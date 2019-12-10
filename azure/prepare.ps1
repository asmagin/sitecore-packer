
If ((Get-Module PowerShellGet).Version -eq [Version]::new(1, 0, 0, 1)) {
  Install-Module -Name PowerShellGet -Force;
  Remove-Item "$env:ProgramFiles\\WindowsPowerShell\\Modules\\PowerShellGet\\1.0.0.1" -Recurse -ErrorAction Ignore;
  Remove-Item "$env:ProgramFiles\\WindowsPowerShell\\Modules\\\PackageManagement\\1.0.0.1" -Recurse -ErrorAction Ignore;
}

Install-PackageProvider -Name NuGet -Scope AllUsers -Force;
Install-Module -Name AzureRM -Scope AllUsers -Force;