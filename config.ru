require "rubygems"
require "bundler/setup"
require "sinatra"
require "sinatra/json"
require "net/https"
require "base64"

class PhoneTap < Sinatra::Base
  helpers Sinatra::JSON

  get '/bug/:name/:base64' do
    push("#{params[:name]} from #{request.ip}")

    # Only works with HTTP, because I'm lazy
    url = URI.parse(Base64.decode64(params[:base64]))
    resp = Net::HTTP.get_response(url)
    content_type resp["Content-Type"]
    return resp.body
  end

  def push(message)
    url = URI.parse("https://api.pushover.net/1/messages.json")
    req = Net::HTTP::Post.new(url.path)
    req.set_form_data({
      :token => ENV["PUSHOVER_APP_TOKEN"],
      :user => ENV["PUSHOVER_USER_KEY"],
      :message => message,
    })
    res = Net::HTTP.new(url.host, url.port)
    res.use_ssl = true
    res.verify_mode = OpenSSL::SSL::VERIFY_PEER
    res.start {|http| http.request(req) }
  end
end

run PhoneTap
