#encoding: utf-8

module MessageProcesser
	@hold_time = 60	# second
	@net = { 0 => { } ,
			1 => { }
		}
	# 在@net中 0为ios的连接 1为android的连接

	# 打印log信息至文件
	def self.info( msg )
		MessagePushLog.log( msg )
	end

	# 由于等待时间过长，则所有连接重新连接
	def self.reconnect_all
		@net[ 0 ] .each{ |c| c[ 1 ] .reconnect }
	end

	# 发送消息的方法细化
	def self.ios_push( app , token , message )
		noti = ApnsNotification.new( token , message )
		@net[ 0 ] [ app.to_sym ].sendmsg( noti.packaged_notification )
	end

	def self.android_push( app , token , message )
		php_path = Rails.root.to_s + "/../getui-php-sdk/single-push.php"
		message = message.gsub("\"","\\\"")
		`php #{php_path} #{token} "#{message}"`
		true
	end

	def self.single_push_nolog( device , app , tokenl , message )
		tokenl .each do |token|
			return false if device == "ios" && !ios_push( app , token , message )
			return false if device == "android" && !android_push( app , token , message ) 
		end
		true
	end

	def self.push( device , app , tokenl , message )
		if  single_push_nolog( device , app , tokenl , message )
			info "#{ device } push: Message(#{ message }) push to user(#{ tokenl }) [app:#{ app }]"
		else 
			info "Warning: #{ device } push: Message(#{ message }) push to user(#{ tokenl }) [app:#{ app }] has been wrong."
	  end
	end

	# 监听 redis 中请求
	def self.working
		#@net[ 0 ] [ :vida ] = ApnsConnnection.new( "vida-apns.pem" , nil )
		@net[ 0 ] [ :vimi ] = ApnsConnnection.new( "vimi-apns.pem" , nil )
		last_send_time = Time.now

		while true
			query = MessageQueue.get_query
			sleep 5 if Time.now - last_send_time >= @hold_time
			sleep 2 and next if query.nil?
			reconnect_all if Time.now - last_send_time >= @hold_time

			push( query[ "device" ] , query[ "app" ] , query[ "token_list" ] , query[ "message" ] )

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
		RestClient.post "0.0.0.0:3000/push/ios_push",:token_list => '["b796a464 3e20bfb5 42aeaf13 fa7e72eb d6d40109 b3df686f ddba860c e0754bab","b796a464 3e20bfb5 42aeaf13 fa7e72eb d6d40109 b3df686f ddba860c e0754bab","b796a464 3e20bfb5 42aeaf13 fa7e72eb d6d40109 b3df686f ddba860c e0754bab"]' , :message => "这是一个中文测试" , :app => "vimi"
	end
end
