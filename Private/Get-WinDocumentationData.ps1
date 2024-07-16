function Get-WinDocumentationData {
    <#
    .SYNOPSIS
    Retrieves specific data related to Active Directory forests and domains.

    .DESCRIPTION
    This function retrieves specific data related to Active Directory forests and domains based on the provided parameters. It distinguishes between forest and domain data and returns the corresponding information.

    .PARAMETER DataToGet
    Specifies the type of data to retrieve.

    .PARAMETER Object
    Specifies the object containing the data to retrieve.

    .PARAMETER Domain
    Specifies the domain for which the data should be retrieved.

    .EXAMPLE
    Get-WinDocumentationData -DataToGet 'ForestInformation' -Object $ForestData -Domain 'example.com'

    Retrieves the forest information for the specified domain 'example.com' from the provided object $ForestData.

    .NOTES
    This function is used to retrieve specific data related to Active Directory forests and domains.
    #>
    [CmdletBinding()]
    param (
        [alias("Data")][Object] $DataToGet,
        [alias("Forest")][Object] $Object,
        [string] $Domain
    )
    if ($null -ne $DataToGet) {
        $Type = Get-ObjectType -Object $DataToGet -ObjectName 'Get-WinDocumentationData' #-Verbose
        if ($Type.ObjectTypeName -eq 'ActiveDirectory') {
            #Write-Verbose "Get-WinDocumentationData - DataToGet: $DataToGet Domain: $Domain"
            if ("$DataToGet" -like 'Forest*') {
                return $Object."$DataToGet"
            } elseif ($DataToGet.ToString() -like 'Domain*' ) {
                return $Object.FoundDomains.$Domain."$DataToGet"
            }
        } else {
            #Write-Verbose "Get-WinDocumentationData - DataToGet: $DataToGet Object: $($Object.Count)"
            return $Object."$DataToGet"
        }
    }
    return
}
