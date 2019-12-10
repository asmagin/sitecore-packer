Workflow PackerSetup {
  param(
    [Parameter(Mandatory = $True, Position = 1)]
    [string] $cwd
  )
  
  InlineScript {
    & "$using:cwd\1-Step.ps1" $using:cwd;
  };
  
  Restart-Computer -Wait;
  
  InlineScript {
    & "$using:cwd\2-Step.ps1" $using:cwd;
  };
  
  Unregister-ScheduledTask -TaskName "PackerSetup_Resume" -Confirm:$false;
}
  
Register-ScheduledTask `
  -TaskName "PackerSetup_Resume" `
  -Trigger (New-ScheduledTaskTrigger -AtStartup) `
  -Action (New-ScheduledTaskAction -Execute "$PSScriptRoot\resume-workflows.cmd" -Argument "$PSScriptRoot") `
  -RunLevel Highest `
  -User "PackerVM\packer" `
  -Password "Engine123";
  
PackerSetup -cwd $PSScriptRoot -AsJob -JobName PackerSetup_Job -PSPersist:$True | Wait-Job;