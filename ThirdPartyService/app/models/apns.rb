#encoding: utf-8

module APNS
	@hold_time = 600	# second
	@net = { 0 => {
				:vimi => Connection.new( "vimi-apns.pem" , nil ) ,
				:vida => Connection.new( "vida-apns.pem" , nil ) ,
			} ,
			1 => {
			}
		}
	# 在@net中 0为ios的连接 1为android的连接

	def self.info( msg )
		#puts "[#{ Time .now }] #{ msg }"
		ApnsPushLog.log( msg )
	end

	def self.open_all_connection
		info "Start connect to Notification Server"
		@net[ 0 ] .each { |c| c[ 1 ] .open_connection }
		@net[ 1 ] .each { |c| c[ 1 ] .open_connection }
		info "Connection Success"
	end

	def self.close_all_connection
		@net[ 0 ] .each { |c| c[ 1 ] .close_connection }
		@net[ 1 ] .each { |c| c[ 1 ] .close_connection }
		info "Close Connection"
	end

	def self.working
		info "=========>>> starting working to sending push <<<========="
		last_send_time = Time.now
		open_all_connection

    while true
      query = MessageQueue.get_query
      sleep 10 if Time.now - last_send_time >= @hold_time
      sleep 2 and next if query.nil?

      info "Error: Push message not found!!!" if query["message"].nil?

      case query["command_type"]
        when 0 # single push
          if query["device"] == 0      #"ios"
            n = APNS::Notification.new(query["token"], query["message"])
            @net[query["device"]] [query["app"].to_sym].sendmsg(n.packaged_notification)
            info "ios push: Message(#{ query["message"] }) has been sent to user(#{ query["token"] })"
          elsif query["device"] == 1  #"android"
             php_path = Rails.root.to_s + "/../getui-php-sdk/single-push.php"

             `php #{php_path} #{query["token"]} #{query["message"]}`
             # `php #{php_path} "#{type}" "#{token}" "#{message}" "#{badge}" "#{user_info}" "#{sound}"`
             info "anroid push: Message(#{ query["message"] }) has been sent to user(#{ query["token"] })"
          end
        when 1 # group push
          if query["device"] == 0      #"ios"
            info "ios push: Start group push with message(#{ query["message"] })"
            Token.each_token(query[:app], query[:device]) do |token|
              n = APNS::Notification.new(token[:token], query["message"])
              @net[token[:device]] [token[:app].to_sym].sendmsg(n.packaged_notification)
            end
            info "ios push: Finish group push"
          elsif query["device"] == 1  #"android"

          end
      end

      MessageQueue.remove_query(query)
      last_send_time = Time.now
    end

		close_connection
	end

	def self.start_working
		begin
			working
		rescue Exception=>e
			info "Error: #{ e.message }"
		end
	end

	def self.test01
		# Single Push Test
		RestClient.post "vimi.in:6000/push/ios_push",:token => "b796a464 3e20bfb5 42aeaf13 fa7e72eb d6d40109 b3df686f ddba860c e0754bab", :message => "这是一个中文测试" , :app => "vimi"
	end

	def self.test02
		# Group Push Test
		RestClient.post "vimi.in:6000/push/group_push" , :message => "这里在测试多人的push情况" , :app => "vida"
	end

	class Notification
		attr_accessor :device_token, :alert, :badge, :sound, :other
		
		def initialize(device_token, message)
			self.device_token = device_token
			if message.is_a?(Hash)
				self.alert = message[:alert]
				self.badge = message[:badge]
				self.sound = message[:sound]
				self.other = message[:other]
			elsif message.is_a?(String)
				self.alert = message
			else
				raise "Notification needs to have either a hash or string"
			end
		end
				
		def packaged_notification
			pt = self.packaged_token
			pm = self.packaged_message
			[0, 0, 32, pt, 0, pm.bytesize, pm].pack("ccca*cca*")
		end
	
		def packaged_token
			[device_token.gsub(/[\s|<|>]/,'')].pack('H*')
		end
	
		def packaged_message
			aps = {'aps'=> {} }
			aps['aps']['alert'] = self.alert if self.alert
			aps['aps']['badge'] = self.badge if self.badge
			aps['aps']['sound'] = self.sound if self.sound
			aps.merge!(self.other) if self.other
			aps.to_json.gsub(/\\u([\da-fA-F]{4})/) {|m| [$1].pack("H*").unpack("n*").pack("U*")}
		end
		
	end
end
