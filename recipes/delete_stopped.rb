gem_package "httparty" do
  version "0.11.0"
  action :install
end

template "/usr/local/bin/delete_stopped" do
  source "delete_stopped.erb"
  mode '0744'
  owner node[:newrelic][:delete_all][:cron][:user]
  group node[:newrelic][:delete_all][:cron][:group]
  variables({
     :api_key => node[:newrelic][:apikey],
  })
end

cron "delete_all_decommissioned_servers" do
  command "bundle exec /usr/local/bin/delete_stopped"
  minute node[:newrelic][:delete_all][:cron][:minute]
  hour node[:newrelic][:delete_all][:cron][:hour]
  day node[:newrelic][:delete_all][:cron][:day]
  weekday node[:newrelic][:delete_all][:cron][:weekday]
  action :create
end