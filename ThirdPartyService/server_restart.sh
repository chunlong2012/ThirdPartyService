#echo `RAILS_ENV=production bundle exec thin stop -d `
#echo `RAILS_ENV=production bundle exec thin start -d `
#./unicorn restart
./unicorn stop
sleep 5
./unicorn start
kill -9 $(cat ./resque.pid)
rake resque:work QUEUE=qq_weibo_queue BACKGROUND=yes PIDFILE=./resque.pid
