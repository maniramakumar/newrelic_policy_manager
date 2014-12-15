default[:newrelic][:apikey] = nil
default[:newrelic][:policy_manager][:server_name] = nil
default[:newrelic][:policy_manager][:startup_policy] = 'Default server alert policy'
default[:newrelic][:policy_manager][:shutdown_policy] = node[:newrelic][:policy_manager][:startup_policy]

default[:newrelic][:delete_all][:cron][:user] = 'root'
default[:newrelic][:delete_all][:cron][:group] = 'root'
default[:newrelic][:delete_all][:cron][:minute] = 0 
default[:newrelic][:delete_all][:cron][:hour] = 0
default[:newrelic][:delete_all][:cron][:day] = "*"
default[:newrelic][:delete_all][:cron][:weekday] = 0