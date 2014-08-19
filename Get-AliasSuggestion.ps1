###############################################################################
# Windows Power Shell クックブック P.37
#
# Usage:
#   PS> Get-AliasSuggestion コマンド
# ex)
#   PS> Get-AliasSuggestion Remove-ItemProperty
#   Suggestion: An alias for Remove-ItemProperty is rp
#
###############################################################################

# 共通ライブラリの読み込み
. (Join-Path (Split-Path $MyInvocation.MyCommand.Path) "cmn010.ps1")

###############################################################################
#
# 主処理
#
###############################################################################
function main {
	param($LastCommand)

	$helpMatches = @()	# 空の配列を作成

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
