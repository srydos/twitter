#!/usr/bin/env ruby
WORK_DIR=File.expand_path(__FILE__).sub(/[^\/]+$/,'')
require WORK_DIR + 'Class/TetesolTwitter.rb'
tweet_user = TetesolTwitter.new(WORK_DIR + 'Config/user.yml')
msg = ''
#reply対象idのバリデーション
target_tweet_id = ARGV[0].to_i
if !target_tweet_id.is_a?(Integer) or target_tweet_id == 0 then
  puts 'target_tweet_id invalid!'
  exit
end

#引数チェック
if ARGV.length < 1 then
  puts 'args:(reply target tweet_id)(text)'
  exit
end

#replyIDだけが設定されていた場合は標準入力を受け取る
if ARGV[1] == nil or ARGV[1] == '' then
  print "input massage! : "
  msg=STDIN.gets
elsif ARGV.length >= 3 then
  #半角スペース対応
  tweet_text = ARGV
  tweet_text.shift.each do | text |
    msg += text + ' '
  end
  msg[/ $/]= ''
else 
  msg = ARGV[1]
end
tweet = tweet_user.reply(target_tweet_id, msg)
tweet_user.tweet_print_console(tweet)
