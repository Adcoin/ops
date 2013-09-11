#
# Cookbook Name:: openx
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

APPLICATION = "openx_server"

WRITABLE_DIRECTORIES = [
    "var", "var/cache", "var/plugins", "var/templates_compiled",
    "plugins", "www/admin/plugins", "www/images"
]

WRITABLE_DIRECTORIES.each do |dir|
    dir_path = File.join(node[:deploy][APPLICATION][:deploy_to], "current", dir)
    deploy_user = node[:opsworks][:deploy_user][:user]

    execute "mkdir -p #{dir_path}" do
        action :run
        user deploy_user
        not_if "test -d #{dir_path}"
    end

    execute "chmod -R a+w #{dir_path}" do
        action :run
        not_if "sudo -u nobody test -w #{dir_path}"
    end
end
