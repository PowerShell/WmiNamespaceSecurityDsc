<#PSScriptInfo
.VERSION 1.0.0
.GUID 692d357b-07aa-4762-881a-b076d4237529
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
        Configuration that sets or changes the specified permissions for the
        specified user account, on the specified WMI namespace.

    .DESCRIPTION
        Configuration that sets or changes the specified permissions for the
        specified user account, on the specified WMI namespace.

    .PARAMETER Path
        The path of WMI namespace to change permission on, e.g. 'root/cimv2'.

    .PARAMETER Principal
        The user account that the permission is set for, e.g. 'Domain\Steve'.

    .PARAMETER Permission
        One or more permissions to set for the principal. This is an string array,
        and can be set to one or more of these values; 'Enable', 'MethodExecute',
        'FullWrite', 'PartialWrite', 'ProviderWrite', 'RemoteAccess', 'Subscribe',
        'Publish', 'ReadSecurity', 'WriteSecurity'.
        Defaults to @('Enable', 'MethodExecute').

    .EXAMPLE
        WmiNamespaceSecurity_AddPermissionToWmiNamespaceConfig -Path 'root/cimv2' -Principal 'Domain\Steve' -Permission @('Enable','MethodExecute')

        Compiles a configuration that sets the permissions 'Enable','MethodExecute'
        for the user account 'Domain\Steve' in the WMI namespace 'root/cimv2'.

    .EXAMPLE
        $configurationParameters = @{
            Path = 'root/cimv2'
            Principal = 'Domain\Steve'
            Permission = @('Enable','MethodExecute')
        }
        Start-AzureRmAutomationDscCompilationJob -ResourceGroupName '<resource-group>' -AutomationAccountName '<automation-account>' -ConfigurationName 'WmiNamespaceSecurity_AddPermissionToWmiNamespaceConfig' -Parameters $configurationParameters

        Compiles a configuration in Azure Automation that sets the permissions
        'Enable','MethodExecute' for the user account 'Domain\Steve' in the
        WMI namespace 'root/cimv2'.

        Replace the <resource-group> and <automation-account> with correct values.
#>
Configuration WmiNamespaceSecurity_AddPermissionToWmiNamespaceConfig
{
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Path,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Principal,

        [Parameter()]
        [ValidateSet('Enable', 'MethodExecute', 'FullWrite', 'PartialWrite', 'ProviderWrite', 'RemoteAccess', 'Subscribe', 'Publish', 'ReadSecurity', 'WriteSecurity')]
        [System.String[]]
        $Permission = @('Enable', 'MethodExecute')
    )

    Import-DSCResource -ModuleName WmiNamespaceSecurityDsc

    Node $AllNodes.NodeName
    {
        WmiNamespaceSecurity AddAccountJason
        {
            Path = $Path
            Principal = $Principal
            AppliesTo = 'Self'
            AccessType = 'Allow'
            Permission = $Permission
            Ensure = 'Present'
        }
    }
}
