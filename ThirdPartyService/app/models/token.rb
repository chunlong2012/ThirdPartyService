class Token
  # 在redis中并且存放每个token的当前状态，字段为 "APNS-USER-TOKEN:token:device:app"
  # 状态为 0 存在并可用 1 存在但无法使用 2 已过期

  def self.redis_code
    "APNS-USER-TOKEN"
  end

  def self.redis_token( token , device , app )
    "#{ redis_code }:#{ token }:#{ device }:#{ app }"
  end

  def self.check_token( token , device , app )
    $redis .get( redis_token( token , device , app ) ) .to_i == 0
  end

  def self.new_token( token , device , app )
    return false unless $redis .get( redis_token( token , device , app ) ) .nil?
    $redis .rpush( redis_code , { :token => token , :device => device , :app => app } .to_json )
    $redis .set( redis_token( token , device , app ) , 0 )
    true
  end

  def self.each_token
    $redis .lrange( redis_code , 0 , -1 ) .each do |s|
      next if s .nil?
      t = JSON.parse( s )
      yield( t ) if check_token( t[ "token" ] , t[ "device" ] , t[ "app" ] )
    end
  end
end
