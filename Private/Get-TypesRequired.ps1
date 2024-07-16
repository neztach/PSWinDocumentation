function Get-TypesRequired {
    <#
    .SYNOPSIS
    Retrieves the types of data required from different sections based on the provided sections.

    .DESCRIPTION
    This function takes an array of sections and retrieves the types of data required from each section. It iterates through each section, checks for the types of data required, and compiles a list of unique data types.

    .PARAMETER Sections
    Specifies an array of sections containing data types required for processing.

    .EXAMPLE
    Get-TypesRequired -Sections @($Section1, $Section2, $Section3)

    Retrieves the types of data required from each section and returns a list of unique data types.

    .NOTES
    This function is used to determine the types of data required from different sections for processing.
    #>
    [CmdletBinding()]
    param (
        [System.Collections.IDictionary[]] $Sections
    )
    $TypesRequired = New-ArrayList
    $Types = 'TableData', 'ListData', 'ChartData', 'SqlData', 'ExcelData', 'TextBasedData'
    foreach ($Section in $Sections) {
        $Keys = Get-ObjectKeys -Object $Section
        foreach ($Key in $Keys) {
            if ($Section.$Key.Use -eq $True) {
                foreach ($Type in $Types) {
                    #Write-Verbose "Get-TypesRequired - Section: $Key Type: $Type Value: $($Section.$Key.$Type)"
                    Add-ToArrayAdvanced -List $TypesRequired -Element $Section.$Key.$Type -SkipNull -RequireUnique -FullComparison
                }
            }
        }
    }
    Write-Verbose "Get-TypesRequired - FinalList: $($TypesRequired -join ', ')"
    return $TypesRequired
}