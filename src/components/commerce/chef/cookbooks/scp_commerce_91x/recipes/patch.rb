scp_sitecore_common_iisreset '' do
end

scp_sitecore_common_warmup '' do
  site_url node['scp_commerce_91x']['common']['sitecore']['site_url']
end

scp_sitecore_common_warmup '' do
  site_url node['scp_commerce_91x']['common']['commerce']['storefront_url']
end

scp_sitecore_common_republish '' do
  site_url node['scp_commerce_91x']['common']['sitecore']['site_url']
end

scp_sitecore_common_rebuild_link_db '' do
  site_url node['scp_commerce_91x']['common']['sitecore']['site_url']
end

scp_sitecore_common_solr_reindex '' do
  site_url node['scp_commerce_91x']['common']['sitecore']['site_url']
end

scp_sitecore_common_iisreset '' do
end

scp_sitecore_common_warmup '' do
  site_url node['scp_commerce_91x']['common']['sitecore']['site_url']
end

scp_sitecore_common_warmup '' do
  site_url node['scp_commerce_91x']['common']['commerce']['storefront_url']
end
