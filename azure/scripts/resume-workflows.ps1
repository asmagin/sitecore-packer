[System.Management.Automation.Remoting.PSSessionConfigurationData]::IsServerManager = $true;
Import-Module PSWorkflow;
Get-Job -State Suspended | Resume-Job -Wait | Wait-Job;