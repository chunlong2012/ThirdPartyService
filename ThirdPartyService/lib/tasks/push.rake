task :start_push_monitor => :environment do
	File.open('./tmp/push_monitor.pid', 'w'){|f| f.puts Process.pid}
	MessageProcesser.start_working
end

def process_running( pid )
	begin
		pid > 0 && Process.getpgid( pid ) && true 
	rescue
		false
	end
end

task :push_process_monitor => :environment do
	while true
		pid = 0
		File.open('./tmp/push_monitor.pid', 'r'){ |f| pid = f.gets.to_i }
		unless process_running( pid ) && ( $redis.llen( MessageQueue.redis_code ) <= 10 )
			puts "There are something wrong"
		end
		sleep 60
	end
end
