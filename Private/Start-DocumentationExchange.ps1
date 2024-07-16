function Start-DocumentationExchange {
    <#
    .SYNOPSIS
    This function starts the documentation process for Exchange services.

    .DESCRIPTION
    Start-DocumentationExchange initiates the documentation process for Exchange services. It retrieves necessary data and generates documentation in various formats based on the provided parameters.

    .PARAMETER Document
    Specifies the document object containing configuration details for Exchange documentation.

    .NOTES
    File Name      : Start-DocumentationExchange.ps1
    Prerequisite   : This function requires the Test-Configuration function to be run first.

    .EXAMPLE
    Start-DocumentationExchange -Document $Document
    Initiates the documentation process for Exchange services based on the specified document object.
    #>
    [CmdletBinding()]
    param(
        [System.Collections.IDictionary] $Document
    )
    $DataSections = ($Document.DocumentExchange.Sections).Keys
    $TypesRequired = Get-TypesRequired -Sections $Document.DocumentExchange.Sections

    $TimeDataOnly = [System.Diagnostics.Stopwatch]::StartNew() # Timer Start

    $DataInformation = Get-WinServiceData -Credentials $Document.DocumentExchange.Services.OnPremises.Credentials `
        -Service $Document.DocumentExchange.Services.OnPremises.Exchange `
        -TypesRequired $TypesRequired `
        -Type 'Exchange'

    $TimeDataOnly.Stop()
    # End Exchange Data
    $TimeDocuments = [System.Diagnostics.Stopwatch]::StartNew() # Timer Start

    if ($DataInformation.Count -gt 0) {
        ### Starting WORD
        if ($Document.DocumentExchange.ExportWord) {
            $WordDocument = Get-DocumentPath -Document $Document -FinalDocumentLocation $Document.DocumentExchange.FilePathWord
        }
        if ($Document.DocumentExchange.ExportExcel) {
            $ExcelDocument = New-ExcelDocument
        }
        ### Start Sections
        foreach ($Section in $DataSections) {
            $WordDocument = New-DataBlock `
                -WordDocument $WordDocument `
                -Section $Document.DocumentExchange.Sections.$Section `
                -Forest $DataInformation `
                -Excel $ExcelDocument `
                -SectionName $Section `
                -Sql $Document.DocumentExchange.ExportSQL -ExportWord $Document.DocumentExchange.ExportWord
        }
        ### End Sections

        ### Ending WORD
        if ($Document.DocumentExchange.ExportWord) {
            $FilePath = Save-WordDocument -WordDocument $WordDocument -Language $Document.Configuration.Prettify.Language -FilePath $Document.DocumentExchange.FilePathWord -Supress $True -OpenDocument:$Document.Configuration.Options.OpenDocument
        }
        ### Ending EXCEL
        if ($Document.DocumentExchange.ExportExcel) {
            $ExcelData = Save-ExcelDocument -ExcelDocument $ExcelDocument -FilePath $Document.DocumentExchange.FilePathExcel -OpenWorkBook:$Document.Configuration.Options.OpenExcel
        }
    } else {
        Write-Warning "There was no data to process Exchange documentation. Check configuration."
    }

    $TimeDocuments.Stop()
    Write-Verbose "Time to gather data: $($TimeDataOnly.Elapsed)"
    Write-Verbose "Time to create documents: $($TimeDocuments.Elapsed)"
}