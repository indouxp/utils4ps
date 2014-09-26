param($dirPath = ".")

switch (hostname) {
  "vipi7920p6t" { $tmpPath = "~\tmp\"  }
  "cf-t9"       { $tmpPath = "d:\tmp\" }
  default       { throw hostname       }
}

$files = gci $dirPath -recurse | where { $_.Name -match "~$" }

foreach ($file in $files) {
  $file.FullName
  move-item -path $file.FullName -destination $tmpPath -force
}
