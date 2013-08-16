require 'socket'
require 'openssl'

class ApnsConnnection
	#attr_accessor :host, :pem, :port, :pass

	def initialize( pem_file , password )
		@host = "gateway.push.apple.com"
		@port = 2195
		@pem = pem_file
		@pass = password

		raise "The path to your pem file is not set. (APNS.pem = /path/to/cert.pem)" unless @pem
		raise "The path to your pem File does not exist!" unless File.exist?(@pem)
		
		reconnect
	end

	def reconnect
		context = OpenSSL::SSL::SSLContext.new
		context.cert = OpenSSL::X509::Certificate.new(File.read(@pem))
		context.key = OpenSSL::PKey::RSA.new(File.read(@pem), @pass)

		@sock = TCPSocket.new(@host, @port)
		@ssl = OpenSSL::SSL::SSLSocket.new(@sock,context)
		@ssl.connect

		MessagePushLog.log( "Connect to APNS with (#{ @pem }) pem file" )
	end

	def sendmsg_sub( msg )
		begin
			@ssl .write( msg )
			return true
		rescue
			MessagePushLog.log( "Error: push send connection error, try to reconnect." )
			return false 
		end
	end

	def sendmsg( msg )
		begin 
			msg = msg.packaged_notification
			for i in 1 .. 3 
				return true if sendmsg_sub( msg )
				reconnect
			end
			MessagePushLog.log( "3 reconnection fail, cancel" )
			false 
		rescue Exception=>e
			MessagePushLog.log( "Error: #{ e.message } in \n\t #{ e.backtrace.join( "\n\t" ) }" )
			false
		end
	end
end
