#encoding: utf-8

module APNS
	@hold_time = 60	# second
	@net = { 0 => { } ,
			1 => { }
		}
	# 在@net中 0为ios的连接 1为android的连接

	# 打印log信息至文件
	def self.info( msg )
		ApnsPushLog.log( msg )
	end

	# 由于等待时间过长，则所有连接重新连接
	def self.reconnect_all
		@net[ 0 ] .each{ |c| c[ 1 ] .reconnect }
	end

	# 发送消息的方法细化
	def self.ios_push( app , token , message )
		noti = APNS::Notification.new( token , message )
		@net[ 0 ] [ app.to_sym ].sendmsg( noti.packaged_notification )
	end

	def self.android_push( app , token , message )
		php_path = Rails.root.to_s + "/../getui-php-sdk/single-push.php"
		message = message.gsub("\"","\\\"")
		`php #{php_path} #{token} "#{message}"`
	end

	def self.single_push_nolog( device , app , token , message )
		ios_push( app , token , message ) if device == "ios" 
		android_push( app , token , message ) if device == "android"
	end

	def self.single_push( device , app , token , message )
		single_push_nolog( device , app , token , message )
		info "#{ device } push: Message(#{ message }) push to user(#{ token }) [app:#{ app }]"
	end

	def self.group_push( device , message , app )
		info "group push: Start group push with message(#{message}) [app:#{ app }]"
		Token.each_token do |t|
			single_push( t[ "device" ] , t[ "app" ] , t[ "token" ] , message ) if ( t[ "device" ] == device || device .nil? ) && t[ "app" ] == app 
		end
		info "group push: Finish group push"
	end

	# 监听 redis 中请求
	def self.working
		@net[ 0 ] [ :vimi ] = Connection.new( "vimi-apns.pem" , nil )
		@net[ 0 ] [ :vida ] = Connection.new( "vida-apns.pem" , nil )
		last_send_time = Time.now

		while true
			query = MessageQueue.get_query
			sleep 5 if Time.now - last_send_time >= @hold_time
			sleep 2 and next if query.nil?
			reconnect_all if Time.now - last_send_time >= @hold_time

			case query[ "command_type" ]
			when 0 # single push
				single_push( query[ "device" ] , query[ "app" ] , query[ "token" ] , query[ "message" ] )
			when 1 # group push
				group_push( query[ "device" ] , query[ "message" ] , query[ "app" ] )
			end

			MessageQueue.remove_query
			last_send_time = Time.now
		end
	end

	# 开始监听，捕获错误
	def self.start_working
		begin
			working
		rescue Exception=>e
			info "Error: #{ e.message } in \n\t #{ e.backtrace.join( "\n\t" ) }"
		end
	end

	# 测试方法 （发送至我的iphone5）
	def self.test01
		# Single Push Test
		RestClient.post "0.0.0.0:3000/push/ios_push",:token => "b796a464 3e20bfb5 42aeaf13 fa7e72eb d6d40109 b3df686f ddba860c e0754bab", :message => "这是一个中文测试" , :app => "vimi"
		#RestClient.post "vimi.in:6000/push/ios_push",:token => "b796a464 3e20bfb5 42aeaf13 fa7e72eb d6d40109 b3df686f ddba860c e0754bab", :message => "这是一个中文测试" , :app => "vimi"
	end

	def self.test03
		RestClient.post "0.0.0.0:3000/push/add_token",:token => "b796a464 3e20bfb5 42aeaf13 fa7e72eb d6d40109 b3df686f ddba860c e0754bab", :message => "这是一个中文测试" , :app => "vimi"
	end

	def self.test02
		# Group Push Test
		RestClient.post "0.0.0.0:3000/push/group_push" , :message => "这里在测试多人的push情况" , :app => "vimi"
	end


	# 发送的 ios push 的封装对象
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
