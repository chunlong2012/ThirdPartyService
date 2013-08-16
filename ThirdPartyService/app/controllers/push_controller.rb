def is_token_list?( s )
	begin
		JSON.parse( s ).kind_of?( Array )
	rescue
		false
	end
end

class PushController < ApplicationController
	# 向一系列用户发送push信息
	# 分别可以调用 /push/ios_push 或 /push/android_push
	# 传入参数 :
	#   token_list : 一个json数组，里面包含的每一个内容是一个token的字符串。如 ["token1","token2"] 请保证传递过来的参数是对的 (ô_ô)
	#   message : 发送的push的信息，一个字符串包含许多内容
	#   app : vida | vimi ，接受push的应用
	#   options : 一个其他设置的json对象，将会直接传递给app。如 {"u":{"t":"url","c":"vida://order-list"}}
	def ios_push
		render :text => false and return if !is_token_list?( params[ :token_list ] ) || params[ :message ] .nil? || ( /vida|vimi/ =~ params[ :app ] ) .nil?
		render :text => MessageQueue.new_single_push( params[ :token_list ] , params[ :message ] , params[ :app ] , 'ios' , params[ :options ] ) 
	end

	def android_push
		render :text => false and return if !is_token_list?( params[ :token_list ] ) || params[ :message ] .nil? || ( /vida|vimi/ =~ params[ :app ] ) .nil?
		render :text => MessageQueue.new_single_push( params[ :token_list ] , params[ :message ] , params[ :app ] , 'android' , params[ :options ] )
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