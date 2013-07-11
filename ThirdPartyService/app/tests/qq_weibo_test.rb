class QqWeiboTest
  @@ACCESS_TOKEN = 'b487dc175f2f46b9e4dc48e77c4d03c6'
  @@OPEN_ID = '34b3e6c365a01269b8ea920a05fbfaa7'
  class << self
    def test_get_info
      puts QqWeibo.get_user_info(@@ACCESS_TOKEN,@@OPEN_ID)
      # response = RestClient.post "localhost:3000/qq/get_user_info",:token => @@ACCESS_TOKEN, :open_id => open_id
    end

    def test_add_pic
      pic = File.new("test.png","rb")
     # puts QqWeibo.add_pic(@@ACCESS_TOKEN,@@OPEN_ID,"test",nil,nil,pic,nil)
      response = RestClient.post "vida.fm:5000/qq_weibo/async_add_pic",:token => @@ACCESS_TOKEN, :open_id => @@OPEN_ID, :content => "test hello", :pic => pic
    end

    def test_upload_pic
      puts QqWeibo.upload_pic(@@ACCESS_TOKEN,@@OPEN_ID,"test.png")
    end

    def test_shorten_url
      puts QqWeibo.shorten_url(@@ACCESS_TOKEN,@@OPEN_ID,"http://vida.fm/moments/rich?id=2137007")
    end

    def test_add_rich
      jump_url = "http://vida.fm"
      jump_url = QqWeibo.shorten_url(@@ACCESS_TOKEN,@@OPEN_ID,jump_url)
      puts jump_url

      iframe_url = "http://vida.fm/moments/2175656"
     # iframe_url = QqWeibo.shorten_url(@@ACCESS_TOKEN,@@OPEN_ID,moment_url)
     # puts iframe_url

      androidcall = "http://vida.fm/d/android"
      iphonecall =  "https://itunes.apple.com/cn/app/id454984086?ls=1"

      QqWeibo.add_rich(@@ACCESS_TOKEN,@@OPEN_ID,"title","content test ycl ycl","introduce",nil,nil,nil,8,"test.jpg",jump_url,iframe_url,androidcall,iphonecall)
#      QqWeibo.add_rich(@@ACCESS_TOKEN,@@OPEN_ID,"title","content test ycl","introduce","42.96.139.12",nil,nil,8,"test.jpg",jump_url,iframe_url,androidcall,iphonecall)
    end
  end
end