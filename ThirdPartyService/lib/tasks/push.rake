task :start_push_monitor => :environment do
	APNS.start_working
end
