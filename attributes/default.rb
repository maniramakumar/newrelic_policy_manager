default[:newrelic][:apikey] = nil
default[:newrelic][:policy_manager][:server_name] = nil
default[:newrelic][:policy_manager][:startup_policy] = 'Default server alert policy'
default[:newrelic][:policy_manager][:shutdown_policy] = node[:newrelic][:policy_manager][:startup_policy]