require_relative "apns/core"
require_relative "apns/notification"
require "sqlite3"

module DB
	@dbname = "../db/development.sqlite3"
	@db = SQLite3::Database.open( @dbname )

	def self.each_token( device , app )
		sql = "select * from tokens where device = \"#{ device }\" and #{ app } = 1"
		@db.execute( sql ) do | row |
			yield( row[ 1 ] ) 
			#token_list << row[ 0 ] 
		end
	end

	def self.get_query
		# get first row in Query table and delete it
		q = @db.get_first_row( "select * from message_queues" )
		return nil if q.nil?
		@db.execute( "delete from message_queues where id = #{ q[ 0 ] }" )
		return { "query_type" => q[ 1 ] , "token" => q[ 2 ] , "message" => q[ 3 ] , "app" => q[ 4 ] }
	end
end

module APNS
	def self.working
		# starting working to sending push 
		self.pem = "vimi_aps.pem"
		self.host = "gateway.push.apple.com"
		sock, ssl = self.open_connection

		while query = DB.get_query
			case query[ "query_type" ]
			when 0 # iOS push
				n = APNS::Notification.new( query[ "token" ] , query[ "message" ] )
				ssl.write( n.packaged_notification )

				puts "[#{ Time .now }] Message has been sent to user(#{ query[ "token" ] })"
			when 1 # android push

			when 2 # group push
				puts "[#{ Time .now }] Start group push"

				# ios
				DB::each_token( "ios" , query[ "app" ] ) do |t|
					n = APNS::Notification.new( t , query[ "message" ] )
					ssl.write( n.packaged_notification )
				end

				# android

				puts "[#{ Time .now }] Finish group push"
			end
		end

		ssl.close
		sock.close
	end
end

APNS.working
