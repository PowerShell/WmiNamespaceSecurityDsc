$script:dscModuleName = 'WmiNamespaceSecurityDsc'
$script:dscResourceFriendlyName = 'WmiNamespaceSecurity'
$script:dcsResourceName = $script:dscResourceFriendlyName

<#
    Remove any existing loaded modules in the session. The module will
    be re-imported by the Initialize-TestEnvironment.
    If there are duplicate modules imported into the session, the line
    47-54 will fail, since Get-Module will return multiple versions.
    It could return duplicate version due to the Examples that get published
    import it into the session too.
#>
Get-Module -Name WmiNamespaceSecurityDsc -All | Remove-Module -Force

#region HEADER
# Integration Test Template Version: 1.3.1
[String] $script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if ( (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
    (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone', 'https://github.com/PowerShell/DscResource.Tests.git', (Join-Path -Path $script:moduleRoot -ChildPath 'DscResource.Tests'))
}

Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'DSCResource.Tests' -ChildPath 'TestHelper.psm1')) -Force
$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $script:dscModuleName `
    -DSCResourceName $script:dcsResourceName `
    -TestType Integration `
    -ResourceType 'Class'
#endregion

try
{
    $configurationFile = Join-Path -Path $PSScriptRoot -ChildPath "$($script:dcsResourceName).config.ps1"
    . $configurationFile

    # The variable $ConfigurationData was dot-sourced above.
    $nsname = $ConfigurationData.AllNodes.NamespaceName
    $nspath = $ConfigurationData.AllNodes.NamespacePath
    $testuser = $ConfigurationData.AllNodes.TestUserName
    $testuserPassword = $ConfigurationData.AllNodes.TestUserPassword

    $principal = New-Object Security.Principal.WindowsPrincipal -ArgumentList ([Security.Principal.WindowsIdentity]::GetCurrent())
    if (!$principal.IsInRole( [Security.Principal.WindowsBuiltInRole]::Administrator))
    {
        throw "These tests require an elevated PowerShell session"
    }

    # Used to access the type until types export is supported
    . (Get-Module -Name WmiNamespaceSecurityDsc) {
        Set-Variable -Name wminsclass -Value ([type]"WmiNamespaceSecurity") -Scope 1
    }

    . (Get-Module -Name WmiNamespaceSecurityDsc) {
        Set-Variable -Name wmiperms -Value ([type]"WmiPermission") -Scope 1
    }

    Describe "Set WMI Namespace Security" {
        BeforeAll {
            net user $testuser /delete 2> $null
            net user $testuser $testuserPassword /add 2> $null
            $ns = Get-CimInstance -Namespace root -ClassName __namespace -Filter "Name='$nsname'"
            if ($ns -ne $Null)
            {
                $ns | Remove-CimInstance
            }
            New-CimInstance -Namespace "root" -ClassName __namespace -Property @{Name = $nsname}
        }

        AfterAll {
            net user $testuser /delete 2> $null
            Get-CimInstance -Namespace root -ClassName __namespace -Filter "Name='$nsname'" | Remove-CimInstance
        }

        $configurationName = "$($script:dcsResourceName)_SetPermission_Config"

        Context ('When using configuration {0}' -f $configurationName) {
            It 'Should compile and apply the MOF without throwing' {
                {
                    $configurationParameters = @{
                        OutputPath        = $TestDrive
                        ConfigurationData = $ConfigurationData
                    }

                    & $configurationName @configurationParameters

                    $startDscConfigurationParameters = @{
                        Path         = $TestDrive
                        ComputerName = 'localhost'
                        Wait         = $true
                        Verbose      = $true
                        Force        = $true
                        ErrorAction  = 'Stop'
                    }

                    Start-DscConfiguration @startDscConfigurationParameters
                } | Should -Not -Throw
            }

            It "Add user to namespace ACL" {
                $sd = $wminsclass::GetSecurityDescriptor($nspath)
                $ace = $wminsclass::FindAce($sd.DACL, $testuser, "Allow")
                $ace | Should Not BeNullOrEmpty
                $ace.AccessMask | Should BeExactly ([uint32]($wmiperms::Enable + $wmiperms::MethodExecute + $wmiperms::ProviderWrite))
            }

            It 'Should be able to call Get-DscConfiguration without throwing' {
                {
                    $script:currentConfiguration = Get-DscConfiguration -Verbose -ErrorAction Stop
                } | Should -Not -Throw
            }

            It 'Should have set the resource and all the parameters should match' {
                $resourceCurrentState = $script:currentConfiguration | Where-Object -FilterScript {
                    $_.ConfigurationName -eq $configurationName `
                        -and $_.ResourceId -eq "[$($script:dscResourceFriendlyName)]Integration_Test"
                }

                $resourceCurrentState.Ensure | Should -Be 'Present'
                $resourceCurrentState.Path | Should -Be $nspath
                $resourceCurrentState.Principal | Should -Be $testuser
                $resourceCurrentState.AccessType | Should -Be 'Allow'
                $resourceCurrentState.Permission | Should -Be @('Enable', 'MethodExecute', 'ProviderWrite')
                $resourceCurrentState.AppliesTo | Should -Be 'Self'
                $resourceCurrentState.Inherited | Should -Be $false
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                Test-DscConfiguration -Verbose | Should -Be $true
            }
        }

        $configurationName = "$($script:dcsResourceName)_ChangePermission_Config"

        Context ('When using configuration {0}' -f $configurationName) {
            It 'Should compile and apply the MOF without throwing' {
                {
                    $configurationParameters = @{
                        OutputPath        = $TestDrive
                        ConfigurationData = $ConfigurationData
                    }

                    & $configurationName @configurationParameters

                    $startDscConfigurationParameters = @{
                        Path         = $TestDrive
                        ComputerName = 'localhost'
                        Wait         = $true
                        Verbose      = $true
                        Force        = $true
                        ErrorAction  = 'Stop'
                    }

                    Start-DscConfiguration @startDscConfigurationParameters
                } | Should -Not -Throw
            }

            It "Change user permission in namespace ACL" {
                $sd = $wminsclass::GetSecurityDescriptor($nspath)
                $ace = $wminsclass::FindAce($sd.DACL, $testuser, "Allow")
                $ace | Should Not BeNullOrEmpty
                $ace.AccessMask | Should BeExactly ([uint32]($wmiperms::Enable + $wmiperms::ProviderWrite))
            }

            It 'Should be able to call Get-DscConfiguration without throwing' {
                {
                    $script:currentConfiguration = Get-DscConfiguration -Verbose -ErrorAction Stop
                } | Should -Not -Throw
            }

            It 'Should have set the resource and all the parameters should match' {
                $resourceCurrentState = $script:currentConfiguration | Where-Object -FilterScript {
                    $_.ConfigurationName -eq $configurationName `
                        -and $_.ResourceId -eq "[$($script:dscResourceFriendlyName)]Integration_Test"
                }

                $resourceCurrentState.Ensure | Should -Be 'Present'
                $resourceCurrentState.Path | Should -Be $nspath
                $resourceCurrentState.Principal | Should -Be $testuser
                $resourceCurrentState.AccessType | Should -Be 'Allow'
                $resourceCurrentState.Permission | Should -Be @('Enable', 'ProviderWrite')
                $resourceCurrentState.AppliesTo | Should -Be 'Self'
                $resourceCurrentState.Inherited | Should -Be $false
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                Test-DscConfiguration -Verbose | Should -Be $true
            }
        }

        $configurationName = "$($script:dcsResourceName)_RemovePermission_Config"

        Context ('When using configuration {0}' -f $configurationName) {
            It 'Should compile and apply the MOF without throwing' {
                {
                    $configurationParameters = @{
                        OutputPath        = $TestDrive
                        ConfigurationData = $ConfigurationData
                    }

                    & $configurationName @configurationParameters

                    $startDscConfigurationParameters = @{
                        Path         = $TestDrive
                        ComputerName = 'localhost'
                        Wait         = $true
                        Verbose      = $true
                        Force        = $true
                        ErrorAction  = 'Stop'
                    }

                    Start-DscConfiguration @startDscConfigurationParameters
                } | Should -Not -Throw
            }

            It "Remove user from namespace ACL" {
                $sd = $wminsclass::GetSecurityDescriptor($nspath)
                $ace, $index = $wminsclass::FindAce($sd.DACL, $testuser, "Allow")
                $ace | Should BeNullOrEmpty
                $index | Should BeExactly -1
            }

            It 'Should be able to call Get-DscConfiguration without throwing' {
                {
                    $script:currentConfiguration = Get-DscConfiguration -Verbose -ErrorAction Stop
                } | Should -Not -Throw
            }

            It 'Should have set the resource and all the parameters should match' {
                $resourceCurrentState = $script:currentConfiguration | Where-Object -FilterScript {
                    $_.ConfigurationName -eq $configurationName `
                        -and $_.ResourceId -eq "[$($script:dscResourceFriendlyName)]Integration_Test"
                }

                #$resourceCurrentState.Ensure | Should -Be 'Absent'
                $resourceCurrentState.Path | Should -Be $nspath
                $resourceCurrentState.Principal | Should -BeNullOrEmpty
                $resourceCurrentState.AccessType | Should -BeNullOrEmpty
                $resourceCurrentState.Permission | Should -BeNullOrEmpty
                $resourceCurrentState.AppliesTo | Should -Be 'Self'
                $resourceCurrentState.Inherited | Should -Be $false
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                Test-DscConfiguration -Verbose | Should -Be $true
            }
        }
    }
}
finally
{
    #region FOOTER
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
    #endregion
}
