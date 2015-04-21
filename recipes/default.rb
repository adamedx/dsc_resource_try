#
# Cookbook Name:: dsc_resource_try
# Recipe:: default
#
# Copyright (c) 2015 Adam Edwards, All Rights Reserved.

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

# TODO: add this back once the PowerShell cookbook
# supports the correct version of PowerShell which includes
# the invoke-dsc resource capability.

# include_recipe 'powershell::powershell5'

include_recipe 'dsc_resource_try::powershell5'
include_recipe 'powershell::dsc'

powershell_script 'disable_lcm' do
  code <<-EOH
Configuration 'disable_lcm' {
  node 'localhost' {
    LocalConfigurationManager {
      RefreshMode = 'Disabled'
    }
  }
}

disable_lcm

set-dsclocalconfigurationmanager -path .\\disable_lcm
EOH
  not_if "(Get-DscLocalConfigurationManager).refreshmode -eq 'disabled'"
end

dsc_resource 'Create Test User' do
  resource :user
  property :username, 'testuser1'
  property :password, ps_credential('123Opscode!')
  property :ensure, 'Present'
end

