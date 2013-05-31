class PushController < ApplicationController

	def single_push
		render :text => -1 and return if params[ :token ] .nil? || params[ :message ] .nil? || ( /vida|vimi/ =~ params[ :app ] ) .nil?
		render :text => MessageQueue.new_ios_push( params[ :token ] , params[ :message ] , params[ :app ] ) 
	end

	def add_token
		render :text => -1 and return if params[ :token ] .nil? || ( /ios|android/ =~ params[ :device ] ) .nil? || ( /vida|vimi/ =~ params[ :app ] ) .nil?
		render :text => Token.new_token( params[ :token ] , params[ :device ] , params[ :app ] )
	end

	def group_push
		render :text => -1 and return if params[ :message ] .nil? || ( /vida|vimi/ =~ params[ :app ] ) .nil?
		render :text => MessageQueue.new_group_push( params[ :message ] , params[ :app ] ) 
	end
end
