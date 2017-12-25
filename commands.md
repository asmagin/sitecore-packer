cls; Remove-Item -Path .\build\w16s-scsolr\ -Recurse -Force; & .\ci.ps1 build w16s-scsolr-virtualbox-core --recursive=true


.\ci.ps1 build w16s-virtualbox-core --recursive=true
.\ci.ps1 build w16s-dotnet-virtualbox-core --recursive=true
.\ci.ps1 build w16s-iis-virtualbox-core --recursive=true
.\ci.ps1 build w16s-scsql17d-virtualbox-core --recursive=true
.\ci.ps1 build w16s-scsolr-virtualbox-core --recursive=true
.\ci.ps1 build w16s-scpre-virtualbox-core --recursive=true
.\ci.ps1 build w16s-sc90-virtualbox-core --recursive=true
dir