param(
  [Parameter(Mandatory = $True, Position = 1)]
  [string] $cwd
)

function Update-PowerShellGet {
  If ((Get-Module PowerShellGet).Version -eq [Version]::new(1, 0, 0, 1)) {
    Install-Module -Name PowerShellGet -Force;
    Remove-Item "$env:ProgramFiles\\WindowsPowerShell\\Modules\\PowerShellGet\\1.0.0.1" -Recurse -ErrorAction Ignore;
    Remove-Item "$env:ProgramFiles\\WindowsPowerShell\\Modules\\\PackageManagement\\1.0.0.1" -Recurse -ErrorAction Ignore;
  } 
}


function Invoke-Step {
  Write-Host $cwd;
  Update-PowerShellGet
}

Start-Transcript -Path $cwd\log.log -Force -Append -NoClobber;
Try {
  Invoke-Step;
}
Catch {
  Write-Host $error[0].Exception;
}
Stop-Transcript;