function Get-WinDataFromFile {
    <#
    .SYNOPSIS
    Retrieves data from a file based on the provided file path, data type, and file type.

    .DESCRIPTION
    This function reads data from a specified file path and handles different file types such as XML and JSON. It retrieves the data based on the specified data type and provides detailed error handling for file loading issues.

    .PARAMETER FilePath
    Specifies the path to the file from which data will be retrieved.

    .PARAMETER Type
    Specifies the type of data to retrieve from the file.

    .PARAMETER FileType
    Specifies the type of file to read. Default is 'XML'.

    .EXAMPLE
    Get-WinDataFromFile -FilePath "C:\Data\data.xml" -Type 'UserData' -FileType 'XML'

    Retrieves data of type 'UserData' from the XML file located at "C:\Data\data.xml".

    .NOTES
    This function is used to retrieve data from files based on the specified parameters.
    #>
    [cmdletbinding()]
    param(
        [string] $FilePath,
        [string] $Type,
        [string] $FileType = 'XML'
    )
    try {
        if (Test-Path $FilePath) {
            if ($FileType -eq 'XML') {
                $Data = Import-Clixml -Path $FilePath -ErrorAction Stop
            } else {
                $File = Get-Content -Raw -Path $FilePath
                $Data = ConvertFrom-Json -InputObject $File
            }
        } else {
            Write-Warning "Couldn't load $FileType file from $FilePath for $Type data. File doesn't exists."
        }
    } catch {
        $ErrorMessage = $_.Exception.Message -replace "`n", " " -replace "`r", " "
        Write-Warning "Couldn't load $FileType file from $FilePath for $Type data. Error occured: $ErrorMessage"
    }
    return $Data
}