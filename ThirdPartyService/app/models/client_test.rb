class ClientTest
  class << self
    #qq: 272142606
    @@ACCESS_TOKEN = "4CC04300BE65895837ED2ADF6E1188E8&expires_in=7776000"

    def get_access_token
      @@ACCESS_TOKEN
    end

    def get_open_id
      response = RestClient.get "https://graph.qq.com/oauth2.0/me?access_token=" + @@ACCESS_TOKEN
      body = response.body
      body = body.slice(10,body.size - 10 - 4)
      result = JSON.parse(body)
      result["openid"]
    end

  end
end