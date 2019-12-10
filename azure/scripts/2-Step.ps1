param(
  [Parameter(Mandatory = $True, Position = 1)]
  [string] $cwd
)


function Set-DHCP {
  Import-Module DHCPServer;
  Add-DhcpServerv4Scope -name "PackerNet" -StartRange 192.168.0.100 -EndRange 192.168.0.200 -SubnetMask 255.255.255.0 -State Active;
  Set-DhcpServerv4OptionValue -Router 192.168.0.1 -ScopeID 192.168.0.0 -DnsServer 8.8.8.8 ;
 
  Restart-Service -Name DHCPServer 
  Write-Host "DHCP configured." -ForegroundColor Green;
}

function Install-Chocolatey {
  Set-ExecutionPolicy Unrestricted -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'));

  $env:ChocolateyInstall = Convert-Path "$((Get-Command choco).path)\..\..";
  Import-Module "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1";

  refreshenv;

  choco feature enable -n=allowGlobalConfirmation;

  Write-Host "Chocolatey installed." -ForegroundColor Green;
}

function Install-DevSoft { 
  choco install gitkraken;
  choco install dotnetcore-sdk;
  choco install vscode;
  choco install vboxguestadditions.install
  Add-Content -Path $Profile.CurrentUserAllHosts -Value '$env:Path += ";C:\Program Files\Microsoft VS Code\bin"'
  
  refreshenv;

  #code --install-extension robertohuertasm.vscode-icons;
  code --install-extension ms-vscode.csharp;
  code --install-extension ms-vscode.powershell;
  code --install-extension cake-build.cake-vscode;
  code --install-extension rebornix.ruby;
 # code --install-extension pendrica.chef;
  code --install-extension bbenoist.vagrant;

  Write-Host "Development software installed." -ForegroundColor Green;
}

function Install-PackerSoft { 
  choco install git.install;
  choco install chefdk;
  choco install packer;

  refreshenv;

  Write-Host "Packer software installed." -ForegroundColor Green;
}

function Install-GeneralSoft { 
  choco install 7zip.install;
  choco install totalcommander;
  choco install notepadplusplus.install;
  choco install googlechrome;
  choco install virtualbox;
 
  $VBoxManage = "C:\Program Files\Oracle\VirtualBox"
  [Environment]::SetEnvironmentVariable("VBOX_MSI_INSTALL_PATH", "$VBoxManage", "Machine")
  refreshenv;

  Write-Host "General software installed." -ForegroundColor Green;
}

function Initialize-Storage {
  Initialize-Disk -Number 2 -PartitionStyle GPT;
  New-Partition -DiskNumber 2 -DriveLetter P -UseMaximumSize;
  Format-Volume -DriveLetter P -FileSystem exFAT -Confirm:$false -Force;
    
  Write-Host "Storage configured." -ForegroundColor Green;
}

  function Set-SitecorePacker {
  $repoPath = "P:\sitecore-packer";
  $packerCachePath = "P:\packer-cache";
  
  New-Item -ItemType Directory -Force -Path $packerCachePath;
  [Environment]::SetEnvironmentVariable("PACKER_CACHE_DIR", $packerCachePath, "Machine");
	
  New-Item -ItemType Directory -Force -Path $repoPath;

  Get-SitecorePackerRepo -RepoPath $repoPath;

  #Copy-Item "$cwd\secret.rb" -Destination "$repoPath\src\components\sitecore\chef\cookbooks\scp_sitecore\attributes" -Recurse -force;
  #Copy-Item "$cwd\license.xml" -Destination "$repoPath\src\components\sitecore\chef\cookbooks\scp_sitecore\files" -Recurse -force;
  #Copy-Item "$cwd\2016_developer.rb" -Destination "$repoPath\src\components\sql\chef\cookbooks\scp_sql\attributes" -Recurse -force;
    
  Write-Host "Packer repository configured." -ForegroundColor Green;
}

function Get-SitecorePackerRepo($repoPath) {
  $repoURL = "https://github.com/asmagin/sitecore-packer.git";
  $gitpath="C:\Program Files\Git\cmd"
  git clone $repoURL $repoPath -q;
    
  Write-Host "Packer repository cloned." -ForegroundColor Green;
}

function Disable-UAC {
  Set-ItemProperty -Path REGISTRY::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System -Name ConsentPromptBehaviorAdmin -Value 0;
    
  Write-Host "UAC disabled." -ForegroundColor Green;
}

function Invoke-Step {
  Write-Host $cwd;

  Install-Chocolatey;
  Install-PackerSoft;
  Initialize-Storage;
  Set-SitecorePacker;
  
  Install-GeneralSoft;
  Install-DevSoft;
}

Start-Transcript -Path $cwd\log.log -Force -Append -NoClobber;
Try {
  Invoke-Step;
}
Catch {
  Write-Host $error[0].Exception;
}
Stop-Transcript;