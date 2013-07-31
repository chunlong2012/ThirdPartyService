class PushController < ApplicationController

	def ios_push
		render :text => false and return if params[ :token ] .nil? || params[ :message ] .nil? || ( /vida|vimi/ =~ params[ :app ] ) .nil?
		render :text => MessageQueue.new_single_push( params[ :token ] , params[ :message ] , params[ :app ] , 'ios' ) 
	end

	def android_push
		render :text => false and return if params[ :token ] .nil? || params[ :message ] .nil? || ( /vida|vimi/ =~ params[ :app ] ) .nil?
		render :text => MessageQueue.new_single_push( params[ :token ] , params[ :message ] , params[ :app ] , 'android' )
	end

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
end
