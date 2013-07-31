class QqWeiboAddRichJob
  @queue = :qq_weibo_queue

  def self.perform(sync_history_id, callback, access_token, open_id, content, lng, lat, thumbnail_file, client_ip, title, introduce, jump_url, iframe_url,androidcall,iphonecall)
    QqWeiboAddRichJobLog.log "=======================================qq_add_rich: #{sync_history_id},#{access_token},#{open_id}=======================================================\n"
    QqWeiboAddRichJobLog.log "#{thumbnail_file}"

    begin
      response = QqWeibo.add_rich(access_token,open_id,title,content,introduce,client_ip,lat,lng,8,thumbnail_file,jump_url,iframe_url,androidcall,iphonecall)
      QqWeiboAddRichJobLog.log response
      result =  JSON.parse response
    rescue Exception=>e
      response = nil
      QqWeiboAddRichJobLog.log e.message
    end


    params = {}
    if response == nil
      params[:result] = 2
      params[:error_msg] = "third party service internal error!"
      QqWeiboAddRichJobLog.log  "third party service internal error!"
    elsif result["ret"] == 0
      params[:result] = 0
      params[:sync_history_id] = sync_history_id
      params[:remote_site_id]  = result["data"]["id"]
      QqWeiboAddRichJobLog.log  "add_rich success!"
    else
      params[:result] = 1
      params[:error_msg] = result["msg"]
      QqWeiboAddRichJobLog.log response
    end


    if !callback.blank?
      begin
        RestClient.get callback + "?" + params.to_query
      rescue Exception=>e
        QqWeiboAddRichJobLog.log "callback error: " + callback + ",  " + e.message
      end
    end

    `rm -f #{Rails.root.to_s + "/" + thumbnail_file}`
  end
end
