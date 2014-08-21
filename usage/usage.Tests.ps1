$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

function before {
	param([string]$file)
	Remove-Item $file 2> $null
	New-Item $file -ItemType file > $null
	$content = @"
#
#
#
# Usage:
#   PS > SCRIPT FILE [...]
#   FILE:���̓t�@�C��
# ex)
#   PS > SCRIPT c:\tmp\test.txt
#
"@
	#Add-Content -Path $file -Value $content -Encoding String
	Add-Content -Path $file -Value $content -Encoding utf8
}

Describe "usage" {

	It "����" {
		$sample="d:\tmp\test.ps1"
		before $sample
		Write-Host (usage $sample)
		$expect =
		"# Usage:\n#   PS > SCRIPT FILE [...]\n#   FILE:���̓t�@�C��\n# ex)\n#   PS > SCRIPT c:\tmp\test.txt\n"
		usage $sample | should be $expect
	}
}
