#
# Author:: Adam Edwards (adamedx)
# Cookbook Name:: dsc_resource_try
# Recipe:: powershell5
#
# Copyright:: Copyright (c) 2015 Adam Edwards
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# PowerShell 5.0 Preview download page
# http://www.microsoft.com/en-us/download/confirmation.aspx?id=45883


case node['platform']
when 'windows'

  powershell5_local_msi = "#{Chef::Config[:file_cache_path]}/powershell5.msu"

  remote_file powershell5_local_msi do
    source node['dsc_resource_try']['powershell5']['powershell5_package_url']
    not_if "($PSVersionTable['psversion'].Major -ge 5) -and ($PSVersionTable['psversion'].Build -gt 9701)"
  end

  reboot 'reboot_if_needed' do
    action :nothing
    only_if { reboot_pending? }
  end

  ruby_block 'check_required_powershell' do
    block do
    end
    action :nothing
    not_if "($PSVersionTable['psversion'].Major -ge 5) -and ($PSVersionTable['psversion'].Build -gt 9701)"
    notifies :reboot_now, 'reboot[reboot_if_needed]', :immediately
  end


  install_command = "'#{powershell5_local_msi}' /quiet /norestart"
  powershell_script 'install_powershell5' do
    code <<-EOH
echo 'Scheduling installation...'
& schtasks /create /f  /sc once /st 00:00:00 /tn chefclientbootstraptask /ru SYSTEM /rl HIGHEST /tr \"cmd /c #{install_command} & sleep 2 & waitfor /s %computername% /si chefclientinstalldone\"
echo 'Starting package installation...'
& schtasks /run /tn chefclientbootstraptask
echo 'Waiting for package installation to complete...'
$duration = (measure-command { waitfor chefclientinstalldone /t 900 })
echo 'Package installation done.'
echo 'Installation duration: ' + $duration.ToString(\"hh':'mm':'ss\")
EOH
    not_if "($PSVersionTable['psversion'].Major -ge 5) -and ($PSVersionTable['psversion'].Build -gt 9701)"
    #    notifies :reboot_now, 'reboot[reboot_if_needed]', :immediately
    notifies :run, 'ruby_block[check_required_powershell]', :immediately
  end

end

