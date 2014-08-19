###############################################################################
# Windows Power Shell �N�b�N�u�b�N P.37
#
# Usage:
#   PS> Get-AliasSuggestion �R�}���h
# ex)
#   PS> Get-AliasSuggestion Remove-ItemProperty
#   Suggestion: An alias for Remove-ItemProperty is rp
#
###############################################################################

# ���ʃ��C�u�����̓ǂݍ���
. (Join-Path (Split-Path $MyInvocation.MyCommand.Path) "cmn010.ps1")

###############################################################################
#
# �又��
#
###############################################################################
function main {
	param($LastCommand)

	$helpMatches = @()	# ��̔z����쐬

	foreach($alias in Get-Alias) {
		if ($lastCommand -match("\b" +
			[System.Text.RegularExpressions.REgex]::Escape($alias.Definition) + "\b")) {
			$helpMatches +=
				"Suggestion: An alias for $($alias.Definition) is $($alias.Name)"
		}
	}

	$helpMatches
}

###############################################################################
if ($args.length -ne 0) {
	main $args
} else {
	usage $MyInvocation.MyCommand.Path
}
