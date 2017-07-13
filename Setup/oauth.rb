require 'oauth'
require 'oauth/consumer'
require 'fileutils'
require 'yaml'

if (ARGV.length < 2) then
  puts "require args (consumer_key) (consumer_secret_key)\'"
  exit
end

consumer_key = ARGV[0]
consumer_secret = ARGV[1]
yaml_name = ARGV[2] || "user"

consumer = OAuth::Consumer.new(consumer_key, consumer_secret, {site: "https://api.twitter.com"})
request_token = consumer.get_request_token

puts "get pin in this url"
puts  request_token.authorize_url
#urlにアクセスしてから
sleep 5
print "input PIN : "
pin = STDIN.gets

access_token = request_token.get_access_token(:oauth_verifier => pin)

key_hash = {
  consumer_key:       consumer_key,
  consumer_secret:    consumer_secret,
  access_token:       access_token.token,
  access_token_secret:access_token.secret
}

# Configディレクトリ準備
config_path = File.expand_path(__FILE__).sub(/[^\/]+$/,'') + "../Config"
FileUtils.mkdir_p(config_path) unless File.exist?(config_path)

open("#{config_path}/#{yaml_name}.yml","w+") do |yml|
  YAML.dump(key_hash, yml)
end

puts "#{File.expand_path(config_path)}/#{yaml_name}.yml"
