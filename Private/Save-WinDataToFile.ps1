function Save-WinDataToFile {
    <#
    .SYNOPSIS
    Saves data to a file in XML or JSON format based on the provided parameters.

    .DESCRIPTION
    This function exports data to a specified file path in either XML or JSON format. It handles offline mode where data is not re-saved.

    .PARAMETER Export
    Specifies whether to export the data.

    .PARAMETER Type
    Specifies the type of data being saved.

    .PARAMETER Data
    Specifies the data to be saved.

    .PARAMETER FilePath
    Specifies the file path where the data will be saved.

    .PARAMETER IsOffline
    Indicates if the operation is offline.

    .PARAMETER FileType
    Specifies the type of file to save the data in. Default is 'XML'.
    #>
    [cmdletbinding()]
    param(
        [nullable[bool]] $Export,
        [string] $Type,
        [Object] $Data,
        [string] $FilePath,
        [switch] $IsOffline,
        [string] $FileType = 'XML'
    )
    if ($IsOffline) {
        # This means data is loaded from xml so it doesn't need to be resaved to XML
        Write-Verbose "Save-WinDataToFile - Exporting $Type data to $FileType to path $FilePath skipped. Running in offline mode."
        return
    }
    if ($Export) {
        if ($FilePath) {
            $Split = Split-Path -Path $FilePath
            if (-not (Test-Path -Path $Split)) {
                # Creates directory path if it doesn't exits
                New-Item -ItemType Directory -Force -Path $Split > $null
            }
            Write-Verbose "Save-WinDataToFile - Exporting $Type data to $FileType to path $FilePath"
            if ($FileType -eq 'XML') {
                try {
                    $Data | Export-Clixml -Path $FilePath -ErrorAction Stop -Encoding UTF8
                } catch {
                    $ErrorMessage = $_.Exception.Message -replace "`n", " " -replace "`r", " "
                    Write-Warning "Couldn't save $FileType file to $FilePath for $Type data. Error occured: $ErrorMessage"
                }
            } else {
                try {
                    $Data | ConvertTo-Json -ErrorAction Stop  | Add-Content -Path $FilePath -Encoding UTF8 -ErrorAction Stop
                } catch {
                    $ErrorMessage = $_.Exception.Message -replace "`n", " " -replace "`r", " "
                    Write-Warning "Couldn't save $FileType file to $FilePath for $Type data. Error occured: $ErrorMessage"
                }
            }
        }
    }
}