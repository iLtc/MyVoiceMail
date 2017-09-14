require 'rubygems'
require 'sinatra'
require 'twilio-ruby'

set :bind, '0.0.0.0'

get '/' do
  response = Twilio::TwiML::VoiceResponse.new
  response.gather(input: 'dtmf', timeout: 1, num_digits: 1, action: '/gather-en', method: 'GET') do |gather|
    gather.play(url: 'https://efficacious-night-1129.twil.io/assets/Hi-EN.mp3')
  end
  response.record(maxLength: 180, transcribe: true, action: '/record-en', method: 'GET')
  response.to_xml
end

get '/gather-en' do
  response = Twilio::TwiML::VoiceResponse.new
  if params['Digits'] == '1'
    response.gather(input: 'dtmf', timeout: 1, num_digits: 1, action: '/gather-cn', method: 'GET') do |gather|
      gather.say('中文服务。', language: 'zh-CN')
      gather.say('我现在有空但是找不到手机。', language: 'zh-CN')
      gather.say('如果这是一个紧急情况，请按0 。', language: 'zh-CN')
      gather.say('否则，请留言，我会在找到手机后尽快回电。', language: 'zh-CN')
    end
    response.record(maxLength: 180, transcribe: true, action: '/record-cn', method: 'GET')
  elsif params['Digits'] == '0'
    response.say('Emergency Situation.')
    response.say('An emergency signal has been sent. If I do not respond to this message in 12 hours, it will be forwarded to nine one one.')
    response.say('Please leave a message.')
    response.record(maxLength: 180, transcribe: true, action: '/record-en', method: 'GET')
  else
    redirect to('/')
  end
  response.to_xml
end

get '/gather-cn' do
  if params['Digits'] == '0'
    response = Twilio::TwiML::VoiceResponse.new
    response.say('紧急情况。', language: 'zh-CN')
    response.say('一个紧急讯号已被发送，如果我没有在12小时内响应，他将被转发到九幺幺。', language: 'zh-CN')
    response.say('请留言。', language: 'zh-CN')
    response.record(maxLength: 180, transcribe: true, action: '/record-cn', method: 'GET')
    response.to_xml
  else
    redirect to('/')
  end
end

get '/record-en' do
  response = Twilio::TwiML::VoiceResponse.new
  response.say('Goodbye')
  response.to_xml
end

get '/record-cn' do
  response = Twilio::TwiML::VoiceResponse.new
  response.say('再见。', language: 'zh-CN')
  response.to_xml
end