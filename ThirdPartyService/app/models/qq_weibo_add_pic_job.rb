class QqWeiboAddPicJob
  @queue = :qq_weibo_queue

  def self.perform(access_token, open_id, content, lng, lat, img_file, client_ip)
    QqWeibo.add_pic(access_token, open_id, content, lng, lat, img_file, client_ip)
  end
end