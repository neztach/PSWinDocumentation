function Get-DocumentPath {
    <#
    .SYNOPSIS
    Retrieves the document path based on the provided configuration and template options.

    .DESCRIPTION
    This function determines the document path to be used for generating a Word document based on the configuration settings and template options provided. It checks if a built-in template or a custom template path is specified and returns the appropriate document path.

    .PARAMETER Document
    Specifies the document configuration containing template and path information.

    .PARAMETER FinalDocumentLocation
    Specifies the final location where the generated document will be saved.

    .EXAMPLE
    Get-DocumentPath -Document $DocumentConfig -FinalDocumentLocation "C:\GeneratedDocuments\Output.docx"

    Retrieves the document path based on the configuration settings in $DocumentConfig and saves the generated document at "C:\GeneratedDocuments\Output.docx".

    .NOTES
    This function is used to determine the document path for generating Word documents based on the provided configuration and template options.
    #>
    [CmdletBinding()]
    param (
        [System.Collections.IDictionary] $Document,
        [string] $FinalDocumentLocation
    )
    if ($Document.Configuration.Prettify.UseBuiltinTemplate) {
        #Write-Verbose 'Get-DocumentPath - Option 1'
        #$WordDocument = Get-WordDocument -FilePath "$((get-item $PSScriptRoot).Parent.FullName)\Templates\WordTemplate.docx"
        $WordDocument = Get-WordDocument -FilePath "$($MyInvocation.MyCommand.Module.ModuleBase)\Templates\WordTemplate.docx"
    } else {
        if ($Document.Configuration.Prettify.CustomTemplatePath) {
            if ($(Test-File -File $Document.Configuration.Prettify.CustomTemplatePath -FileName 'CustomTemplatePath') -eq 0) {
                # Write-Verbose 'Get-DocumentPath - Option 2'
                $WordDocument = Get-WordDocument -FilePath $Document.Configuration.Prettify.CustomTemplatePath
            } else {
                #Write-Verbose 'Get-DocumentPath - Option 3'
                $WordDocument = New-WordDocument -FilePath $FinalDocumentLocation
            }
        } else {
            #Write-Verbose 'Get-DocumentPath - Option 4'
            $WordDocument = New-WordDocument -FilePath $FinalDocumentLocation
        }
    }
    if ($null -eq $WordDocument) { Write-Verbose ' Null'}
    return $WordDocument
}
