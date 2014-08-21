$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

$expectFile = "d:\tmp\expect.txt"
$resultFile = "d:\tmp\result.txt"

function before {
	#param([string]$file)
	[string]$file = $args[0]
	[string]$case = $args[1]

	Remove-Item $file 2> $null
	New-Item $file -ItemType file > $null
	switch ($case) {
		1{
				$content = @"
#
#
#
# Usage:
#   PS > SCRIPT FILE [...]
#   FILE:入力ファイル
# ex)
#   PS > SCRIPT c:\tmp\test.txt
#
"@
			break}
		2 {
				$content = @"
#
#Usage:
#   PS > SCRIPT FILE [...]
#   FILE:入力ファイル
#ex)
#   PS > SCRIPT c:\tmp\test.txt
#
"@
			break}
		3 {
				$content = @"
#
# Usage:
#   PS > SCRIPT FILE [...]
#   FILE:入力ファイル
# ex)
#   PS > SCRIPT c:\tmp\test.txt
#          
"@
			break}
	}
	#Add-Content -Path $file -Value $content -Encoding String
	Add-Content -Path $file -Value $content -Encoding utf8
}
function after {
	remove-item $expectFile
	remove-item $resultFile
}

Describe "usage" {

	It "正常1 (# Usage:)" {
		$sample = "d:\tmp\test.ps1"
		before $sample 1

		$expect = @"
# Usage:
#   PS > SCRIPT FILE [...]
#   FILE:入力ファイル
# ex)
#   PS > SCRIPT c:\tmp\test.txt

"@
		$expect				| Out-File $expectFile; $expect = Get-Content $expectFile
		usage $sample | Out-File $resultFile; $result = Get-Content $resultFile
		$result | should be $expect

		after
	}
	It "正常2 (#Usage:)" {
		$sample = "d:\tmp\test.ps1"
		before $sample 2

		$expect = @"
#Usage:
#   PS > SCRIPT FILE [...]
#   FILE:入力ファイル
#ex)
#   PS > SCRIPT c:\tmp\test.txt

"@
		$expect				| Out-File $expectFile; $expect = Get-Content $expectFile
		usage $sample | Out-File $resultFile; $result = Get-Content $resultFile
		$result | should be $expect

#		after
	}
	It "正常3 (#空白\$)" {
		$sample = "d:\tmp\test.ps1"
		before $sample 3

		$expect = @"
# Usage:
#   PS > SCRIPT FILE [...]
#   FILE:入力ファイル
# ex)
#   PS > SCRIPT c:\tmp\test.txt

"@
		$expect				| Out-File $expectFile; $expect = Get-Content $expectFile
		usage $sample | Out-File $resultFile; $result = Get-Content $resultFile
		$result | should be $expect

		after
	}
}
