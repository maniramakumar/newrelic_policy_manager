#### Newrelic Policy Manager
This cookbook allows the designation of which Newrelic Alert Policy a server should be placed in on start up and on shutdown. It also allows the user to easily delete servers which have been shutdown, 


#### Recipes
**add_to_policy:** Adds server to Newrelic alert policy

**remove_from_policy:** Remove server to Newrelic alert policy

**delete_stopped:** Creates a cron that removes all stopped servers

#### Attributes
- `node[:newrelic][:apikey]` *required, defaults to nil*
- `node[:newrelic][:policy_manager][:server_name]` The name of the server that you want to add to a different policy.
- `node[:newrelic][:policy_manager][:startup_policy]` The policy that you want `:server_name` to be added to on startup.  *defaults to 'Default server alert policy'*
- `node[:newrelic][:policy_manager][:shutdown_policy]` The policy that you want `:server_name` to be added to on startup. *defaults to `node[:newrelic][:policy_manager][:startup_policy]`*

#####The following are only needed for the delete_stopped recipe:

- `default[:newrelic][:delete_all][:cron][:user]` The user to run the cron as.

- `default[:newrelic][:delete_all][:cron][:group]` The group to which the user belongs. 

#####The following are only necessary to change the time when the cron runs. It runs at 12:00 every Sunday by default.
- `default[:newrelic][:delete_all][:cron][:minute]`
- `default[:newrelic][:delete_all][:cron][:hour]`
- `default[:newrelic][:delete_all][:cron][:day]`
- `default[:newrelic][:delete_all][:cron][:weekday]`