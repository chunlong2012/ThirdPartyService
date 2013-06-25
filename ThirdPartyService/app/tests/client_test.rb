class ClientTest
  class << self
    #qq: 272142606
    #open mobile, 而不是graph
    @@ACCESS_TOKEN = "FC5D2E01E6CAD589917A0C6DC29FF307"

    def test_get_user_info
      open_id = Qq.get_open_id(@@ACCESS_TOKEN)
      puts Qq.get_user_info(@@ACCESS_TOKEN,open_id)
     # response = RestClient.post "localhost:3000/qq/get_user_info",:token => @@ACCESS_TOKEN, :open_id => open_id
    end

    def test_get_info
      open_id = Qq.get_open_id(@@ACCESS_TOKEN)
      puts Qq.get_info(@@ACCESS_TOKEN,open_id)
      # response = RestClient.post "localhost:3000/qq/get_user_info",:token => @@ACCESS_TOKEN, :open_id => open_id
    end

    def test_add_pic_t
      open_id = Qq.get_open_id(@@ACCESS_TOKEN)
      pic = File.new("test.png","rb")
     # puts QQ.add_pic_t(@@ACCESS_TOKEN,open_id,"test",pic)

      response = RestClient.post "localhost:3000/qq/add_pic_t",:token => @@ACCESS_TOKEN, :open_id => open_id, :content => "test hello", :pic => pic
    end

    def test_list_album
      open_id = Qq.get_open_id(@@ACCESS_TOKEN)
      puts Qq.list_album(@@ACCESS_TOKEN,open_id)
    end

    def test_anroid_push
      token = "3f5afc260a39b454ed2d20da02703851"
      message = "hello_world"
      RestClient.post "http://vimi.in:6000/push/android_push", :token => token, :message => message, :app=>"vimi"
    end
  end


end