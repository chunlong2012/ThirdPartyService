class MessageQueue
  # attr_accessible :command_type, :token, :message, :app, :device
  # command_type : 0为single push 1为group push
  # device : ios | android

  def self.redis_code
    "APNS-MESSAGE-QUEUE"
  end

  def self.new_single_push( token_list , message , app , device , options )
    s = { :token_list => token_list , :message => message , :app => app , :device => device }
    s[ :options ] = options unless options.nil?
    $redis .rpush( redis_code , s.to_json )
  end

  def self.get_query
    q = nil
    s = $redis .lindex( redis_code , 0 )
    q = JSON.parse( s ) unless s .nil?
    while !q.nil? && ( q[ "message" ] .nil? || q[ "app" ] .nil? )
      ApnsPushLog.log( "Warning: Parameter not found in single push! DELETE! (#{ q[ "device" ]},#{ q[ "app" ] },#{ q[ "token_list" ] },#{ q[ "message" ] })" ) 
      remove_query
      q = nil
      s = $redis .lindex( redis_code , 0 )
      q = JSON.parse( s ) unless s .nil?
    end
    q[ "token_list" ] = JSON.parse( q[ "token_list" ] ) unless q.nil?
    q[ "options" ] = JSON.parse( q[ "options" ] ) unless q.nil? || q[ "options" ] .nil?
    q
  end

  def self.remove_query
    $redis .lpop( redis_code )
  end

  def self.round
    $redis .rpush( redis_code , $redis .lpop( redis_code ) )
  end
end
