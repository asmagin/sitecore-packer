cls; Remove-Item -Path .\build\w16s-solr\ -Recurse -Force; & .\ci.ps1 build w16s-solr-virtualbox-core --recursive=true

.\ci.ps1 build w16s-virtualbox-core --recursive=true
.\ci.ps1 build w16s-dotnet-virtualbox-core --recursive=true
.\ci.ps1 build w16s-iis-virtualbox-core --recursive=true
.\ci.ps1 build w16s-solr-virtualbox-core --recursive=true
.\ci.ps1 build w16s-sc900-virtualbox-core --recursive=true
dir

---

.\ci.ps1 rebuild w16s-solr-virtualbox-core
.\ci.ps1 rebuild w16s-sc900-virtualbox-core



# certificates installation
$pass = (ConvertTo-SecureString -String "vagrant" -Force -AsPlainText)
Import-PfxCertificate -CertStoreLocation cert:/LocalMachine/Root -Password $pass -FilePath C:/certificates/SitecoreFundamentalsRoot.pfx
Import-PfxCertificate -CertStoreLocation cert:/LocalMachine/Root -Password $pass -FilePath C:/certificates/SitecoreRootCert.pfx

Import-PfxCertificate -CertStoreLocation cert:/LocalMachine/CA   -Password $pass -FilePath C:/certificates/SitecoreFundamentalsRoot.pfx
Import-PfxCertificate -CertStoreLocation cert:/LocalMachine/CA   -Password $pass -FilePath C:/certificates/SitecoreRootCert.pfx

Import-PfxCertificate -CertStoreLocation cert:/LocalMachine/My   -Password $pass -FilePath C:/certificates/SitecoreFundamentalsRoot.pfx
Import-PfxCertificate -CertStoreLocation cert:/LocalMachine/My   -Password $pass -FilePath C:/certificates/SitecoreRootCert.pfx
Import-PfxCertificate -CertStoreLocation cert:/LocalMachine/My   -Password $pass -FilePath C:/certificates/all.local.pfx
Import-PfxCertificate -CertStoreLocation cert:/LocalMachine/My   -Password $pass -FilePath C:/certificates/sc9.xconnect.pfx
Import-PfxCertificate -CertStoreLocation cert:/LocalMachine/My   -Password $pass -FilePath C:/certificates/all.sc9.local.pfx
Import-PfxCertificate -CertStoreLocation cert:/LocalMachine/My   -Password $pass -FilePath C:/certificates/sc9.commerce.pfx
Import-PfxCertificate -CertStoreLocation cert:/LocalMachine/My   -Password $pass -FilePath C:/certificates/sc9.local.pfx