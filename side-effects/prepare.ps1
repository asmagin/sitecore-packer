Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

mkdir C:\packer-chef -ErrorAction Continue
mkdir C:\tmp -ErrorAction Continue
mkdir C:\tmp\packer-chef-solo -ErrorAction Continue
mkdir C:\tmp\packer-chef-solo\cache -ErrorAction Continue

Write-Host "Installing Chef Client"
# We might want to bump it later. Testing required
choco install chef-client -y --version 13.4.24 #--version 15.0.300 --force
[Environment]::SetEnvironmentVariable("CHEF_LICENSE", "accept-silent", "Machine")

Write-Host "Installing 7zip"
choco install 7zip.portable -y

Write-Host "Extracting cookbooks"
7z x C:\packer-chef\cookbooks.tar.gz -o"C:\packer-chef" -aoa
7z x C:\packer-chef\cookbooks.tar -o"C:\packer-chef" -aoa
