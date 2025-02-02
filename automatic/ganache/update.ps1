﻿Import-Module AU

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$releases = 'https://github.com/trufflesuite/ganache-ui/releases'

function global:au_BeforeUpdate() {
  Get-RemoteFiles -Purge -FileNameBase 'ganache'
  $Latest.Checksum = Get-RemoteChecksum $Latest.URL -Algorithm 'sha256'
}
function global:au_SearchReplace {
  @{
    ".\tools\chocolateyInstall.ps1" = @{
      "(?i)(^\s*url64bit\s*=\s*)('.*')"      = "`$1`'$($Latest.URL)`'"
      "(?i)(^\s*checksum64\s*=\s*)('.*')" = "`$1`'$($Latest.Checksum)`'"
    }
  }
}
function global:au_GetLatest {
  $download_page = Invoke-WebRequest -Uri $releases -UseBasicParsing
  $regex = '.exe$'
  $url = $download_page.links | Where-Object {($_.href -match $regex) -and -Not ($_.href -match 'beta')} | Select-Object -First 1 -ExpandProperty href
  $url = "https://github.com$url"
  $arr = $url -split '-|.exe'
  $version = $arr[2]
  return @{ Version = $version; URL = $url }
}

update -ChecksumFor none
