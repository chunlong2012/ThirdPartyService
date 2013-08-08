def is_token_list?( s )
	begin
		JSON.parse( s ).kind_of?( Array )
	rescue
		false
	end
end

class PushController < ApplicationController
	def ios_push
		render :text => false and return if !is_token_list?( params[ :token_list ] ) || params[ :message ] .nil? || ( /vida|vimi/ =~ params[ :app ] ) .nil?
		render :text => MessageQueue.new_single_push( params[ :token_list ] , params[ :message ] , params[ :app ] , 'ios' ) 
	end

	def android_push
		render :text => false and return if !is_token_list?( params[ :token_list ] ) || params[ :message ] .nil? || ( /vida|vimi/ =~ params[ :app ] ) .nil?
		render :text => MessageQueue.new_single_push( params[ :token_list ] , params[ :message ] , params[ :app ] , 'android' )
	end

=begin
	def add_token
		# 必然需要 device 以及 app 信息
		render :text => false and return if params[ :token ] .nil? || ( /ios|android/ =~ params[ :device ] ) .nil? || ( /vida|vimi/ =~ params[ :app ] ) .nil?
		render :text => Token.new_token( params[ :token ] , params[ :device ] , params[ :app ] )
	end

	def group_push
		# params[ :device ] 为空则会发送ios以及android
		render :text => false and return if params[ :message ] .nil? || ( /vida|vimi/ =~ params[ :app ] ) .nil?
		render :text => MessageQueue.new_group_push( params[ :message ] , params[ :app ] , params[ :device ] )
	end
=end

end