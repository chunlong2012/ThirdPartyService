#echo `RAILS_ENV=production bundle exec thin stop -d `
#echo `RAILS_ENV=production bundle exec thin start -d `
#./unicorn restart
#./unicorn stop
#sleep 5
#./unicorn start
#bundle exec thin restart -d -p 6000

kill -9 $(cat ./tmp/pids/unicorn.pid)
bundle exec unicorn -c ./config/unicorn.rb -D -E development

kill -9 $(cat ./tmp/resque.pid)
bundle exec rake resque:work QUEUE=qq_weibo_queue BACKGROUND=yes PIDFILE=./tmp/resque.pid

kill -9 $(cat ./tmp/push_monitor.pid)
bundle exec rake start_push_monitor &

