class Chef
  class Recipe
    class NewrelicServer

      def initialize(api_key,server_name)
        self.class.send(:include, HTTParty)
        @api_key = api_key
        @server_name = server_name
        @server_response = {}
        @policy_response = {}
      end

      def delete
        response = HTTParty.delete(
          "https://api.newrelic.com/v2/servers/#{server_id}.json",
          :headers => {"X-Api-Key" => @api_key}
        )
        if response.code != 200
          log_error(response.code)
        else 
          Chef::Log.info "Successfully deleted #{@server_name}"
        end
      end

      def get_by_name
        response = HTTParty.get(
          "https://api.newrelic.com/v2/servers.json?filter[name]=#{URI.escape(@server_name)}", 
          :headers => {"X-Api-Key" => @api_key}
        )
        if response.code != 200
          log_error(response.code)
        else 
          if response["servers"].length <= 0
            Chef::Log.error "Received 0 servers with the name #{@server_name}, expected exactly one"
          else
            return response["servers"].first
          end
        end
        {}
      end
      private :get_by_name

      def get_policy_by_name(policy_name)
        response = HTTParty.get(
          "https://api.newrelic.com/v2/alert_policies.json?filter[type]=server&filter[name]=#{URI.escape(policy_name)}", 
          :headers => {"X-Api-Key" => @api_key}
        )
        if response.code != 200
          log_error(response.code)
        else 
          alert_policy = response["alert_policies"].select{ |alert_policy| alert_policy["name"] == policy_name }
          if alert_policy.length <= 0
            Chef::Log.error "Received 0 policies with the name #{policy_name}, expected exactly one"
          else
            return alert_policy.first
          end
        end
        {}
      end
      private :get_policy_by_name

      def add_to_policy(policy_name)
        @server_response = get_by_name
        @policy_response = get_policy_by_name(policy_name)
        unless @server_response.empty? || @policy_response.empty?
          if server_ids.include? server_id
            Chef::Log.info "Server #{@server_name} already belongs to #{policy_name}"
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
              if @policy_response["links"] && !@policy_response["links"]["servers"].include?(server_id)
                Chef::Log.error "Failed to added server #{@server_name} to alert policy with name #{policy_name}"
              else 
                Chef::Log.info "Successfully added server #{@server_name} to alert policy with name #{policy_name}"
              end
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
        if @policy_response["links"] && @policy_response["links"]["servers"]
          @policy_response["links"]["servers"]
        else
          []
        end
      end
      private :server_ids

      def log_error(code) 
        case code
        when 401 then Chef::Log.error "Invalid or missing NewRelic API code"
        when 403 then Chef::Log.error "New Relic API access has not been enabled for your account"
        when 404 then Chef::Log.error "No alert policy found with the given ID"
        when 422 then Chef::Log.error "Validation error occurred when updating the alert policy"
        when 500 then Chef::Log.error "A server error occured, please contact New Relic support"
        else Chef::Log.error "Unknown response code #{code}" end
      end

    end
  end
end
