class QqWeiboAddPicJob
  @queue = :qq_weibo_queue

  def self.perform(sync_history_id, call_back, access_token, open_id, content, lng, lat, img_file, client_ip)
    response = QqWeibo.add_pic(access_token, open_id, content, lng, lat, img_file, client_ip)
    result =  JSON.parse response

    params = {}
    if result[:ret] == 0
      params[:result] = 0
      params[:sync_history_id] = sync_history_id
      params[:remote_site_id]  = result[:data][:id]
      params[:remote_pic] = result[:imgurl]
    else
      params[:result] = 1
      params[:error_msg] = result[:msg]
    end

    RestClient.get call_back + "?" + params.to_query
  end
end