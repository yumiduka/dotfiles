# �t�H���g�E�c�[���o�[�ݒ�

$psISE.Options.SelectedScriptPaneState = "Top"
$psISE.Options.Fontsize = if ( & $Global:IsUHD ) { 9 } else { 6 }
$psISE.Options.FontName = $DefaultFont
$psISE.Options.ShowToolBar = $false

# scratch�ƃv���t�@�C����ISE�ŊJ��

psEdit ((Join-Path $ProfileRoot 'scratch.ps1'), $PROFILE.CurrentUserAllHosts, $PROFILE, $WorkplaceProfile, $WorkplaceFiles) -ErrorAction SilentlyContinue
