#!/usr/bin/env ruby
WORK_DIR=File.expand_path(__FILE__).sub(/[^\/]+$/,'')
require WORK_DIR + 'Class/TetesolTwitter.rb'
twitter_user = TetesolTwitter.new(WORK_DIR + 'Config/user.yml')

args = ARGV
if args.length > 2 then
  puts 'too many args...'
  exit
end
if args[0] == nil or args[0] == '' then
  print "arg : (reaction_target_id)"
  exit
end
#引数によって操作を選択
func_name = "status"
#func_name = "status"   if args.delete("-s") or args.delete("-status")
target_tweet_id = args[0]
#puts "\"" + func_name + "\" doing..."
#begin
  case func_name 
  when "status"
    twitter_user.status(target_tweet_id)
  else
    puts "hmm... what method?"
  end
#rescue
#  puts 'reaction error!'
  exit
#end
