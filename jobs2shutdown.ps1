###############################################################################
# 
# Usage:
#   PS> jobs2shutdown.ps1 shutdown
#   PS> jobs2shutdown.ps1 noshutdown
#
###############################################################################
[string]$MyPath = $MyInvocation.MyCommand.Path
[string]$MyName = $MyInvocation.MyCommand.Name
[string]$MyDir = Split-Path $MyPath
[string]$confPath = Join-Path $MyDir ($MyName -replace ".ps1", ".conf")
[string]$logDir = "C:\Users\indou\Documents"
[string]$logPath = Join-Path $logDir ($MyName + ".log")
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
  param([array]$shutdown)
  try {
    new-item $semaphorePath -type directory > $null
    add2Log "START"
    add2Log $shutdown
    $hosts = @()
    $commands = @()
    $options = @()
    $waits = @{}  # hash
    analyseConf $confPath ([ref]$hosts) ([ref]$commands) ([ref]$options)
    $psinfo = @()
    $ps = @()
    $j = 0
    for ($i = 0; $i -lt $hosts.length; $i++) {
      $hostname = hostname
      if ($hostname -eq $hosts[$i]) {
        $psinfo += New-Object System.Diagnostics.ProcessStartInfo
        $psinfo[$j].FileName = $commands[$i]
        $psinfo[$j].Arguments = $options[$i]
        $psinfo[$j].RedirectStandardError = $true
        $psinfo[$j].RedirectStandardOutput = $true
        $psinfo[$j].UseShellExecute = $false

        $ps += New-Object System.Diagnostics.Process
        $ps[$j].StartInfo = $psinfo[$j]
        $ps[$j].Start() | Out-Null
        add2Log ("start:" + $commands[$i] + " " + $options[$i] + " pid:" + $ps[$j].pid)
        $j++
      }
    }
    $j = 0
    for ($i = 0; $i -lt $hosts.length; $i++) {
      $hostname = hostname
      if ($hostname -eq $hosts[$i]) {
        $msg = ""
        $msg = ("wait " + $commands[$i] + " " + $options[$i])
        $msg
        add2Log $msg

        $ps[$j].WaitForExit()

        $msg = ""
        $msg += ($ps[$j].StartTime.toString("yyyy/MM/dd HH:mm:ss"))
        $msg += "-"
        $msg += ($ps[$j].ExitTime.toString("yyyy/MM/dd HH:mm:ss"))
        $msg += (" status was " + $ps[$j].ExitCode)
        $msg
        add2Log $msg

        $command_name = Split-Path -Leaf ($commands[$i])
        $stdoutPath = Join-Path $logDir ($MyName + "." + $command_name + "." + $j + ".stdout.log")
        $stderrPath = Join-Path $logDir ($MyName + "." + $command_name + "." + $j + ".stderr.log")
        $out = $ps[$j].StandardOutput.ReadtoEnd()
        $out | Out-File $stdoutPath
        $err = $ps[$j].StandardError.ReadtoEnd()
        $err | Out-File $stderrPath

        $j++
      }
    }
    foreach ($job in $shutdown) {
      if ($job -eq "shutdown") {
        Start-Process -FilePath "shutdown" -ArgumentList "/s /c $MyName"
        add2Log "shutdown"
      }
    }
    add2Log "SUCCESS"
  } catch [Exception] {
    add2Log ("CATCH:" + $Error[0])
    add2Log ("Exception:" + $Error[0].Exception)
    add2Log ("InvocationInfo.Line:" + $Error[0].InvocationInfo.Line)
    add2Log ("InvocationInfo.PositionMessage:" + $Error[0].InvocationInfo.PositionMessage)
    return 1
  } finally {
    remove-item $semaphorePath
    add2Log "DONE"
  }
  return 0
}
###############################################################################
# �����̃`�F�b�N
###############################################################################
function chkArgs {
  param([array]$shutdown)
  foreach ($job in $shutdown) {
    switch($job) {
      "noshutdown" {}
      "shutdown" {}
      default {
        $MyPath
        usage $MyPath
        throw "Unknown command $job"
      }
    }
  } 
}
###############################################################################
# $confPath��ǂݍ��݁A���t�B�[���h���z�X�g���A���t�B�[���h���R�}���h�A
# ��O�t�B�[���h���R�}���h�̃I�v�V�����Ƃ��Ď擾�B
# ���ꂼ���z��ւ̎Q�Ƃɑ�����Ė߂�
###############################################################################
function analyseConf {
  param([string]$confPath, [ref]$hosts, [ref]$commands, [ref]$options)

  $conf = (Get-Content $confPath) -as [string[]]

  $index_no = 0
  foreach ($line in $conf) {
    $fields = $line.split(",") # ,��split
    $comment = $false
    $option = ""
    $col_count = 0
    foreach ($field in $fields) {
      if ($col_count -eq 0 -and $field -match "^#") { # ���t�B�[���h��^#�Ƀ}�b�`����
        $comment = $true
        break
      }
      switch ($col_count) {
        0 { $hosts.value += $field }          # ���t�B�[���h
        1 { $commands.value += $field }       # ���t�B�[���h
        default { $option += ($field + " ") } # ��O�t�B�[���h�ȍ~
      }
      $col_count++
    }
    if ($comment -ne $true) {
      $options.value += $option               # ��O�t�B�[���h�ȍ~
      $index_no++  
    }
  }
}

###############################################################################
set-psdebug -strict # �ϐ��������̋���
if ($args.length -ne 0) {
  chkArgs $args
  $rc = main $args
} else {
  usage $MyPath
  $rc = 1
}
set-psdebug -off  # �ϐ��������̋���OFF
exit $rc
