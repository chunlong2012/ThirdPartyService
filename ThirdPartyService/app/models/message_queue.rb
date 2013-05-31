class MessageQueue < ActiveRecord::Base
  attr_accessible :command_type, :token, :message, :app

  def self.new_ios_push( token , message , app )
  	m = MessageQueue.new( 
  		:command_type => 0 ,
  		:token => token ,
  		:message => message ,
  		:app => app 
  	)
  	m .save
  end

  def self.new_android_push( token , message , app )
  	m = MessageQueue.new( 
  		:command_type => 1 ,
  		:token => token ,
  		:message => message ,
  		:app => app 
  	)
  	m .save
  end

  def self.new_group_push( message , app )
  	m = MessageQueue.new( 
  		:command_type => 2 ,
  		:token => "" ,
  		:message => message ,
  		:app => app 
  	)
  	m .save
  end
end
