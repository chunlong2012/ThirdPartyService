class Token < ActiveRecord::Base
  attr_accessible :device, :token, :vida, :vimi

  def self.new_token( token , device , app )
  	m = Token.find_by_token( token )
  	m = Token.new( 
  		:token => token ,
  		:device => device ,
  		:vida => 0 ,
  		:vimi => 0
  	) if m .nil?
  	m[ app .to_sym ] = 1 
  	m .save
  end
end
