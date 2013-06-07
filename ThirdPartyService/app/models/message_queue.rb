class MessageQueue < ActiveRecord::Base
  attr_accessible :command_type, :token, :message, :app, :device
  # command_type : 0为single push 1为group push
  # device : 0为ios 1为android

  @device_h = { "ios" => 0 , "android" => 1 }

  def self.new_single_push( token , message , app , device )
  	m = MessageQueue.new( 
  		:command_type => 0 ,
  		:token => token ,
  		:message => message ,
  		:app => app ,
      :device => @device_h[ device ]
  	)
  	m .save
  end

  def self.new_group_push( message , app , device )
  	m = MessageQueue.new( 
  		:command_type => 1 ,
  		:token => "" ,
  		:message => message ,
  		:app => app ,
      :device => @device_h[ device ]
  	)
  	m .save
  end

  def self.get_query
    MessageQueue.find( :first )
  end

  def self.remove_query( q )
    MessageQueue.delete( q[ :id ] )
  end
end
