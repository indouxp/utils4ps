###############################################################################
# Windows Power Shell �N�b�N�u�b�N P.28
#
# Usage:
#   PS > Search-Help COMMAND
# ex)
#   PS > Search-Help hashtable
#   PS > Search-Help "(datetime|ticks)"
#
###############################################################################
#param($pattern = $(throw "Please specify content to search for"))

# ���ʃ��C�u�����̓ǂݍ���
. (Join-Path (Split-Path $MyInvocation.MyCommand.Path) "cmn010.ps1")

###############################################################################
#
# �又��
#
###############################################################################
function main {
	param($pattern)

	$helpNames = $(Get-Help * | Where-Object { $_.Category -ne "Alias" })

	foreach($helpTopic in $helpNames) {
		$content = Get-Help -Full $helpTopic.Name | Out-String
		if ($content -match $pattern) {
			$helpTopic | Select-Object Name, Synopsis
		}
	}
	exit 0
}

###############################################################################
if ($args.length -ne 0) {
	main $args
} else {
	usage $MyInvocation.MyCommand.Path
}
