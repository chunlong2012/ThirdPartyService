class QqWeiboAddPicJob
  @queue = :qq_weibo_queue

  def self.perform(sync_history_id, call_back, access_token, open_id, content, lng, lat, img_file, client_ip)
    QqWeiboAddPicJobLog "=======================================#{sync_history_id},#{access_token},#{open_id}=======================================================\n"
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
      QqWeiboAddPicJobLog  "third party service internal error!"
    elsif result[:ret] == 0
      params[:result] = 0
      params[:sync_history_id] = sync_history_id
      params[:remote_site_id]  = result[:data][:id]
      params[:remote_pic] = result[:imgurl]
    else
      params[:result] = 1
      params[:error_msg] = result[:msg]
      QqWeiboAddPicJobLog response
    end

    if !call_back.brank?
      begin
        RestClient.get call_back + "?" + params.to_query
      rescue Exception=>e
        QqWeiboAddPicJobLog "call_back error: " + call_back + ",  " + e.message
      end
    end
  end
end