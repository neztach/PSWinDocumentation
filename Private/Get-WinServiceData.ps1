function Get-WinServiceData {
    <#
    .SYNOPSIS
    Retrieves data from various services based on the provided credentials and service type.

    .DESCRIPTION
    This function connects to different services based on the specified service type and retrieves relevant data using the provided credentials.

    .PARAMETER Credentials
    Specifies the credentials required to connect to the services.

    .PARAMETER Service
    Specifies the service details for data retrieval.

    .PARAMETER Type
    Specifies the type of service to connect to.

    .PARAMETER TypesRequired
    Specifies the types of data required from the service.

    .EXAMPLE
    Get-WinServiceData -Credentials $Creds -Service $ServiceDetails -Type 'ActiveDirectory' -TypesRequired @('Type1', 'Type2')

    Retrieves data from Active Directory service with the specified credentials and service details.

    .NOTES
    This function is used to retrieve data from various services based on the provided parameters.
    #>
    [CmdletBinding()]
    param (
        [Object] $Credentials,
        [Object] $Service,
        [string] $Type,
        [Object] $TypesRequired
    )

    # Temporary hack - requires rewrite
    if ($Type -eq 'O365') {
        $CommandOutput = @(
            Connect-WinService -Type 'ExchangeOnline' -Credentials $Credentials -Service $Service -Verbose
            Connect-WinService -Type 'Azure' -Credentials $Credentials -Service $Service -Verbose
        )
    } else {
        $CommandOutput = Connect-WinService -Type $Type `
            -Credentials $Credentials `
            -Service $Service `
            -Verbose
    }

    if ($Service.Use) {
        if ($Service.OnlineMode) {
            switch ($Type) {
                'ActiveDirectory' {
                    if ($Service.PasswordTests.Use) {
                        $PasswordClearText = $Service.PasswordTests.PasswordFilePathClearText
                    } else {
                        $PasswordClearText = ''
                    }
                    if ($Service.PasswordTests.UseHashDB) {
                        $PasswordHashes = $Service.PasswordTests.PasswordFilePathHash
                    } else {
                        $PasswordHashes = ''
                    }
                    if ($PasswordClearText -or $PasswordHashes) {
                        $PasswordQuality = $true
                    } else {
                        $PasswordQuality = $false
                    }
                    $DataInformation = Get-WinADForestInformation -TypesRequired $TypesRequired -PathToPasswords $PasswordClearText -PathToPasswordsHashes $PasswordHashes -PasswordQuality:$PasswordQuality -Verbose
                }
                'AWS' {
                    $DataInformation = Get-WinAWSInformation -TypesRequired $TypesRequired -AWSAccessKey $Credentials.AccessKey -AWSSecretKey $Credentials.SecretKey -AWSRegion $Credentials.Region
                }
                #'Azure' {
                #    $DataInformation = Get-WinO365Azure -TypesRequired $TypesRequired # -Prefix would require session
                #}
                #'Exchange' {
                #    $DataInformation = Get-WinExchangeInformation -TypesRequired $TypesRequired -Prefix $Service.Prefix
                #}
                #'ExchangeOnline' {
                #    $DataInformation = Get-WinO365Exchange -TypesRequired $TypesRequired -Prefix $Service.Prefix
                #}
                'O365' {
                    $DataInformation = Get-WinO365 -TypesRequired $TypesRequired -Prefix $Service.Prefix
                }
            }
            if ($Service.Export.Use) {
                $Time = Start-TimeLog
                if ($Service.Export.To -eq 'File' -or $Service.Export.To -eq 'Both') {
                    Save-WinDataToFile -Export $Service.Export.Use -FilePath $Service.Export.FilePath -Data $DataInformation -Type $Type -IsOffline:$false -FileType 'XML'
                    $TimeSummary = Stop-TimeLog -Time $Time -Option OneLiner
                    Write-Verbose "Saving data for $Type to file $($Service.Export.FilePath) took: $TimeSummary"
                }
                if ($Service.Export.To -eq 'Folder' -or $Service.Export.To -eq 'Both') {
                    $Time = Start-TimeLog
                    Save-WinDataToFileInChunks -Export $Service.Export.Use -FolderPath $Service.Export.FolderPath -Data $DataInformation -Type $Type -IsOffline:$false -FileType 'XML'
                    $TimeSummary = Stop-TimeLog -Time $Time -Option OneLiner
                    Write-Verbose "Saving data for $Type to folder $($Service.Export.FolderPath) took: $TimeSummary"
                }
            }
            return $DataInformation
        } else {
            if ($Service.Import.Use) {
                $Time = Start-TimeLog
                if ($Service.Import.From -eq 'File') {
                    Write-Verbose "Loading data for $Type in offline mode from XML File $($Service.Import.Path). Hang on..."
                    $DataInformation = Get-WinDataFromFile -FilePath $Service.Import.Path -Type $Type -FileType 'XML'
                } elseif ($Service.Import.From -eq 'Folder') {
                    Write-Verbose "Loading data for $Type in offline mode from XML File $($Service.Import.Path). Hang on..."
                    $DataInformation = Get-WinDataFromFileInChunks -FolderPath $Service.Import.Path -Type $Type -FileType 'XML'
                } else {
                    Write-Warning "Wrong option for Import.Use. Only Folder/File is supported."
                }
                $TimeSummary = Stop-TimeLog -Time $Time -Option OneLiner
                Write-Verbose "Loading data for $Type in offline mode from file took $TimeSummary"
                return $DataInformation
            }

        }
    }
}