$destPath = (Get-Content "$PSScriptRoot\provision_vm.json" | Out-String | ConvertFrom-Json).DestenationPath
$File_list = Get-ChildItem $PSScriptRoot | select $_.Name
if(!(Test-Path $destPath -Verbose)){
    Write-Host "Creating the destination folder..." -Verbose
    New-Item -ItemType directory -Path $destPath -Force -Verbose
}
foreach ($file in $File_list) {
    Copy-Item "$PSScriptRoot\$file" -Destination $destPath -Force -Verbose
}