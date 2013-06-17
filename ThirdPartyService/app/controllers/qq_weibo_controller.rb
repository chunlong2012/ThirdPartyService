class QqWeiboController < ApplicationController
  def get_user_info
    begin
      response = QqWeibo.get_user_info(params[:token], params[:open_id])
      render :json => response
    rescue Exception => e
      render :json => {:error_msg => e.message}
    end
  end

  def async_add_pic
      file_name = "public/" + UUIDTools::UUID.timestamp_create.to_s
      File.open(file_name,"wb") do |f|
        f.write(params[:pic].read)
      end

      Resque.enqueue(QqWeiboAddPicJob,params[:sync_history_id],params[:callback],params[:token],params[:open_id],params[:content],params[:lng],params[:lat],file_name,params[:clientip])
      render :json => {:success => true}
  end
end

