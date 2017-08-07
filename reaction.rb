#!/usr/bin/env ruby
# frozen_string_literal: true

WORK_DIR = File.expand_path('./', File.dirname(__FILE__))
require_relative 'class/tetesol_twitter'

###
# tweetに対してfav rt del のいずれかの操作を行う
###
twitter_user = TetesolTwitter.new(WORK_DIR + '/config/user.yml')

args = ARGV
if args.length > 2
  puts 'too many args...'
  exit
end
if args[0].nil? || args[0].empty?
  print 'arg : (reaction_target_id)'
  exit
end
# 引数によって操作を選択
func_name = ''
func_name = 'delete'   if args.delete('-d') || args.delete('-delete')
func_name = 'retweet'  if args.delete('-r') || args.delete('-retweet')
func_name = 'favorite' if args.delete('-f') || args.delete('-favorite')
target_tweet_id = args[0]
puts '\'' + func_name + '\' doing...'
begin
  case func_name
  when 'retweet'
    result = twitter_user.retweet(target_tweet_id)
  when 'favorite'
    result = twitter_user.favorite(target_tweet_id)
    if result.empty?
      result = twitter_user.unfavorite(target_tweet_id)
      puts 'unfav.'
    else
      puts 'fav.'
    end
  when 'delete'
    result = twitter_user.delete(target_tweet_id)
    puts 'deleted.'
  else
    puts 'hmm... what method?'
  end
  puts 'done!'
rescue
  puts 'reaction error!'
  exit
end

# 帰ってきたツイート配列の中身を表示
result.each do |tweet|
  twitter_user.tweet_print_console(tweet)
end
