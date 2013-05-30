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
      Resque.enqueue(QqWeiboAddPicJob,params[:token],params[:open_id],params[:content],params[:lng],params[:lat],params[:pic],params[:clientip])
      render :json => {:success => true}
  end

  def test
    render :text=>"qq weibo test"
  end
end
