include_recipe "newrelic_policy_manager::default"

server = NewrelicServer.new(node[:newrelic][:apikey],node[:newrelic][:policy_manager][:server_name])
server.add_to_policy(node[:newrelic][:policy_manager][:startup_policy])
