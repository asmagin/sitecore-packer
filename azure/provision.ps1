<#
    .Synopsis
    .Description
    .Example
    .Example
    .Notes
    .Link
#>
[CmdletBinding()]
Param (
  [Parameter(Mandatory = $true)]
  [ValidateNotNullOrEmpty()]
  [string] $SubscriptionId,
  [string] $version="w16s-iis"
 
)

function CreateResourceGroup($depConfig) {
  return New-AzureRmResourceGroup -Name $depConfig.ResourceGroupName -Location $depConfig.Location -Force;
}

function CreateStorageContext($stConfig, $rg) {
  $staGuid = [guid]::NewGuid().ToString("N").Substring(0, 8);
  Write-Host $staGuid;
  $sProps = @{
    Name              = "${staGuid}configs";
    SkuName           = $stConfig.SkuName;
    Location          = $rg.Location;
    ResourceGroupName = $rg.ResourceGroupName;
  }

  $stAccount = New-AzureRmStorageAccount @sProps;
  $stkey = Get-AzureRmStorageAccountKey -ResourceGroupName $rg.ResourceGroupName  -Name $sProps.Name;
  $stContext = New-AzureStorageContext -StorageAccountName $sProps.Name -StorageAccountKey $stkey[0].Value -Protocol Https;

  return $stContext;
}

function DeployConfigurationScriptAndFiles($stConfig, $rg, $root, $files) {
  $cName = $stConfig.ContainerName;
  $stContext = CreateStorageContext $stConfig $rg;
  $container = New-AzureStorageContainer -Name $cName -Permission Blob -Context $stContext;
  
  $scriptUris = @();
  Foreach ($file in $files) {
    $scriptUris += (Set-AzureStorageBlobContent -Container $cName -File "$root\$($file)" -Context $stContext).ICloudBlob.Uri.AbsoluteUri;
  }

  return $scriptUris;
}

function DeployVirtualMachine($depConfig, $rg, $configScriptUris, $templateFile) {
  $deploymentConfig = @{
    Name                    = $depConfig.DeploymentName;
    ResourceGroupName       = $rg.ResourceGroupName;
    Mode                    = 'Complete';
    TemplateFile            = $templateFile;
    TemplateParameterObject = @{
      adminUsername    = $depConfig.AdminName;
      adminPassword    = $depConfig.AdminPass;
      dnsLabelPrefix   = $depConfig.DnsPrefix;
      configScriptUris = $configScriptUris;
    };
    Force                   = $true
  }

  New-AzureRmResourceGroupDeployment @deploymentConfig;
}

function Run($root) {
  $cwd = (Get-Content "${root}\scripts\provision_vm.json" | Out-String | ConvertFrom-Json).DestenationPath
  $config = Get-Content "${root}\provision_config.json" | Out-String | ConvertFrom-Json;
  $depConfig = $config.Deployment;
  $rg = CreateResourceGroup $depConfig;
  $configScriptUris = DeployConfigurationScriptAndFiles $config.Storage $rg $root $depConfig.Files ;
  DeployVirtualMachine $config.Deployment $rg $configScriptUris "$root\$($depConfig.TemplateFile)";
  
  $config_azure = Get-Content "$PSScriptRoot\azure_deploy.json" | Out-String | ConvertFrom-Json;
  $rgName = $config.Deployment.ResourceGroupName
  $rgvmName = $config_azure.variables.vmName
  Invoke-AzureRmVMRunCommand -ResourceGroupName $rgName  -Name $rgvmName -CommandId 'RunPowerShellScript' -ScriptPath '.\scripts\1-Step.ps1' -Parameter @{"cwd"=$cwd}
  Invoke-AzureRmVMRunCommand -ResourceGroupName $rgName  -Name $rgvmName -CommandId 'RunPowerShellScript' -ScriptPath '.\scripts\2-Step.ps1' -Parameter @{"cwd"=$cwd}
  Invoke-AzureRmVMRunCommand -ResourceGroupName $rgName  -Name $rgvmName -CommandId 'RunPowerShellScript' -ScriptPath '.\scripts\3-Step.ps1' -Parameter @{"cwd"=$cwd;"version"=$version}
}

Add-AzureRmAccount -Subscription $SubscriptionId;
Run $PSScriptRoot;
Clear-AzureRmContext -Force;