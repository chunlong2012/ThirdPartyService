#encoding: utf-8
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

     #{"data":{"id":"264083075336830","time":1370415584},
     #"errcode":0,"imgurl":"http:\/\/t1.qpic.cn\/mblogpic\/154ac425f86742daec38","msg":"ok","ret":0,"seqid":5885890110916371426}
     def add_pic(access_token, open_id, content, lng, lat, img_file, client_ip)
       params = {:format => "json", :access_token => access_token, :oauth_consumer_key => @@APP_ID, :openid => open_id,
                 :oauth_version => '2.a', :scope => 'all',
                 :content => content, :pic => File.new(img_file,"rb")}

       params[:clientip] = client_ip  unless client_ip != nil
       params[:longitude] = lng  unless lng != nil
       params[:latitude] = lat   unless lat != nil

       url = @@SERVER + "/api/t/add_pic"
       response = RestClient.post url, params
     end

     def upload_pic(access_token,open_id,img_file)
       params = {:format => "json", :access_token => access_token, :oauth_consumer_key => @@APP_ID, :openid => open_id,
                 :oauth_version => '2.a', :scope => 'all',
                 :pic_type => 2, :pic => File.new(img_file,"rb")}
       url = @@SERVER + "/api/t/upload_pic"

       begin
          response = RestClient.post url, params
          result = JSON.parse response
       rescue
          result = nil
       end

       if result == nil || result["ret"] != 0
         return nil
       end

       return result["data"]["imgurl"]
     end

     #url必须以http://打头，url中可以带参数
     def shorten_url(access_token,open_id,long_url)
       params = {:format => "json", :access_token => access_token, :oauth_consumer_key => @@APP_ID, :openid => open_id,
                 :oauth_version => '2.a', :scope => 'all',
                 :long_url => long_url}
       url = @@SERVER + "/api/short_url/shorten"

       begin
         response = RestClient.get url + "?" + params.to_query
         result = JSON.parse response
       rescue Exception => e
         result = nil
       end

       if result == nil || result["ret"] != 0
         return nil
       end

       return "http://url.cn/" + result["data"]["short_url"]
     end

     def add_rich(access_token,open_id,title,content,introduce,clientip,lat,lng,type,img_file,jump_url,iframe_url,androidcall,iphonecall)
       params = {:format => "json", :access_token => access_token, :oauth_consumer_key => @@APP_ID, :openid => open_id,
                 :oauth_version => '2.a', :scope => 'all',
                 :title => title, :content => content, :introduce => introduce, :clientip => clientip, :type => type
                }

       params[:longitude] = lng  unless lng != nil
       params[:latitude] = lat   unless lat != nil

       puts "img_url begin"
       img_url = QqWeibo.upload_pic(access_token,open_id,img_file)
       puts img_url


       params[:img_url] = img_url
       params[:jump_url] = jump_url
       params[:iframe_url] = iframe_url
       params[:androidcall] = androidcall
       params[:iphonecall] = iphonecall

       puts params

       url =  "https://open.t.qq.com"  + "/api/t/add_rich"

       begin
         response = RestClient.post url,params
         puts response
         result = JSON.parse response
       rescue Exception => e
         result = nil
         puts e.message
       end

     end

  end
end