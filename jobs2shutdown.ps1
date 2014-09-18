###############################################################################
# 
# Usage:
#   PS> jobs2shutdown.ps1 shutdown
#   PS> jobs2shutdown.ps1 defrag backup shutdown
# ex)
#   PS> jobs2shutdown.ps1 defrag shutdown
#   defrag ��Ashutdown
#   PS> jobs2shutdown.ps1 backup shutdown
#   backup ��Ashutdown
#   PS> jobs2shutdown.ps1 backup defrag
#   backup�ƁAdefrag�̕��s���s
#   PS> jobs2shutdown.ps1 backup defrag shutdown
#   backup�ƁAdefrag�̕��s���s��Ashutdown
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
              # /H  ���̑���� "�ʏ�" �̗D��x�Ŏ��s���܂� (����ł� "��")�B
              # /U  ����̐i�s�󋵂���ʂɕ\�����܂��B
              # /V  �f�Љ��̓��v�����܂ޏڍׂ��o�͂��܂��B
              # /X  �w�肵���{�����[���̋󂫗̈�̓��������s���܂��B
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
