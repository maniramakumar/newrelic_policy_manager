require File.expand_path("../../libraries/newrelic_server.rb", __FILE__)
include_recipe "newrelic_policy_manager::httparty"

ruby_block "remove_server_from_policy" do
  block do
    server = Chef::Recipe::NewrelicServer.new(node[:newrelic][:apikey],node[:newrelic][:policy_manager][:server_name])
    server.add_to_policy(node[:newrelic][:policy_manager][:shutdown_policy])
  end
end

