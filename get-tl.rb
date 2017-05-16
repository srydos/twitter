#!/usr/bin/env ruby
WORK_DIR=File.expand_path(__FILE__).sub(/[^\/]+$/,'')
require WORK_DIR + './Class/TetesolTwitter.rb'
twitter_user = TetesolTwitter.new(WORK_DIR + 'Config/user.yml')

args = ARGV
func_name = ""
#引数で取って来るTLを判断
func_name = "all"     if args.delete("-a") or args.delete("-all")
func_name = "me"      if args.delete("-m") or args.delete("-me")
func_name = "mention" if args.delete("-@") or args.delete("-mention")
if args.delete("-u") or args.delete("-user") then
  func_name = "user"
  user_arr  = args
end
#引数判断
case args.length
when 0..10
  last_tweet_id = "1"
  case func_name
  when "all"
    timeline = twitter_user.home_timeline(last_tweet_id)
    twitter_user.tweets_print_console(timeline, last_tweet_id)
  when "mention"
    timeline = twitter_user.mentions_timeline
    twitter_user.tweets_print_console(timeline, last_tweet_id)
  when "me"
    timeline = twitter_user.my_timeline
    twitter_user.tweets_print_console(timeline, last_tweet_id)
  when "user"
    len = user_arr.length 
    user_arr.each do |user|
      if not len = 0..1 then
        puts 'press Enter...print TL user is ' + user
        STDIN.gets
      end
      timeline = twitter_user.user_timeline(user_arr)
      twitter_user.tweets_print_console(timeline, last_tweet_id)
    end
  else
    #最後に取得したツイートid取得
    last_tweet_id = twitter_user.read_or_make_text_file(WORK_DIR + "/Config/.last_tweet_id")
    last_tweet_id = "1" if last_tweet_id.empty?
    timeline = twitter_user.home_timeline( last_tweet_id )
    last_tweet_id = twitter_user.tweets_print_console(timeline, last_tweet_id) #見え方悪いけど合理的　直す？
    twitter_user.write_text_to_file(WORK_DIR + "/Config/.last_tweet_id", last_tweet_id)
  end
else
  puts "too many args!"
  exit
end
