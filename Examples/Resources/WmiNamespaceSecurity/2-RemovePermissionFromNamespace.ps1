<#
    .EXAMPLE
        This example shows how to remove the permissions from two accounts, so
        they no longer have permission to the root/cimv2 namespace.
#>

Configuration Example
{
    Import-DSCResource -ModuleName WmiNamespaceSecurityDsc

    Node $AllNodes.NodeName
    {
        WmiNamespaceSecurity RemoveAccountJason
        {
            Path = 'root/cimv2'
            Principal = 'Jason'
            AccessType = 'Allow'
            Ensure = 'Absent'
        }

        WmiNamespaceSecurity RemoveAccountSteve
        {
            Path = 'root/cimv2'
            Principal = 'Contoso\Steve'
            AccessType = 'Deny'
            Ensure = 'Absent'
        }
    }
}
