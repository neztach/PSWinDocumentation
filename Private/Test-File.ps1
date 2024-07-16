function Test-File {
    <#
    .SYNOPSIS
    This function tests the existence of a specified file and provides feedback on its availability.

    .DESCRIPTION
    Test-File is used to check if a specified file exists. It can be used to verify the presence of a file before proceeding with a particular feature that requires it.

    .PARAMETER File
    Specifies the path of the file to be tested.

    .PARAMETER FileName
    Specifies the name of the file being tested.

    .PARAMETER Require
    Indicates whether the file is required for the feature. If set to $true, an error will be raised if the file is not found.

    .PARAMETER Skip
    Skips the file existence check if this switch is provided.

    .EXAMPLE
    Test-File -File 'C:\Example.txt' -FileName 'Example.txt' -Require
    Checks if the file 'Example.txt' exists at the specified path and raises an error if it is not found.

    #>
    [CmdletBinding()]
    param (
        [string] $File,
        [string] $FileName,
        [switch] $Require,
        [switch] $Skip
    )
    [int] $ErrorCount = 0
    if ($Skip) {
        return $ErrorCount
    }
    if ($File -ne '') {
        if ($Require) {
            if (Test-Path $File) {
                return $ErrorCount
            } else {
                Write-Color  @Script:WriteParameters '[e] ', $FileName, " doesn't exists (", $File, "). It's required if you want to use this feature." -Color Red, Yellow, Yellow, White
                $ErrorCount++
            }
        }
    } else {
        $ErrorCount++
        Write-Color @Script:WriteParameters '[e] ', $FileName, " was empty. It's required if you want to use this feature." -Color Red, Yellow, White
    }
    return $ErrorCount
}
