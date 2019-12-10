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
  [string] $SubscriptionId
)

function DeleteResourceGroup($depConfig) {
  return Remove-AzureRmResourceGroup -Name $depConfig.ResourceGroupName -Force;
}
function Run($root) {
  $config = Get-Content "${root}\provision_config.json" | Out-String | ConvertFrom-Json;
  $depConfig = $config.Deployment;
  DeleteResourceGroup $depConfig;
}

Add-AzureRmAccount -Subscription $SubscriptionId;
Run $PSScriptRoot;
Clear-AzureRmContext -Force;
