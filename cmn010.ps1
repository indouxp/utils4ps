###############################################################################
#
# usage PATH
# 	PATH:�R�}���h���b�g�̃p�X
# 	PATH�ŗ^����ꂽ�t�@�C����ǂݍ��݁A�ŏ��Ɍ�������^# *Usage:$����A^# *$�܂ł�Ԃ�
#
###############################################################################
function usage {
	param($path)
	$encoding = [Text.Encoding]::GetEncoding("Shift_JIS")
	$fh = new-Object System.IO.StreamReader($path, $encoding)
  $start = $false
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

###############################################################################
#
# add2Log MESSAGE
###############################################################################
function add2Log {
  Param([string]$msg = "")
  $now = get-date -uFormat "%Y/%m/%d %H:%M:%S"
  $now + ":" + "[" + $PID + "]" + " " + $msg |
    Out-File $logPath -encoding Default -append -ErrorAction Stop
}
