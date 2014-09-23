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
    for ($i = 0; $i -lt $hosts.length; $i++) {
      $myHost = hostname
      if ($myHost -eq $hosts[$i]) {
        if ($commands[$i] -ne "shutdown" -and $commands[$i] -ne "noshutdown") {
          $command_name = Split-Path -Leaf ($commands[$i])
          $stdoutPath = Join-Path $logDir ($MyName + "." + $command_name + "." + $i + ".stdout.log")
          $stderrPath = Join-Path $logDir ($MyName + "." + $command_name + "." + $i + ".stderr.log")
          $p =                                    `
              Start-Process                       `
                      -FilePath $commands[$i]     `
                      -ArgumentList $options[$i]  `
                      -PassThru                   `
                      -RedirectStandardOutput $stdoutPath `
                      -RedirectStandardError $stderrPath  `
                      -NoNewWindow
          add2Log ("start " + $commands[$i] + "-" + $options[$i])
          add2Log ("  StartTime:" + $p.StartTime)
          add2Log ("  stdout:" + $stdoutPath)
          add2Log ("  stderr:" + $stderrPath)
          add2Log ("  pid:" + $p.id)
          $waits[($command_name + $i)] = $p
        }
      }
    }
    foreach($command_name in $waits.keys) {
      $id = $waits[$command_name].Id
      "wait.. $command_name"
      try {
        Wait-Process -Id $id
        "$command_name done"
        add2Log ($command_name + " ExitTime:" + $waits[$command_name].ExitTime)
      } catch [Exception] {
        "$command_name process not exist"
      } finally {
        add2Log ($command_name + " ExitCode:" + $waits[$command_name].ExitCode)
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
    exit 1
  } finally {
    remove-item $semaphorePath
    add2Log "DONE"
  }
  exit 0
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
Set-PSDebug -strict
if ($args.length -ne 0) {
  chkArgs $args
	main $args
} else {
	usage $MyPath
}
