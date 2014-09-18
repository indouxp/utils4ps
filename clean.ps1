param($dirPath = ".")

$tmpPath = "d:\tmp\"

$files = gci $dirPath -recurse | where { $_.Name -match "~$" }

foreach ($file in $files) {
  $file.FullName
  move-item -path $file.FullName -destination $tmpPath -force
}
