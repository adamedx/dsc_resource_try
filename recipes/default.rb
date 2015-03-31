#
# Cookbook Name:: dsc_resource_try
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

include_recipe 'powershell::powershell5'
include_recipe 'powershell::dsc'

dsc_script 'disable_lcm' do
  code <<-EOH
    LocalConfigurationManager {
      RefreshMode = 'Disabled'
   }
EOH
end

dsc_resource 'Create Test User' do
  resource :user
  property :username, 'testuser1'
  property :password, ps_credential('123Opscode!')
  property :ensure, 'Present'
end

