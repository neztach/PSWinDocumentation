function Invoke-ADHTML {
    <#
    .SYNOPSIS
    Generates an HTML dashboard based on the provided Active Directory forest data.

    .DESCRIPTION
    This function generates an interactive HTML dashboard that displays detailed information about the Active Directory forest. It organizes the data into sections and tables for easy visualization.

    .PARAMETER FilePath
    Specifies the file path where the HTML dashboard will be saved.

    .PARAMETER DataSetForest
    Specifies the data set containing information about the Active Directory forest.

    .EXAMPLE
    Invoke-ADHTML -FilePath 'C:\Output\AD_Dashboard.html' -DataSetForest $ForestData

    Generates an HTML dashboard based on the provided Active Directory forest data and saves it to the specified file path.

    .NOTES
    This function is used to create interactive HTML dashboards for Active Directory forests.
    #>
    [cmdletBinding()]
    param(
        [string] $FilePath,
        [System.Collections.IDictionary] $DataSetForest
    )

    Dashboard -Name 'Dashimo Test' -FilePath $FilePath -ShowHTML {
        Tab -Name 'Forest' {
            Section -Name 'Forest Information' -Invisible {
                Section -Name 'Forest Information' {
                    Table -HideFooter -DataTable $DataSetForest.ForestInformation
                }
                Section -Name 'FSMO Roles' {
                    Table -HideFooter -DataTable $DataSetForest.ForestFSMO
                }

            }
            Section -Name 'Forest Domain Controllers' -Collapsable {
                Panel {
                    Table -HideFooter -DataTable $DataSetForest.ForestDomainControllers
                }
            }
            Section -Name 'Forest Optional Features / UPN Suffixes / SPN Suffixes' -Collapsable {

                Panel {
                    Table -HideFooter -DataTable $DataSetForest.ForestOptionalFeatures
                }
                Panel {
                    Table -HideFooter -DataTable $DataSetForest.ForestUPNSuffixes
                }
                Panel {
                    Table -HideFooter -DataTable $DataSetForest.ForestSPNSuffixes
                }
            }
            Section -Name 'Sites / Subnets / SiteLinks' -Collapsable {
                Panel {
                    Table -HideFooter -DataTable $DataSetForest.ForestSites
                }
                Panel {
                    Table -HideFooter -DataTable $DataSetForest.ForestSubnets
                }
                Panel {
                    Table -HideFooter -DataTable $DataSetForest.ForestSiteLinks
                }
            }
        }

        foreach ($Domain in $DataSetForest.FoundDomains.Keys) {
            Tab -Name $Domain {
                Tab -Name 'Overview' {
                    Section -Name 'Domain Controllers / FSMO Roles' {
                        Panel {
                            Table -HideFooter -DataTable $DataSetForest.FoundDomains.$Domain.DomainControllers
                        }
                        Panel {
                            Table -HideFooter -DataTable $DataSetForest.FoundDomains.$Domain.DomainFSMO
                        }
                    }
                    Section -Name 'Password Policies' -Invisible {
                        Section -Name 'Default Password Policy' {
                            Table -HideFooter -DataTable $DataSetForest.FoundDomains.$Domain.DomainDefaultPasswordPolicy
                        }

                        Section -Name 'Domain Fine Grained Policies' {
                            Table -HideFooter -DataTable $DataSetForest.FoundDomains.$Domain.DomainFineGrainedPolicies
                        }
                    }
                    Section -Name 'Domain Well Known Folders' -Invisible {
                        Table -HideFooter -DataTable $DataSetForest.FoundDomains.$Domain.DomainWellKnownFolders
                    }
                }
                Tab -Name 'Organizational Units' {
                    Section -Name 'Organizational Units' {
                        Table -HideFooter -DataTable $DataSetForest.FoundDomains.$Domain.DomainOrganizationalUnits
                    }
                    Section -Name 'OU ACL Basic' {
                        Panel {
                            Table -HideFooter -DataTable $DataSetForest.FoundDomains.$Domain.DomainOrganizationalUnitsBasicACL
                        }
                    }
                    Section -Name 'OU ACL Extended' {
                        Panel {
                            Table -HideFooter -DataTable $DataSetForest.FoundDomains.$Domain.DomainOrganizationalUnitsExtended
                        }
                    }
                }
                Tab -Name 'Users' {
                    Section -Name 'Users' {
                        Panel {
                            Table -HideFooter -DataTable $DataSetForest.FoundDomains.$Domain.DomainUsers
                        }
                    }
                }
                Tab -Name 'Computers' {
                    Section -Name 'Computers' {
                        Panel {
                            Table -HideFooter -DataTable $DataSetForest.FoundDomains.$Domain.DomainComputers
                        }
                    }
                    <#
                    Section -Name 'Summary Bitlocker & Laps' {
                        Container {
                            Section -Invisible {
                                Panel {
                                    Table -DataTable $DataBitlockerLapsSummary -Filtering
                                }
                            }
                            Section -Invisible {
                                Panel {
                                    Chart {
                                        foreach ($_ in $Systems) {
                                            ChartPie -Name $_.Name -Value $_.Count
                                        }
                                    }
                                }
                                Panel {
                                    Chart {
                                        ChartPie -Name 'Encrypted' -Value $Encrypted[0].Count
                                        ChartPie -Name 'Not Encrypted' -Value $Encrypted[1].Count
                                    }
                                }
                            }
                        }
                    }
                    #>
                    Section -Name 'Bitlocker' {
                        Panel {
                            Table -HideFooter -DataTable $DataSetForest.FoundDomains.$Domain.DomainBitlocker
                        }
                    }
                    Section -Name 'LAPS' {
                        Panel {
                            Table -HideFooter -DataTable $DataSetForest.FoundDomains.$Domain.DomainLAPS
                        }
                    }
                }
                Tab -Name 'Groups' {
                    Section -Name 'Groups Priviliged' {
                        Panel {
                            Table -HideFooter -DataTable $DataSetForest.FoundDomains.$Domain.DomainGroupsPriviliged
                        }
                        Panel {
                            #Chart -DataTable $DataSetForest.FoundDomains.'ad.evotec.xyz'.DomainGroupsPriviliged -DataNames 'Group Name' -DataCategories $DataSetForest.FoundDomains.'ad.evotec.xyz'.DomainGroupsPriviliged.'Members Count' -DataValues 'Members Count'
                        }
                    }
                }
            }
        }
    }

}