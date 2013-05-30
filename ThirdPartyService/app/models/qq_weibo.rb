class QqWeibo
  #oauth 2.0
  class << self
     @@APP_ID = 801063700
     @@APP_SECRET = "61f513e3773bfefb23732e35698c85cf"
     @@SERVER = "https://open.t.qq.com"

     #weibo user info
     #access_token, open_id都由客户端传过来
     def get_user_info(access_token,open_id)
       params = {}
       params[:format] = 'json'
       params[:access_token] = access_token
       params[:oauth_consumer_key] = @@APP_ID
       params[:openid] = open_id
       params[:oauth_version] = '2.a'
       params[:scope] = 'all'

       url = @@SERVER + "/api/user/info?" + params.to_query
       response = RestClient.get url
     end

     def add_pic(access_token, open_id, content, lng, lat, img_file, client_ip)
       params = {:format => "json", :access_token => access_token, :oauth_consumer_key => @@APP_ID, :openid => open_id,
                 :oauth_version => '2.a', :scope => 'all',
                 :content => content, :pic => img_file}

       params[:clientip] = client_ip  unless client_ip != nil
       params[:longitude] = lng  unless lng != nil
       params[:latitude] = lat   unless lat != nil

       url = @@SERVER + "/api/t/add_pic"
       response = RestClient.post url, params
     end

  end
end