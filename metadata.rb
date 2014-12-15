name             'newrelic_policy_manager'
maintainer       'Sport Ngin'
maintainer_email 'infrastructure@sportngin.com'
license          'All rights reserved'
description      'Automatically adds/removes servers to Newrelic alert policy.'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

supports 'amazon'

recipe "add_to_policy", "Adds server to Newrelic alert policy"
recipe "remove_from_policy", "Remove server to Newrelic alert policy"
recipe "delete_stopped", "Creates a cron that removes all stopped servers"
