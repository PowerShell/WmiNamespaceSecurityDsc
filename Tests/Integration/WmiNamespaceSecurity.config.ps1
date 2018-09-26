#region HEADER
# Integration Test Config Template Version: 1.2.0
#endregion

$configFile = [System.IO.Path]::ChangeExtension($MyInvocation.MyCommand.Path, 'json')
if (Test-Path -Path $configFile)
{
    $ConfigurationData = Get-Content -Path $configFile | ConvertFrom-Json
}
else
{
    $ConfigurationData = @{
        AllNodes = @(
            @{
                NodeName        = 'localhost'
                CertificateFile = $env:DscPublicCertificatePath

                # TODO: (Optional) Add configuration properties.
                NamespaceName        = 'WmiNamespaceTest'
                NamespacePath        = 'root\WmiNamespaceTest'
                TestUserName         = 'WmiNamespaceUser'
                TestUserPassword     = 'Pa55w0rd!!'
            }
        )
    }
}

<#
    .SYNOPSIS
        Sets the permission of the namespace for the user.
#>
Configuration WmiNamespaceSecurity_SetPermission_Config
{
    Import-DscResource -ModuleName 'WmiNamespaceSecurityDsc'

    node $AllNodes.NodeName
    {
        WmiNamespaceSecurity Integration_Test
        {
            Path = $Node.NamespacePath
            AppliesTo = 'Self'
            Principal = $Node.TestUserName
            AccessType = 'Allow'
            Permission = 'Enable', 'MethodExecute', 'ProviderWrite'
            Ensure = 'Present'
        }
    }
}

<#
    .SYNOPSIS
        Changes the permission of the namespace for the user.
#>
Configuration WmiNamespaceSecurity_ChangePermission_Config
{
    Import-DscResource -ModuleName 'WmiNamespaceSecurityDsc'

    node $AllNodes.NodeName
    {
        WmiNamespaceSecurity Integration_Test
        {
            Path = $Node.NamespacePath
            AppliesTo = 'Self'
            Principal = $Node.TestUserName
            AccessType = 'Allow'
            Permission = 'Enable', 'ProviderWrite'
            Ensure = 'Present'
        }
    }
}

<#
    .SYNOPSIS
        Removes the permission of the namespace for the user.
#>
Configuration WmiNamespaceSecurity_RemovePermission_Config
{
    Import-DscResource -ModuleName 'WmiNamespaceSecurityDsc'

    node $AllNodes.NodeName
    {
        WmiNamespaceSecurity Integration_Test
        {
            Path = $Node.NamespacePath
            Principal = $Node.TestUserName
            AccessType = 'Allow'
            Ensure = 'Absent'
        }
    }
}
