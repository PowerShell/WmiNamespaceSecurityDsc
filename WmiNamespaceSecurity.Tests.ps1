$nsname = "WmiNamespaceTest"
$nspath = "root\$nsname"
$testuser = "WmiNamespaceUser"
$testuserPassword = "Pa55w0rd!!"

$principal = New-Object Security.Principal.WindowsPrincipal -ArgumentList ([Security.Principal.WindowsIdentity]::GetCurrent())
if (!$principal.IsInRole( [Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw "These tests require an elevated PowerShell session"
}

# used to access the type until types export is supported
Import-Module WmiNamespaceSecurityResource
. (Get-module WmiNamespaceSecurityResource) { set-variable -name wminsclass -value ([type]"WmiNamespaceSecurity") -scope 1 }
. (Get-module WmiNamespaceSecurityResource) { set-variable -name wmiperms -value ([type]"WmiPermission") -scope 1 }

Describe "Set WMI Namespace Security" {
    BeforeAll {
        net user $testuser /delete 2> $null
        net user $testuser $testuserPassword /add 2> $null
        $ns = Get-CimInstance -Namespace root -ClassName __namespace -Filter "Name='$nsname'"
        if ($ns -ne $Null) {
            $ns | Remove-CimInstance
        }
        New-CimInstance -Namespace "root" -ClassName __namespace -Property @{Name=$nsname}
    }

    AfterAll {
        net user $testuser /delete 2> $null
        Get-CimInstance -Namespace root -ClassName __namespace -Filter "Name='$nsname'" | Remove-CimInstance
    }

    It "Add user to namespace ACL" {
        
        Configuration SetTest {
            Import-DscResource -Module WmiNamespaceSecurity
        
            WMINamespaceSecurity namespacetest {
                Path = "$nspath"
                AppliesTo = "self"
                Principal = "$testuser"
                AccessType = "Allow"
                Permission = "Enable", "MethodExecute", "ProviderWrite"
                Ensure = "Present"
            }
        }

        SetTest -OutputPath TestDrive:\dsc
        "TestDrive:\dsc\localhost.mof" | Should Exist

        Start-DscConfiguration -Path "TestDrive:\dsc" -Force -Wait
        $sd = $wminsclass::GetSecurityDescriptor($nspath)
        $ace = $wminsclass::FindAce($sd.DACL, $testuser, "Allow")
        $ace | Should Not BeNullOrEmpty
        $ace.AccessMask | Should BeExactly ([uint32]($wmiperms::Enable + $wmiperms::MethodExecute + $wmiperms::ProviderWrite))
    }

    It "Change user permission in namespace ACL" {
        
        Configuration SetTest {
            Import-DscResource -Module WmiNamespaceSecurity
        
            WMINamespaceSecurity namespacetest {
                Path = "$nspath"
                AppliesTo = "self"
                Principal = "$testuser"
                AccessType = "Allow"
                Permission = "Enable", "ProviderWrite"
                Ensure = "Present"
            }
        }

        SetTest -OutputPath TestDrive:\dsc
        "TestDrive:\dsc\localhost.mof" | Should Exist

        Start-DscConfiguration -Path "TestDrive:\dsc" -Force -Wait
        $sd = $wminsclass::GetSecurityDescriptor($nspath)
        $ace = $wminsclass::FindAce($sd.DACL, $testuser, "Allow")
        $ace | Should Not BeNullOrEmpty
        $ace.AccessMask | Should BeExactly ([uint32]($wmiperms::Enable + $wmiperms::ProviderWrite))
    }

    It "Remove user from namespace ACL" {
        
        Configuration SetTest {
            Import-DscResource -Module WmiNamespaceSecurity
        
            WMINamespaceSecurity namespacetest {
                Path = "$nspath"
                Principal = "$testuser"
                AccessType = "Allow"
                Ensure = "Absent"
            }
        }

        SetTest -OutputPath TestDrive:\dsc
        "TestDrive:\dsc\localhost.mof" | Should Exist

        Start-DscConfiguration -Path "TestDrive:\dsc" -Force -Wait
        $sd = $wminsclass::GetSecurityDescriptor($nspath)
        $ace, $index = $wminsclass::FindAce($sd.DACL, $testuser, "Allow")
        $ace | Should BeNullOrEmpty
        $index | Should BeExactly -1
    }

}

