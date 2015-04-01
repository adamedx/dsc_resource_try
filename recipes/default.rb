#
# Cookbook Name:: dsc_resource_try
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

# include_recipe 'powershell::powershell5'
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

set-dsclocalconfigurationmanager -path .\disable_lcm -wait
EOH
end

dsc_resource 'Create Test User' do
  resource :user
  property :username, 'testuser1'
  property :password, ps_credential('123Opscode!')
  property :ensure, 'Present'
end

