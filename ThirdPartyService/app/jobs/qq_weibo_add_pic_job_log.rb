class QqWeiboAddPicJobLog
  @@logger = Log4r::Logger.new "qq_weibo_add_pic_job_log"
  @@out_putter = Log4r::RollingFileOutputter.new('qq_weibo_add_pic_job_log', :filename =>  Rails.root.to_s + "/log/qq_weibo_add_pic_job.log", :maxtime=> 24*3600, :trunc => false)
  @@pattern_formatter = Log4r::PatternFormatter.new(:pattern => "%d %m\n")

  @@out_putter.formatter = @@pattern_formatter
  @@logger.outputters = @@out_putter

  def QqWeiboAddPicJobLog.log(msg)
    @@logger.info msg
  end
end