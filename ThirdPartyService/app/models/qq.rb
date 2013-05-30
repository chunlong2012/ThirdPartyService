#encoding=utf-8
class Qq
  class << self
    #QQ互联的app id, 而不是腾讯开放平台的app id
    @@APP_ID = 100445139
    @@SERVER = "https://openmobile.qq.com"

    def get_open_id(access_token)
      response = RestClient.get "https://graph.qq.com/oauth2.0/me?access_token=" + access_token
      body = response.body
      body = body.slice(10,body.size - 10 - 4)
      result = JSON.parse(body)
      result["openid"]
    end

    #qq以及qq空间的相关信息
    def get_user_info(access_token,open_id)
      url = @@SERVER + "/user/get_user_info?" + "access_token=" + access_token + "&oauth_consumer_key=" + @@APP_ID.to_s + "&openid=" + open_id
      response = RestClient.get url
    end

    #腾讯微博的相关信息
    def get_info(access_token,open_id)
      url = @@SERVER + "/user/get_info?" + "access_token=" + access_token + "&oauth_consumer_key=" + @@APP_ID.to_s + "&openid=" + open_id
      response = RestClient.get url
    end

    #分享一张照片到腾讯微博
    def add_pic_t(access_token,open_id, content, lng, lat, img_file)
      url =  @@SERVER + "/t/add_pic_t"

      params = {:access_token => access_token, :oauth_consumer_key => @@APP_ID, :openid => open_id,
                 :content => content, :pic => img_file }
      if lng != nil
        params[:longitude] = lng
      end
      if lat != nil
        params[:latitude] = lat
      end

      response = RestClient.post url, params
  end

    def list_album(access_token,open_id)
      url = @@SERVER + "/photo/list_album"
      auth = "?access_token=" + access_token + "&oauth_consumer_key=" + @@APP_ID.to_s + "&openid=" + open_id
      response = RestClient.get url+auth
    end
  end
end