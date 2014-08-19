
###############################################################################
#
# usage PATH
# 	PATH:�R�}���h���b�g�̃p�X
# 	PATH�ŗ^����ꂽ�t�@�C����ǂݍ��݁A�ŏ��Ɍ�������^# Usage:$����A^#$�܂ł�Ԃ�
#
###############################################################################
function usage {
	param($path)
	$encoding = [Text.Encoding]::default 
	$fh = new-Object IO.StreamReader($path ,$encoding)
	while (($line = $fh.ReadLine()) -ne $null) {
		if ($line -match "^# Usage:") {
			$start = $true
		}
		if ($line -match "^#$" -and $start -eq $true) {
			$start = $false
			break
		}
		if ($start) {
			$line
		}	
	}
	$fh.close()
}

