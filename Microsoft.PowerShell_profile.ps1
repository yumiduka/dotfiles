﻿# 関数設定

## timeコマンドを指定回数実行して、回数・平均時間・最長時間・最短時間を表示
function Get-ScriptTime {
  param(
    [Parameter(Mandatory)][scriptblock]$Command,
    [int32]$Count = 10,
    [switch]$Table
  )

  $Time = (1..$Count) | % { (Measure-Command -Expression $Command).TotalMilliseconds } | measure -Average -Maximum -Minimum | select Count,Average,Maximum,Minimum,@{n='Script';e={$Command}}
  if ( $Table ) { return $Time | ft -AutoSize }

  return $Time
}

## UserCSSでフォント設定を上書きするための設定をクリップボードとファイルに取得
function Get-FontFamily {
  param(
    [string]$Path = '~/Downloads/style.css',
    [string]$FontFile = '~/.fontlist',
    [string]$Encoding = 'utf8',
    [string]$FontName = '恵梨沙フォント+Osaka－等幅'
  )

  if ( $psISE ) { psEdit $FontFile }

  (gc $Path -Encoding $Encoding).Split(';').Split('}').Split('{') | ? { $_ -match "font-family" } | % { ($_ -replace 'font-family:').Split(',') -replace "'" -replace '"' -replace '!important' -replace "`t" -replace '^ *' -replace ' *$' } | sort -Unique | Out-File $FontFile -Encoding $Encoding -Append
  $Fonts = (gc $FontFile -Encoding $Encoding | sort -Unique)
  $Fonts | % { '@font-face { src: local("' + $FontName + '"); font-family: "' + $_ + '"; }' } | scb
  $Fonts | Out-File $FontFile -Encoding $Encoding
}

## 指定した二つのファイルのうち、古いものを新しいもので上書きする
function Bakup-Item {
  param(
    [Parameter(Mandatory)][string]$Base,
    [Parameter(Mandatory)][string]$Target
  )

  if ( (Test-Path $Base) -and (! (Test-Path $Target)) ) {
    cp -Path $Base -Destination $Target
  } elseif ( (! (Test-Path $Base)) -and (Test-Path $Target) ) {
    cp -Path $Target -Destination $Base
  }

  $ErrorActionPreference = 'Stop'

  ($Base, $Target) | % {
    [System.IO.FileSystemInfo[]]$Files += (ls $_)
  }

  if ( $Files[0].LastWriteTime -gt $Files[1].LastAccessTime ) {
    cp -Path $Files[0] -Destination $Files[1]
  } elseif ( $Files[0].LastWriteTime -lt $Files[1].LastAccessTime ) {
    cp -Path $Files[1] -Destination $Files[0]
  }
}

## PC稼働時間を取得する(一日の中で一番最初と一番最後にイベントログが書かれた時間を見るため、日をまたぐ稼働時間は取得できない)
function Get-WorkTime {
  param(
    [datetime]$Today = (Get-Date),
    [datetime]$TargetDay = ($Today.AddDays(-8))
  )

  $EventLogs = Get-EventLog -LogName System -After $TargetDay.Date -Before $Today

  while ( $Today.Date -gt $TargetDay.Date ) {
    $StartWork,$EndWork = $EventLogs | ? { $_.TimeGenerated.Date -eq $TargetDay.Date } | sort TimeGenerated | select TimeGenerated -First 1 -Last 1
    $TargetDay | select @{n='Date';e={$_.Date.ToString('yyyy/MM/dd')}},@{n='Start';e={$StartWork.TimeGenerated.TImeOfDay}},@{n='End';e={$EndWork.TimeGenerated.TimeOfDay}}
    $TargetDay = $TargetDay.AddDays(1)
  }
}

## Jsonファイルを読み込む
function Import-Json {
  param(
    [string]$Path,
    [string]$Encoding = 'utf8'
  )

  $ErrorActionPreference = 'Stop'

  gc $Path -Encoding $Encoding | ConvertFrom-Json
}

# 変数設定

if ( ! (gv DefaultVariable -ErrorAction SilentlyContinue) ) {
  (
    @{ Name = 'DefaultVariable'; Value = (gv | select Name,Value); Scope = 'Global' },
    @{ Name = 'ProgramFiles'; Value = ('C:\Tools', $env:ProgramFiles, ${env:ProgramFiles(x86)}); Scope = 'Global' },
    @{ Name = 'ProfileRoot'; Value = $PSScriptRoot; Scope = 'Global' },
    @{ Name = 'WorkplaceProfile'; Value = (Join-Path $PSScriptRoot 'WorkplaceProfile.ps1'); Scope = 'Global' },
    @{ Name = 'DefaultFont'; Value = '恵梨沙フォント+Osaka－等幅'; Scope = 'Global' },
    @{ Name = 'GitPath'; Value = '~/Git'; Scope = 'Global' }
  ) | % { sv @_ }
}

# Path追加

(
  (Split-Path $profile), # Profile
  (ls $ProgramFiles '*vim*' -Directory -ErrorAction SilentlyContinue | ls -Filter 'vim.exe').DirectoryName, # vim
  (ls 'C:\Windows\Microsoft.NET\Framework64' -Directory -ErrorAction SilentlyContinue | ls -Filter 'csc.exe' | sort VersionInfo)[-1].DirectoryName # .NET Framework
) | % { if ( $env:Path.Split(';') -notcontains $_ ) { $env:Path += (';' + $_) } }

# LOCAL MACHINEとCURRENT USER以外のレジストリをマウント

(
  @{ Name = 'HKCR'; PSProvider = 'Registry'; Root = 'HKEY_CLASSES_ROOT' },
  @{ Name = 'HKU';  PSProvider = 'Registry'; Root = 'HKEY_USERS' },
  @{ Name = 'HKCC'; PSProvider = 'Registry'; Root = 'HKEY_CURRENT_CONFIG' }
) | % {
  if ( Get-PSDrive $_.Name -ErrorAction SilentlyContinue ) {
    Write-Host ('ドライブレター "' + $_.Name + '" は既に使われていました。')
    return
  }
  New-PSDrive @_ > $null
}

# CapsLock -> LeftCtrl (初期設定に移行予定)

#$RegValue = @()
#('00','00','00','00','00','00','00','00','02','00','00','00','1d','00','3a','00','00','00','00','00') | % { [Byte]('0x' + $_) }
# sp -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Keyboard Layout' -Name 'Scancode Map' -Value $RegValue

# エクスプローラーの3Dオブジェクト削除 (初期設定に移行予定)

ri 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}' -ErrorAction SilentlyContinue

# プロンプト設定

function prompt {
  Write-Host ''
  Write-Host ('[' + (Get-Date).ToString('yyyy/MM/dd hh:mm:ss') + ']') -ForegroundColor Yellow -NoNewline
  Write-Host (' ' + $Pwd.Path) -ForegroundColor Cyan
  if ( [Security.Principal.WindowsIdentity]::GetCurrent().Owner -eq 'S-1-5-32-544' ) { '# ' } else { '> ' }
}

# 環境別プロファイルを読み込み(場所により異なる設定が必要な場合に使用)

if ( Test-Path $WorkplaceProfile -ErrorAction SilentlyContinue ) {
  . $WorkplaceProfile
}
