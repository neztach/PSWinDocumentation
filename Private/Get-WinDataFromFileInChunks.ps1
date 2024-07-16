function Get-WinDataFromFileInChunks {
    <#
    .SYNOPSIS
    Retrieves data from files in chunks based on the provided folder path, file type, and data type.

    .DESCRIPTION
    This function reads files from a specified folder path with a given file type and organizes the data into chunks based on the provided data type. It handles errors during file loading and provides detailed warnings if any issues occur.

    .PARAMETER FolderPath
    Specifies the path to the folder containing the files to be processed.

    .PARAMETER FileType
    Specifies the type of files to look for in the folder. Default is 'XML'.

    .PARAMETER Type
    Specifies the data type for organizing the retrieved information.

    .EXAMPLE
    $Data = Get-WinDataFromFileInChunks -FolderPath "C:\DataFiles" -FileType 'CSV' -Type 'UserData'
    $Data | Format-Table -AutoSize
    $Data.'UserData1' | Format-Table

    Retrieves data from CSV files in the 'C:\DataFiles' folder, organizes it as 'UserData' chunks, and displays the information in a table format.

    .NOTES
    This function is used to read and organize data from files in chunks based on the specified parameters.
    #>
    [CmdletBinding()]
    param (
        [string] $FolderPath,
        [string] $FileType = 'XML',
        [Object] $Type
    )
    $DataInformation = @{}
    if (Test-Path $FolderPath) {
        $Files = @( Get-ChildItem -Path "$FolderPath\*.$FileType" -ErrorAction SilentlyContinue -Recurse )
        foreach ($File in $Files) {
            $FilePath = $File.FullName
            $FieldName = $File.BaseName
            Write-Verbose -Message "Importing $FilePath as $FieldName"
            try {
                $DataInformation.$FieldName = Import-CliXML -Path $FilePath -ErrorAction Stop
            } catch {
                $ErrorMessage = $_.Exception.Message -replace "`n", " " -replace "`r", " "
                Write-Warning "Couldn't load $FileType file from $FilePath for $Type data to match into $FieldName. Error occured: $ErrorMessage"
            }
        }
    } else {
        Write-Warning -Message "Couldn't load files ($FileType) from folder $FolderPath as it doesn't exists."
    }
    return $DataInformation
}
<# Simple Use Case

$Data = Get-WinDataFromFileInChunks -FolderPath "$Env:USERPROFILE\Desktop\PSWinDocumentation"
$Data | Format-Table -AutoSize
$Data.FoundDomains.'ad.evotec.xyz' | Ft -a

#>