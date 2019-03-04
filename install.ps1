# 変数

$ProfileRoot = (Split-Path $Profile)

# Profile用ディレクトリ作成

if ( ! (Test-Path $ProfileRoot) ) {
  mkdir $ProfileRoot -Force
}

# シンボリックリンク作成

function link {
  param(
    [string]$Path,
    [string]$Value
  )

  if ( Test-Path $Path ) {
    return $true
  }
  
  ni -ItemType SymbolicLink -Path $Path -Value $Value
}

link -Path '~\.fontlist' -Value (Join-Path $PSScriptRoot '.fontlist')
link -Path '~\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1' -Value (Join-Path $PSScriptRoot 'profile.ps1')
link -Path '~\Documents\WindowsPowerShell\Microsoft.PowerShellISE_profile.ps1' -Value (Join-Path $PSScriptRoot 'profile.ps1')

# エクスプローラーの3Dオブジェクト削除

ri 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}' -ErrorAction SilentlyContinue

# CapsLock -> LeftCtrl

[byte[]]$RegValue = @()
('00','00','00','00','00','00','00','00','02','00','00','00','1d','00','3a','00','00','00','00','00') | % { $RegValue += [Byte]('0x' + $_) }
sp -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Keyboard Layout' -Name 'Scancode Map' -Value $RegValue

# PackageProvider追加

(
  @{ Name = 'Chocolatey'; Force = $true }
) | % {
  if ( ! (Get-PackageProvider @_ -ErrorAction SilentlyContinue) ) { 
    Install-PackageProvider @_
  }
}

# アプリ追加

(
  @{ Name = 'Git'; ProviderName = 'Chocolatey'; Force = $true },
  @{ Name = 'GoogleJapaneseInput'; ProviderName = 'Chocolatey'; Force = $true },
  @{ Name = '7zip'; ProviderName = 'Chocolatey'; Force = $true },
  @{ Name = 'Steam'; ProviderName = 'Chocolatey'; Force = $true },
  @{ Name = 'mpc-hc'; ProviderName = 'Chocolatey'; Force = $true }
) | % {
  if ( ! (Get-Package @_ -ErrorAction SilentlyContinue) ) {
    Install-Package @_
  }
}
