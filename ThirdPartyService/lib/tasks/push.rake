task :start_push_monitor => :environment do
  File.open('./tmp/push_monitor.pid', 'w'){|f| f.puts Process.pid}
	APNS.working
end
