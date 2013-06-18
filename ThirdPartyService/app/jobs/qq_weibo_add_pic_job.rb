class QqWeiboAddPicJob
  @queue = :qq_weibo_queue

  def self.perform(sync_history_id, callback, access_token, open_id, content, lng, lat, img_file, client_ip)
    QqWeiboAddPicJobLog.log "=======================================#{sync_history_id},#{access_token},#{open_id}=======================================================\n"
    QqWeiboAddPicJobLog.log "#{img_file}"

    begin
      response = QqWeibo.add_pic(access_token, open_id, content, lng, lat, img_file, client_ip)
      result =  JSON.parse response
    rescue
      response = nil
    end

    params = {}
    if response == nil
      params[:result] = 2
      params[:error_msg] = "third party service internal error!"
      QqWeiboAddPicJobLog.log  "third party service internal error!"
    elsif result["ret"] == 0
      params[:result] = 0
      params[:sync_history_id] = sync_history_id
      params[:remote_site_id]  = result["data"]["id"]
      params[:remote_pic] = result["imgurl"]
    else
      params[:result] = 1
      params[:error_msg] = result["msg"]
      QqWeiboAddPicJobLog.log response
    end

    if !callback.blank?
      begin
        RestClient.get callback + "?" + params.to_query
      rescue Exception=>e
        QqWeiboAddPicJobLog.log "callback error: " + callback + ",  " + e.message
      end
    end

    `rm -f #{Rails.root.to_s + "/" + img_file}`
  end
end