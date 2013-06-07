class Token < ActiveRecord::Base
  attr_accessible :device, :token, :app
  # device : 0为ios 1为android

  @device_h = { "ios" => 0 , "android" => 1 }

  def self.new_token( token , device , app )
  	m = Token.find_by_token( token )
  	m = Token.new( 
  		:token => token ,
  		:device => @device_h[ device ] ,
      :app => app
  	) if m .nil?
  	m .save
  end

  def self.each_token( app , device )
    offset = 0
    construction = [ "app = ?#{ " and device = ?" unless device .nil? }" , app ] 
    construction << device unless device .nil?
    while !( list = Token.where( construction ).offset( offset ).limit( 20 ).all ) .empty?
      list .each { |token| yield token }
      offset += 20 
    end
  end
end
