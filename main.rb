require 'rubygems'
require 'sinatra'
require 'twilio-ruby'

set :bind, '0.0.0.0'

get '/' do
  Twilio::TwiML::Response.new do |r|
    r.Gather :numDigits => 1, :action => '/gather-en', :method => 'get', :timeout => 1 do |g|
      g.Play "https://efficacious-night-1129.twil.io/assets/Hi-EN.mp3"
    end
    r.Record :maxLength => '60', :action => '/record-en', :method => 'get'
  end.text
end

get '/gather-en' do
  if params['Digits'] == '1'
    response = Twilio::TwiML::Response.new do |r|
      r.Gather :numDigits => 1, :action => '/gather-cn', :method => 'get', :timeout => 1 do |g|
        g.Say '中文服务。', :language => "zh-CN"
        g.Say '我现在有空但是找不到手机。', :language => "zh-CN"
        g.Say '如果这是一个紧急情况，请按0 。', :language => "zh-CN"
        g.Say '否则，请留言，我会在找到手机后尽快回电。', :language => "zh-CN"
      end
      r.Record :maxLength => '60', :action => '/record-cn', :method => 'get'
    end
  elsif params['Digits'] == '0'
    response = Twilio::TwiML::Response.new do |r|
      r.Say 'Emergency Situation.'
      r.Say 'An emergency signal has been sent. If I do not respond to this message in 12 hours, it will be forwarded to nine one one.'
      r.Say 'Please leave a message.'
      r.Record :maxLength => '60', :action => '/record-en', :method => 'get'
    end
  else
    redirect to('/')
  end
  response.text
end

get '/gather-cn' do
  if params['Digits'] == '0'
    Twilio::TwiML::Response.new do |r|
      r.Say '紧急情况', :language => "zh-CN"
      r.Say '一个紧急讯号已被发送，如果我没有在12小时内响应，他将被转发到九幺幺。', :language => "zh-CN"
      r.Say '请留言。', :language => "zh-CN"
      r.Record :maxLength => '60', :action => '/record-cn', :method => 'get'
    end.text
  else
    redirect to('/')
  end
end

get '/record-en' do
  Twilio::TwiML::Response.new do |r|
    #r.Say 'Listen to your voicemail.'
    #r.Play params['RecordingUrl']
    r.Say 'Goodbye.'
  end.text
end

get '/record-cn' do
  Twilio::TwiML::Response.new do |r|
    #r.Say 'Listen to your voicemail.'
    #r.Play params['RecordingUrl']
    r.Say '再见。', :language => "zh-CN"
  end.text
end