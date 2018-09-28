<#PSScriptInfo
.VERSION 1.0.0
.GUID 168b59de-fd55-4f63-b345-f876152c2323
.AUTHOR Microsoft Corporation
.COMPANYNAME Microsoft Corporation
.COPYRIGHT
.TAGS DSCConfiguration
.LICENSEURI https://github.com/PowerShell/WmiNamespaceSecurityDsc/blob/master/LICENSE
.PROJECTURI https://github.com/PowerShell/WmiNamespaceSecurityDsc
.ICONURI
.EXTERNALMODULEDEPENDENCIES
.REQUIREDSCRIPTS
.EXTERNALSCRIPTDEPENDENCIES
.RELEASENOTES First version.
.PRIVATEDATA 2016-Datacenter,2016-Datacenter-Server-Core
#>

#Requires -module WmiNamespaceSecurityDsc

<#
    .SYNOPSIS
        Configuration that removes the account, so the account no longer have
        permission to the specified WMI namespace.

    .DESCRIPTION
        Configuration that removes the account, so the account no longer have
        permission to the specified WMI namespace.

    .PARAMETER Path
        The path of WMI namespace to remove the account from. e.g. 'root/cimv2'.

    .PARAMETER Principal
        The user account that should be removed, e.g. 'Domain\Steve'.

    .EXAMPLE
        WmiNamespaceSecurity_RemovePermissionFromWmiNamespaceConfig -Path 'root/cimv2' -Principal 'Domain\Steve'

        Compiles a configuration that removes the user account 'Domain\Steve'
        from the WMI namespace 'root/cimv2'.

    .EXAMPLE
        $configurationParameters = @{
            Path = 'root/cimv2'
            Principal = 'Domain\Steve'
        }
        Start-AzureRmAutomationDscCompilationJob -ResourceGroupName '<resource-group>' -AutomationAccountName '<automation-account>' -ConfigurationName 'WmiNamespaceSecurity_RemovePermissionFromWmiNamespaceConfig' -Parameters $configurationParameters

        Compiles a configuration in Azure Automation that removes the user
        account 'Domain\Steve' from the WMI namespace 'root/cimv2'.

        Replace the <resource-group> and <automation-account> with correct values.
#>
Configuration WmiNamespaceSecurity_RemovePermissionFromWmiNamespaceConfig
{
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Path,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Principal
    )

    Import-DSCResource -ModuleName WmiNamespaceSecurityDsc

    Node $AllNodes.NodeName
    {
        WmiNamespaceSecurity AddAccountJason
        {
            Path = $Path
            Principal = $Principal
            AccessType = 'Allow'
            Ensure = 'Absent'
        }
    }
}
