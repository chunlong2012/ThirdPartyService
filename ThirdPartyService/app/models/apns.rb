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
		puts "[#{ Time .now }] #{ msg }"
	end

	def self.open_all_connection
		@net[ 0 ] .each { |c| c[ 1 ] .open_connection }
		@net[ 1 ] .each { |c| c[ 1 ] .open_connection }
	end

	def self.close_all_connection
		@net[ 0 ] .each { |c| c[ 1 ] .close_connection }
		@net[ 1 ] .each { |c| c[ 1 ] .close_connection }
	end

	def self.working
		# starting working to sending push
		last_send_time = Time.now
		open_all_connection

		while true
			query = MessageQueue.get_query
			sleep 10 if Time.now - last_send_time >= @hold_time
			sleep 2 and next if query .nil?

			case query[ "command_type" ]
			when 0 # single push
				n = APNS::Notification.new( query[ "token" ] , query[ "message" ] )
				@net[ query[ "device" ] ] [ query[ "app" ] .to_sym ] .sendmsg( n.packaged_notification )

				info "Message has been sent to user(#{ query[ "token" ] })"

			when 1 # group push
				info "Start group push" 

				Token.each_token( query[ :app ] , query[ :device ] ) do | token |
					n = APNS::Notification.new( token[ :token ] , query[ "message" ] )
					@net[ token[ :device ] ] [ token[ :app ] .to_sym ] .sendmsg( n.packaged_notification ) 
				end

				info "Finish group push"
			end
			MessageQueue.remove_query( query )
			last_send_time = Time.now
		end

		close_connection
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
