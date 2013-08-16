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
	def self.ios_push( app , token , message , options )
		noti = ApnsNotification.new( token , { :alert => message , :other => options } )
		if @net[ 0 ] [ app.to_sym ].sendmsg( noti )
			info "ios push: Message(#{ message }) push to user(#{ token }) [options:#{ options.to_json }] [app:#{ app }]"
		else
			info "Warning: ios push: Message(#{ message }) push to user(#{ token }) [options:#{ options.to_json }] [app:#{ app }] has been wrong."
		end
	end

	def self.android_push( app , token , message )
		php_path = Rails.root.to_s + "/../getui-php-sdk/single-push.php"
		message = message.gsub("\"","\\\"")
		`php #{php_path} #{token} "#{message}"`

		info "android push: Message(#{ message }) push to user(#{ token }) [app:#{ app }]"
	end

	def self.push( device , app , tokenl , message , options )
		tokenl.each do |token|
			ios_push(app, token, message,options) if device == "ios" 
			android_push(app, token, message) if device == "android" 
		end
	end

	# 监听 redis 中请求
	def self.working
		@net[ 0 ] [ :vida ] = ApnsConnnection.new( "vida-apns.pem" , nil )
		@net[ 0 ] [ :vimi ] = ApnsConnnection.new( "vimi-apns.pem" , nil )
		last_send_time = Time.now

		while true
			query = MessageQueue.get_query
			sleep 5 if Time.now - last_send_time >= @hold_time
			sleep 2 and next if query.nil?
			reconnect_all if Time.now - last_send_time >= @hold_time

			push( query[ "device" ] , query[ "app" ] , query[ "token_list" ] , query[ "message" ] , query[ "options" ] )

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
		# 
		# "Vida微图记首届【微电影大赛】开始了！参加就有Q币拿，每天都送出 OPPO夜拍神器 和Tiffany银项链各一个！还有终极大奖价值两万元的奢华境外游！20万奖品，人人有，天天送！快去看看吧~" , 
		RestClient.post "0.0.0.0:3000/push/ios_push", { 
			:token_list => '["b796a464 3e20bfb5 42aeaf13 fa7e72eb d6d40109 b3df686f ddba860c e0754bab"]' , 
			:message => "Vida微图记首届【微电影大赛】开始了！参加就有Q币拿，每天都送出 OPPO夜拍神器 和Tiffany银项链各一个！还有终极大奖价值两万元的奢华境外游！20万奖品，人人有，天天送！快去看看吧~" ,
			:app => "vida" ,
			:options => { :u => { :url => "http://www.baidu.com/" , :c => "" } } .to_json 
		}
	end
end
