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
link -Path '~\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1' -Value (Join-Path $PSScriptRoot 'profile.ps1'
link -Path '~\Documents\WindowsPowerShell\Microsoft.PowerShellISE_profile.ps1' -Value (Join-Path $PSScriptRoot 'profile.ps1'
