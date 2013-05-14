class QqController < ApplicationController
  def get_user_info
    begin
      response = Qq.get_user_info(params[:token], params[:open_id])
      render :json => response
    rescue Exception => e
      render :json => {:error_msg => e.message}
    end
  end

  def get_weibo_info
    begin
      response = Qq.get_info(params[:token], params[:open_id])
      render :json => response
    rescue Exception => e
      render :json => {:error_msg => e.message}
    end
  end

  def add_pic_t
    begin
      response = Qq.add_pic_t(params[:token],params[:open_id],params[:content],params[:lng],params[:lat],params[:pic])
      render :json => response
    rescue Exception => e
      render :json => {:error_msg => e.message}
    end
  end

end
