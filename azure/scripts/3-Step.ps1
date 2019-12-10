param(
  [Parameter(Mandatory = $True, Position = 1)]
  [string] $cwd,
  [string] $version,
  [string] $buildpath="P:\sitecore-packer"
  
)

function Build {
  $packerCachePath = "P:\packer-cache";
  [Environment]::SetEnvironmentVariable("PACKER_CACHE_DIR", "$packerCachePath", "Process");

  $VBoxManage = "C:\Program Files\Oracle\VirtualBox"
  [Environment]::SetEnvironmentVariable("VBOX_MSI_INSTALL_PATH", "$VBoxManage", "Process")

  $packerpath="C:\ProgramData\chocolatey\bin"
  [Environment]::SetEnvironmentVariable("Packer", "$packerpath", "Process")
  
  $env:Path="C:\windows\system32;C:\windows;C:\windows\System32\Wbem;C:\windows\System32\WindowsPowerShell\v1.0\;C:\ProgramData\chocolatey\bin;C:\Program Files\Git\cmd;C:\opscode\chef
  dk\bin\;C:\Program Files\dotnet\;C:\Program Files\Microsoft VS Code\bin;C:\Users\packer\AppData\Local\Microsoft\WindowsApps;C:\opscode\chefdk\bin;"

  Set-Location $buildpath
  Invoke-Expression "& .\ci.ps1 build  $version --recursive=true" | Out-File -FilePath "$cwd\$version.log" -Force -Append -NoClobber; 

}

function Invoke-Step {
  Build

}

Start-Transcript -Path $cwd\log.log -Force -Append -NoClobber;

Try {
  Invoke-Step 
  Write-Host $cwd;
}
Catch {
  Write-Host $error[0].Exception;
}
Stop-Transcript;