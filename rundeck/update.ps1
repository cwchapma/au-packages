import-module au
. $PSScriptRoot\..\_scripts\all.ps1

$releases = 'http://rundeck.org/downloads.html'

function global:au_SearchReplace {
   @{
        "$($Latest.PackageName).nuspec" = @{
            "(\<releaseNotes\>).*?(\</releaseNotes\>)" = "`${1}$($Latest.ReleaseNotes)`$2"
        }

        ".\legal\VERIFICATION.txt" = @{
            "(?i)(\s+x32:).*"     = "`${1} $($Latest.URL32)"
            "(?i)(checksum32:).*" = "`${1} $($Latest.Checksum32)"
        }
    }
}

function global:au_BeforeUpdate { Get-RemoteFiles -Purge -NoSuffix }
function global:au_AfterUpdate  { Set-DescriptionFromReadme -SkipFirst 2 }

function global:au_GetLatest {
    $download_page = Invoke-WebRequest -Uri $releases -UseBasicParsing

    $re    = '\.jar$'
    $url   =  $download_page.links | ? href -match $re | % href | select -First 1

    $release_notes = $download_page.links | ? class -eq 'rd_releasenotes' | select -First 1 | % href
    $version  = $release_notes -split '/' | select -Last 1 -skip 1

    @{
        Version = $version -replace 'v'
        URL32   = $url
        ReleaseNotes = $release_notes
    }
}

update -ChecksumFor none
