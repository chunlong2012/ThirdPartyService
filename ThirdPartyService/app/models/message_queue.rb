class MessageQueue
  # attr_accessible :command_type, :token, :message, :app, :device
  # command_type : 0为single push 1为group push
  # device : ios | android

  def self.redis_code
    "APNS-MESSAGE-QUEUE"
  end

  def self.new_single_push( token , message , app , device )
    s = { :command_type => 0 , :token => token , :message => message , :app => app , :device => device } .to_json
    $redis .rpush( redis_code , s )
  end

  def self.new_group_push( message , app , device )
    s = { :command_type => 1 , :message => message , :app => app , :device => device } .to_json
    $redis .rpush( redis_code , s )
  end

  def self.get_query
    q = nil
    s = $redis .lindex( redis_code , 0 )
    q = JSON.parse( s ) unless s .nil?
    while !q.nil? && ( q[ "message" ] .nil? || q[ "app" ] .nil? )
      ApnsPushLog.log( "Warning: Parameter not found in single push! DELETE! (#{ q[ "command_type" ] },#{ q[ "device" ]},#{ q[ "app" ] },#{ q[ "token" ] },#{ q[ "message" ] })" ) 
      remove_query
      q = nil
      s = $redis .lindex( redis_code , 0 )
      q = JSON.parse( s ) unless s .nil?
    end
    q
  end

  def self.remove_query
    $redis .lpop( redis_code )
  end
end
