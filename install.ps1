# 変数

$ProfileRoot = (Split-Path $Profile)

# Profile用ディレクトリ作成

if ( ! (Test-Path $ProfileRoot) ) { mkdir $ProfileRoot -Force }

# シンボリックリンク作成

(
  '~\.fontlist',
  '~\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1',
  '~\Documents\WindowsPowerShell\Microsoft.PowerShellISE_profile.ps1'
) | % {
  if ( ! (Test-Path $_) ) { ni -ItemType SymbolicLink -Path $_ -Value (Join-Path $PSScriptRoot (Split-Path -Leaf $_)) }
}
