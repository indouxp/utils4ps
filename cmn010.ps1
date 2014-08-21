###############################################################################
#
# usage PATH
# 	PATH:コマンドレットのパス
# 	PATHで与えられたファイルを読み込み、最初に見つかった^# *Usage:$から、^# *$までを返す
#
###############################################################################
function usage {
	param($path)
	$encoding = [Text.Encoding]::GetEncoding("Shift_JIS")
	$fh = new-Object System.IO.StreamReader($path, $encoding)
	while (($line = $fh.ReadLine()) -ne $null) {
		if ($line -match "^# *Usage:") {
			$start = $true
		}
		if ($line -match "^# *$" -and $start -eq $true) {
			$start = $false
			break
		}
		if ($start) {
			#$result += "$line`r`n"
			$line
		}	
	}
	$fh.close()
}

