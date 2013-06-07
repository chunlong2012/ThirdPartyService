require 'socket'
require 'openssl'

class Connection
	#attr_accessor :host, :pem, :port, :pass

	def initialize( pem_file , password )
		@host = "gateway.push.apple.com"
		@port = 2195
		@pem = pem_file
		@pass = password

		raise "The path to your pem file is not set. (APNS.pem = /path/to/cert.pem)" unless @pem
		raise "The path to your pem File does not exist!" unless File.exist?(@pem)
		
		context = OpenSSL::SSL::SSLContext.new
		context.cert = OpenSSL::X509::Certificate.new(File.read(@pem))
		context.key = OpenSSL::PKey::RSA.new(File.read(@pem), @pass)

		@sock = TCPSocket.new(@host, @port)
		@ssl = OpenSSL::SSL::SSLSocket.new(@sock,context)

		@connection_state = false
	end

	def open_connection
		return @sock, @ssl if @connection_state

		@ssl.connect
		@connection_state = true

		return @sock, @ssl
	end

	def sendmsg( msg )
		@ssl .write( msg ) if @connection_state
	end

	def close_connection
		@ssl.close
		@sock.close
		@connection_state = false
	end
end
