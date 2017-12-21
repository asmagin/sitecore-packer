property :iso_path, String, name_property: true
property :iso_drive_letter, String, required: true

default_action :mount

action :mount do
  powershell_script "Mount '#{iso_path}' at '#{iso_drive_letter}'" do
    code <<-EOH
      $mountResult = Mount-DiskImage #{iso_path.tr('/', '\\')} -PassThru -NoDriveLetter
      mountvol #{iso_drive_letter}: ($mountResult | Get-Volume).UniqueId
    EOH
    action :run
  end
end

action :dismount do
  powershell_script "Dismount '#{iso_path}'" do
    code <<-EOH
      Dismount-DiskImage #{iso_path}
    EOH
    action :run
  end
end
