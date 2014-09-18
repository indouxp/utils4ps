###############################################################################
# 
# Usage:
#   PS> jobs2shutdown.ps1 shutdown
#   PS> jobs2shutdown.ps1 defrag backup shutdown
# ex)
#   PS> jobs2shutdown.ps1 defrag shutdown
#   defrag 後、shutdown
#   PS> jobs2shutdown.ps1 backup shutdown
#   backup 後、shutdown
#   PS> jobs2shutdown.ps1 backup defrag
#   backupと、defragの並行実行
#   PS> jobs2shutdown.ps1 backup defrag shutdown
#   backupと、defragの並行実行後、shutdown
#
###############################################################################
[string]$MyPath = $MyInvocation.MyCommand.Path
[string]$MyName = $MyInvocation.MyCommand.Name
[string]$MyDir = Split-Path $MyPath
[string]$logPath = Join-Path "C:\Users\indou\Documents" ($MyName + ".log")
. (Join-Path $MyDir "cmn010.ps1")
[string]$semaphorePath = Join-Path "C:\" $MyName
###############################################################################
$ErrorActionPreference = "Stop"
trap {
	add2Log ("TRAP:" + $Error[0])
	add2Log ("InvocationInfo.Line:" + $Error[0].InvocationInfo.Line)
  add2Log ("InvocationInfo.PositionMessage:" + $Error[0].InvocationInfo.PositionMessage)
	break
}
###############################################################################
function main {
  param([array]$jobs)
  try {
    new-item $semaphorePath -type directory > $null
    add2Log "START"
    add2Log $jobs
    $waits = @{}  # hash
    foreach ($job in $jobs) {
      switch($job) {
        "backup" {
        }
        "defrag" {
          switch(hostname) {
            "cf-t9" {
              # /H  この操作を "通常" の優先度で実行します (既定では "低")。
              # /U  操作の進行状況を画面に表示します。
              # /V  断片化の統計情報を含む詳細を出力します。
              # /X  指定したボリュームの空き領域の統合を実行します。
              $arguments = "c: /v /h /x"
              $proc = Start-Process                 `
                          -FilePath "defrag"        `
                          -ArgumentList $arguments  `
                          -PassThru                 `
                          -RedirectStandardOutput defrag.c.stdout.txt `
                          -RedirectStandardError defrag.c.stderr.txt  `
                          -NoNewWindow
              add2Log "defrag c" + $proc
              $waits["defrag c"] = $proc
              $arguments = "d: /v /h /x"
              $proc = Start-Process                 `
                          -FilePath "defrag"        `
                          -ArgumentList $arguments  `
                          -PassThru                 `
                          -RedirectStandardOutput defrag.c.stdout.txt `
                          -RedirectStandardError defrag.c.stderr.txt  `
                          -NoNewWindow
              add2Log "defrag d" + $proc
              $waits["defrag d"] = $proc
            } # cf-t9
          } # switch
        } # defrag
      } # switch
    } # foreach 
    foreach($run in $waits.keys) {
      $id = $waits[$run].Id
      "wait.. $run"
      try {
        Wait-Process -Id $id
        "$run done"
      } catch [Exception] {
        "$run process not exist"
      } finally {
        add2Log ($run + " ExitCode:" + $waits[$run].ExitCode)
      }
    }
    foreach ($job in $jobs) {
      if ($job -eq "shutdown") {
        add2Log "shutdown"
        #Start-Process -FilePath "shutdown" -ArgumentList "/s /c $MyName"
      }
    }
    add2Log "SUCCESS"
  } catch [Exception] {
		add2Log ("CATCH:" + $Error[0])
		add2Log ("Exception:" + $Error[0].Exception)
		add2Log ("InvocationInfo.Line:" + $Error[0].InvocationInfo.Line)
    add2Log ("InvocationInfo.PositionMessage:" + $Error[0].InvocationInfo.PositionMessage)
    exit 1
  } finally {
    remove-item $semaphorePath
    add2Log "DONE"
  }
  exit 0
}
###############################################################################
function chkArgs {
  param([array]$jobs)
  foreach ($job in $jobs) {
    switch($job) {
      "shutdown" {}
      "backup" {}
      "defrag" {}
      default {
        $MyPath
        usage $MyPath
        throw "Unknown command $job"
      }
    }
  } 
}
###############################################################################
Set-PSDebug -strict
if ($args.length -ne 0) {
  chkArgs $args
	main $args
} else {
	usage $MyPath
}
