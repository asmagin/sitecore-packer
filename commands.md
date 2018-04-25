cls; Remove-Item -Path .\build\w16s-solr\ -Recurse -Force; & .\ci.ps1 build w16s-solr-virtualbox-core --recursive=true

.\ci.ps1 build w16s-virtualbox-core --recursive=true
.\ci.ps1 build w16s-dotnet-virtualbox-core --recursive=true
.\ci.ps1 build w16s-iis-virtualbox-core --recursive=true
.\ci.ps1 build w16s-solr-virtualbox-core --recursive=true
.\ci.ps1 build w16s-sc90-virtualbox-core --recursive=true
dir

---

.\ci.ps1 rebuild w16s-solr-virtualbox-core
.\ci.ps1 rebuild w16s-sc90-virtualbox-core
