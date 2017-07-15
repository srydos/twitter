#!/usr/bin/env ruby
WORK_DIR=File.expand_path(__FILE__).sub(/[^\/]+$/,'')
require WORK_DIR + 'Class/TetesolTwitter.rb'
twitter_user = TetesolTwitter.new(WORK_DIR + 'Config/user.yml')

args = ARGV
if args.length > 2
  puts 'too many args...'
  exit
elsif args[0].nil? or args[0].empty?
  print "arg : (reaction_target_id)"
  exit
end
target_tweet_id = args[0]
twitter_user.status target_tweet_id
