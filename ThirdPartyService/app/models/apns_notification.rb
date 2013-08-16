# 发送的 ios push 的封装对象

class ApnsNotification
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
		# 对于超过长度的消息需要将消息切断，所有消息按照中文字符计算其长度
		if self.alert.length * 3 + self.other.to_json.length > 256 - 25
			max_length = ( 256 - 25 - self.other.to_json.length ) / 3 
			self.alert = self.alert[ 0 .. max_length ] + "..."
		end

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
