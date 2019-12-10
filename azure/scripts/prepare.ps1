Set-ExecutionPolicy Unrestricted -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'));

$env:ChocolateyInstall = Convert-Path "$((Get-Command choco).path)\..\..";
Import-Module "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1";

refreshenv;

choco feature enable -n=allowGlobalConfirmation;

Write-Host "Installing Chef Client"
choco install chef-client -y --version 13.4.24

Write-Host "Installing 7zip"
choco install 7zip.portable -y

Write-Host "Extracting cookbooks"
7z x C:\packer-chef\cookbooks.tar.gz -o"C:\packer-chef" -aoa
7z x C:\packer-chef\cookbooks.tar -o"C:\packer-chef" -aoa
