function Save-WinDataToFileInChunks {
    <#
    .SYNOPSIS
    Saves data to files in chunks.

    .DESCRIPTION
    This function saves data to individual files in chunks based on the keys provided in the input data.

    .PARAMETER Export
    Specifies whether to export the data.

    .PARAMETER Type
    Specifies the type of data being saved.

    .PARAMETER Data
    Specifies the data to be saved.

    .PARAMETER FolderPath
    Specifies the folder path where the files will be saved.

    .PARAMETER IsOffline
    Indicates if the operation is offline.

    .PARAMETER FileType
    Specifies the type of file to save the data in. Default is 'XML'.

    .EXAMPLE
    Save-WinDataToFileInChunks -Export $true -Type 'ExampleType' -Data $Data -FolderPath 'C:\Output' -IsOffline

    Saves the data in chunks to individual XML files in the 'C:\Output' folder.

    .NOTES
    File names are based on the keys in the input data.
    #>
    [CmdletBinding()]
    param(
        [nullable[bool]] $Export,
        [string] $Type,
        [Object] $Data,
        [string] $FolderPath,
        [switch] $IsOffline,
        [string] $FileType = 'XML'
    )

    foreach ($Key in $Data.Keys) {
        $FilePath = [IO.Path]::Combine($FolderPath, "$Key.xml")
        Save-WinDataToFile -Export $Export -Type $Type -IsOffline:$IsOffline -Data $Data.$Key -FilePath $FilePath -FileType $FileType
    }
}