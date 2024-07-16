function Test-Configuration {
    <#
    .SYNOPSIS
    This function tests the configuration settings for generating documentation and provides feedback on any errors encountered.

    .DESCRIPTION
    Test-Configuration is used to validate the configuration settings required for generating documentation. It checks if all necessary parameters are correctly set up and provides feedback on any missing or incorrect configurations.

    .PARAMETER Document
    Specifies the document object containing configuration details for documentation.

    .NOTES
    File Name      : Test-Configuration.ps1
    Prerequisite   : This function should be run before starting the documentation process.

    .EXAMPLE
    Test-Configuration -Document $Document
    Validates the configuration settings for generating documentation based on the specified document object.

    #>
    [CmdletBinding()]
    param (
        [System.Collections.IDictionary] $Document
    )
    [int] $ErrorCount = 0
    $Script:WriteParameters = $Document.Configuration.DisplayConsole


    $Keys = Get-ObjectKeys -Object $Document -Ignore 'Configuration'
    foreach ($Key in $Keys) {
        $ErrorCount += Test-File -File $Document.$Key.FilePathWord -FileName 'FilePathWord' -Skip:(-not $Document.$Key.ExportWord)
        $ErrorCount += Test-File -File $Document.$Key.FilePathExcel -FileName 'FilePathExcel' -Skip:(-not $Document.$Key.ExportExcel)
    }
    if ($ErrorCount -ne 0) {
        Exit
    }
}