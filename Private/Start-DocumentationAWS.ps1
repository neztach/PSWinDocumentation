function Start-DocumentationAWS {
    <#
    .SYNOPSIS
    This function starts the documentation process for Amazon Web Services (AWS).

    .DESCRIPTION
    Start-DocumentationAWS initiates the documentation process for AWS. It retrieves necessary data and generates documentation in various formats based on the provided parameters.

    .PARAMETER Document
    Specifies the document object containing configuration details for AWS documentation.

    .NOTES
    File Name      : Start-DocumentationAWS.ps1
    Prerequisite   : This function requires the Test-Configuration function to be run first.

    .EXAMPLE
    Start-DocumentationAWS -Document $Document
    Initiates the documentation process for AWS based on the specified document object.
    #>
    [CmdletBinding()]
    param(
        [System.Collections.IDictionary] $Document
    )
    $TimeDataOnly = [System.Diagnostics.Stopwatch]::StartNew() # Timer Start

    $DataSections = ($Document.DocumentAWS.Sections).Keys
    $TypesRequired = Get-TypesRequired -Sections $Document.DocumentAWS.Sections

    $DataInformation = Get-WinServiceData -Credentials $Document.DocumentAWS.Services.Amazon.Credentials `
        -Service $Document.DocumentAWS.Services.Amazon.AWS `
        -TypesRequired $TypesRequired `
        -Type 'AWS'

    $TimeDataOnly.Stop()

    $TimeDocuments = [System.Diagnostics.Stopwatch]::StartNew() # Timer Start
    # Saves data to XML is required - skipped when Offline mode is on
    if ($DataInformation.Count -gt 0) {
        ### Starting WORD
        if ($Document.DocumentAWS.ExportWord) {
            $WordDocument = Get-DocumentPath -Document $Document -FinalDocumentLocation $Document.DocumentAWS.FilePathWord
        }
        if ($Document.DocumentAWS.ExportExcel) {
            $ExcelDocument = New-ExcelDocument
        }
        ### Start Sections
        foreach ($Section in $DataSections) {
            $WordDocument = New-DataBlock `
                -WordDocument $WordDocument `
                -Section $Document.DocumentAWS.Sections.$Section `
                -Forest $DataInformation `
                -Excel $ExcelDocument `
                -SectionName $Section `
                -Sql $Document.DocumentAWS.ExportSQL -ExportWord $Document.DocumentAWS.ExportWord
        }
        ### End Sections

        ### Ending WORD
        if ($Document.DocumentAWS.ExportWord) {
            $FilePath = Save-WordDocument -WordDocument $WordDocument -Language $Document.Configuration.Prettify.Language -FilePath $Document.DocumentAWS.FilePathWord -Supress $True -OpenDocument:$Document.Configuration.Options.OpenDocument
        }
        ### Ending EXCEL
        if ($Document.DocumentAWS.ExportExcel) {
            $ExcelData = Save-ExcelDocument -ExcelDocument $ExcelDocument -FilePath $Document.DocumentAWS.FilePathExcel -OpenWorkBook:$Document.Configuration.Options.OpenExcel
        }
    } else {
        Write-Warning "There was no data to process AWS documentation. Check configuration."
    }
    $TimeDocuments.Stop()
    Write-Verbose "Time to gather data: $($TimeDataOnly.Elapsed)"
    Write-Verbose "Time to create documents: $($TimeDocuments.Elapsed)"
}