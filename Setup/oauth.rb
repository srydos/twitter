#!/usr/bin/env ruby
WORK_DIR=File.expand_path(__FILE__).sub(/[^\/]+$/,'')
require 'oauth'
require 'oauth/consumer'
require 'YAML'
if (ARGV.length != 2) then
  puts "require args (consumer_key) (consumer_secret_key)\'"
  exit
end
@consumer_key = ARGV[0]
@consumer_secret = ARGV[1]
@consumer = OAuth::Consumer.new( @consumer_key.to_s, @consumer_secret.to_s, {
    :site=>"https://api.twitter.com"
    })
@request_token = @consumer.get_request_token
puts "get pin in this url"
puts  @request_token.authorize_url
#urlにアクセスしてから
print "input PIN : "
pin = STDIN.gets
@access_token = @request_token.get_access_token(:oauth_verifier => pin)
key_hash = { 
  'consumer_key'=>		@consumer_key,
  'consumer_secret'=>		@consumer_secret,
  'access_token'=>		@access_token.token,
  'access_token_secret'=>	@access_token.secret
}

print 'this client called ... : '
name = STDIN.gets.chomp
export_path = "#{WORK_DIR}../Config/#{name}.yml"
if File.exist?(export_path)
  print "#{export_path} is already exist! \noverwrite? type \"yes\" :"
  ans = STDIN.gets.chomp
  print 'ok. no action.' unless ans.eql?("yes")
  exit unless ans.eql?("yes")
end
open("#{WORK_DIR}../Config/#{name}.yml","w+") do |e|
  YAML.dump(key_hash,e)
end
puts "#{name}.yml exported."
