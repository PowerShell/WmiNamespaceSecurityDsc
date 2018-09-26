<#
    .EXAMPLE
        This example shows how to add two accounts so they got permission
        to the root/cimv2 namespace.
#>

Configuration Example
{
    Import-DSCResource -ModuleName WmiNamespaceSecurityDsc

    Node $AllNodes.NodeName
    {
        WmiNamespaceSecurity AddAccountJason
        {
            Path = 'root/cimv2'
            Principal = 'Jason'
            AppliesTo = 'Self'
            AccessType = 'Allow'
            Permission = 'Enable', 'MethodExecute', 'ProviderWrite'
            Ensure = 'Present'
        }

        WmiNamespaceSecurity AddAccountSteve
        {
            Path = 'root/cimv2'
            Principal = 'Contoso\Steve'
            AppliesTo = 'Children'
            AccessType = 'Deny'
            Permission = 'Enable', 'MethodExecute', 'ProviderWrite', 'RemoteAccess'
            Ensure = 'Present'
        }
    }
}
