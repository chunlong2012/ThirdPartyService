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
      file_name = "public/" + params[:sync_history_id].to_s
      File.open(file_name,"wb") do |f|
        f.write(params[:pic].read)
      end

      Resque.enqueue(QqWeiboAddPicJob,params[:sync_history_id],params[:callback],params[:token],params[:open_id],params[:content],params[:lng],params[:lat],file_name,params[:clientip])
      render :json => {:success => true}
  end

  def async_add_rich
     thumbnail_file = "public/rich_" + params[:sync_history_id].to_s
     File.open(file_name,"wb") do |f|
       f.write(params[:pic].read)
     end

     Resque.enqueue(QqWeiboAddRichJob,params[:sync_history_id],params[:callback],params[:token],params[:open_id],params[:content],params[:lng],params[:lat],thumbnail_file,params[:clientip],
                    params[:title],params[:introduce],params[:jump_url],params[:iframe_url],params[:androidcall],params[:iphonecall])
     render :json => {:success => true}
  end
end

