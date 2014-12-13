class Chef
  class Recipe
    class NewrelicServer

      def initialize(api_key,server_name)
        self.class.send(:include, HTTParty)
        @api_key = api_key
        @server_name = server_name
        @server_response = get_by_name
        @policy_response = nil
      end

      def self.delete_all(api_key)
        response = HTTParty.get(
          "https://api.newrelic.com/v2/servers.json", 
          :headers => {"X-Api-Key" => api_key}
        )
        response["servers"].select{ |server| server["reporting"] == false }.each do |server|
          response = HTTParty.delete(
            "https://api.newrelic.com/v2/servers/#{server["id"]}.json",
            :headers => {"X-Api-Key" => api_key}
          )
          if response.code != 200
            log_error(response.code)
          else 
            Chef::Log.warn "Successfully deleted #{server["name"]}"
          end
        end
      end

      def get_by_name
        response = ::HTTParty.get(
          "https://api.newrelic.com/v2/servers.json?filter[name]=#{URI.escape(@server_name)}", 
          :headers => {"X-Api-Key" => @api_key}
        )
        if response.code != 200
          log_error(response.code)
        else 
          if response["servers"].length == 1
            return response["servers"].first
          else
            Chef::Log.warn("Received #{response["servers"].length} servers with the name #{@server_name}, expected exactly one"); exit(1)
          end
        end
      end
      private :get_by_name

      def delete
        response = HTTParty.delete(
          "https://api.newrelic.com/v2/servers/#{server_id}.json",
          :headers => {"X-Api-Key" => @api_key}
        )
        if response.code != 200
          log_error(response.code)
        else 
          Chef::Log.warn("Successfully deleted #{@server_name}")
        end
      end

      def get_policy_by_name(policy_name)
        response = HTTParty.get(
          "https://api.newrelic.com/v2/alert_policies.json?filter[type]=server&filter[name]=#{URI.escape(policy_name)}", 
          :headers => {"X-Api-Key" => @api_key}
        )
        if response.code != 200
          log_error(response.code) 
        else 
          if response["alert_policies"].length == 1
            return response["alert_policies"].first
          else
            Chef::Log.warn("Received #{response["alert_policies"].length} policies with the name #{policy_name}, expected exactly one"); exit(1)
          end
        end
      end
      private :get_policy_by_name

      def add_to_policy(policy_name)
        @policy_response = get_policy_by_name(policy_name)

        if server_ids.include? server_id
          Chef::Log.warn("Server #{@server_name} already belongs to policy with id #{policy_id}")
        else
          servers = server_ids << server_id
          response = HTTParty.put(
            "https://api.newrelic.com/v2/alert_policies/#{policy_id}.json", 
            :headers => {"X-Api-Key" => @api_key, "Content-Type" => "application/json"},
            :body => {
              'alert_policy' => { 
                'links' => { 
                  'servers'=> servers
                  }
                }
              }.to_json
          )
          if response.code != 200
            log_error(response.code)
          else 
            if response["alert_policy"]["links"]["servers"].empty?
              Chef::Log.warn response
            else 
              Chef::Log.warn "Successfully added server #{server_id} to alert policy with id #{policy_id}"
            end
          end
        end
      end

      def policy_id
        @policy_response["id"]
      end
      private :policy_id

      def server_id
        @server_response["id"]
      end
      private :server_id

      def server_ids
        @policy_response["links"]["servers"] || []
      end
      private :server_ids

      def log_error(code) 
        case code
        when 401 then Chef::Log.warn("Invalid or missing NewRelic API code")
        when 403 then Chef::Log.warn("New Relic API access has not been enabled for your account")
        when 404 then Chef::Log.warn("No alert policy found with the given ID")
        when 422 then Chef::Log.warn("Validation error occurred when updating the alert policy")
        when 500 then Chef::Log.warn("A server error occured, please contact New Relic support")
        else Chef::Log.warn("Unknown response code #{code}") end
      end

    end
  end
end