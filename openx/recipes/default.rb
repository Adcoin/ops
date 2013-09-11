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

SHARED_DIRECTORIES = [
    "shared/config",
    "shared/log"
]

deploy_user = "deploy" # from opsworks cookbooks: node[:opsworks][:deploy_user][:user]
deploy_dir  = node[:deploy][APPLICATION][:deploy_to]

dns_name    = node[:opsworks][:instance][:public_dns_name]

WRITABLE_DIRECTORIES.each do |dir|
    dir_path = File.join(deploy_dir, "current", dir)

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

SHARED_DIRECTORIES.each do |dir|
    dir_path = File.join(deploy_dir, "current", dir)

    execute "mkdir -p #{dir_path}" do
        action :run
        user deploy_user
        not_if "test -d #{dir_path}"
    end
end

template File.join(deploy_dir, "current", "var/default.conf.php") do
    source "default.conf.php.erb"
    mode "0644"
    owner deploy_user
    variables({
        :dns_name => dns_name
    })
end

template File.join(deploy_dir, "current", "var/#{dns_name}.conf.php") do
    source "server.conf.php.erb"
    mode "0644"
    owner deploy_user
    variables({
        :dns_name => dns_name,
        :deploy_dir => deploy_dir
    })
end

file File.join(deploy_dir, "current", "var/INSTALLED") do
    action :touch
    mode "0644"
    owner deploy_user
end
