gusztavvargadr_sitecore_prepare '' do
  options node['gusztavvargadr_sitecore']['90xp']
  action :enable_contained_db_auth
end

gusztavvargadr_sitecore_prepare '' do
  options node['gusztavvargadr_sitecore']['90xp']
  action :enable_mixed_auth
end

gusztavvargadr_sitecore_prepare '' do
  options node['gusztavvargadr_sitecore']['90xp']
  action :enable_sa_login
end

gusztavvargadr_sitecore_prepare '' do
  options node['gusztavvargadr_sitecore']['90xp']
  action :install_and_update_sif
end
