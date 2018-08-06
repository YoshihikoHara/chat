# Author       : Yoshihiko Hara <goronyanko.h@gmail.com>
# last updated : 2018/08/03
# Overview     : Conversation script using NTT docomo chat API.
#  * For an overview of chatting API, refer to the following URL.
#    https://dev.smt.docomo.ne.jp/?p=docs.api.page&api_name=natural_dialogue&p_name=api_4_usage_scenario#tag01
#  * Refer to the following URL for official reference of chat API.
#    https://dev.smt.docomo.ne.jp/?p=docs.api.page&api_name=natural_dialogue&p_name=api_4#tag01
#    https://dev.smt.docomo.ne.jp/?p=docs.api.page&api_name=natural_dialogue&p_name=api_4_user_registration#tag01
# License      : MIT License

require 'uri'
require 'json'
require 'openssl'
require 'net/http'

# Check flag whether OS is WINDOWS or not.
WINDOWS = true

# proxy
# If Proxy exists, add information about Proxy.
PROXY = true
if true == PROXY 
  proxy_addr = '<Proxy URL>'
  proxy_port = <Proxy Port>
  proxy_user = '<Proxy User Name>'
  proxy_pass = '<Proxy PassWord>'
end

# Base of URI for calling docomo API.
APIURI1 = 'https://api.apigw.smt.docomo.ne.jp/naturalChatting/v1/registration'
APIURI2 = 'https://api.apigw.smt.docomo.ne.jp/naturalChatting/v1/dialogue'
APIKEY = '<APIKey you got from NTT docomo>'

# Assemble the URI for calling docomo API.
uri1 = URI.parse("#{APIURI1}?APIKEY=#{APIKEY}")
uri2 = URI.parse("#{APIURI2}?APIKEY=#{APIKEY}")

# Get appId
# In order to guarantee the continuity of the conversation, acquire the appId before starting the conversation.
if true == PROXY
  # With proxy
  proxy = Net::HTTP::Proxy(proxy_addr, proxy_port, proxy_user, proxy_pass) 
  http = proxy.new(uri1.host, uri1.port)
else
  # No proxy
  http = Net::HTTP.new(uri1.host, uri1.port)
end

http.use_ssl = true
http.verify_mode = OpenSSL::SSL::VERIFY_NONE

# Assemble data to request appId
body = {
  "botId": "Chatting",
  "appKind": "Smart Phone"
}
request = Net::HTTP::Post.new(uri1.request_uri, {'Content-Type' =>'application/json'})
request.body = body.to_json
response = nil

# Request appId.
http.start do |h|
  resp = h.request(request)
  response = JSON.parse(resp.body)
end

# Store appId in variable.
appId = response['appId']

# Talk with the computer using chat API.
if true == PROXY
  # With proxy
  http = proxy.new(uri2.host, uri2.port)
else
  # No proxy
  http = Net::HTTP.new(uri2.host, uri2.port)
end

http.use_ssl = true
http.verify_mode = OpenSSL::SSL::VERIFY_NONE

# Assemble data to start chat.
body = {
  "language": "ja-JP",
  "botId": "Chatting", 
  "appId": "#{appId}",
  "voiceText": "こんにちわ"
}

# Start chatting.
# To terminate, enter [ctrl] + "c".
loop do
  request = Net::HTTP::Post.new(uri2.request_uri, {'Content-Type' =>'application/json'})

  request.body = body.to_json

  response = nil
  http.start do |h|
    resp = h.request(request)
    response = JSON.parse(resp.body)
  end

  puts "com > #{response['systemText']['utterance']}"
  print 'you > '
  word = gets

  # When running on Windows, perform character code conversion.
  if true == WINDOWS
    word = word.encode("UTF-8", "Shift_JIS")
  end

  body = {
    "language": "ja-JP",
    "botId": "Chatting", 
    "appId": "#{appId}",
    "voiceText": "#{word}"
  }

end
