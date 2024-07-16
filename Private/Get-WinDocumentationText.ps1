function Get-WinDocumentationText {
    <#
    .SYNOPSIS
    Retrieves and replaces placeholders in text with actual values from the provided Forest and Domain data.

    .DESCRIPTION
    This function takes an array of text strings and replaces specific placeholders with corresponding values from the Forest and Domain data. It provides a way to customize text based on the context of the Active Directory environment.

    .PARAMETER Text
    Specifies an array of text strings containing placeholders to be replaced.

    .PARAMETER Forest
    Specifies the data set containing information about the Active Directory forest.

    .PARAMETER Domain
    Specifies the domain for which the text replacements will be applied.

    .EXAMPLE
    Get-WinDocumentationText -Text @('Welcome to <CompanyName>','You are in the <Domain> domain') -Forest $ForestData -Domain 'example.com'

    Retrieves and replaces placeholders in the provided text array with actual values from the Forest and Domain data for the specified domain.

    .NOTES
    This function is used to customize text by replacing placeholders with actual values from Active Directory forest and domain data.
    #>
    [CmdletBinding()]
    param (
        [string[]] $Text,
        [System.Collections.IDictionary] $Forest,
        [string] $Domain
    )

    $Array = foreach ($T in $Text) {
        $T = $T.Replace('<CompanyName>', $Document.Configuration.Prettify.CompanyName)
        $T = $T.Replace('<ForestName>', $Forest.ForestInformation.Name)
        $T = $T.Replace('<ForestNameDN>', $Forest.ForestInformation.'Forest Distingushed Name')
        $T = $T.Replace('<Domain>', $Domain)
        $T = $T.Replace('<DomainNetBios>', $Forest.FoundDomains.$Domain.DomainInformation.NetBIOSName)
        $T = $T.Replace('<DomainDN>', $Forest.FoundDomains.$Domain.DomainInformation.DistinguishedName)
        $T = $T.Replace('<DomainPasswordWeakPasswordList>', $Forest.FoundDomains.$Domain.DomainPasswordDataPasswords.DomainPasswordWeakPasswordList)
        $T
    }
    return $Array
}