#!/usr/bin/env ruby
# frozen_string_literal: true

WORK_DIR = File.expand_path('./', File.dirname(__FILE__))
require_relative 'Class/tetesol_twitter'
tweet_user = TetesolTwitter.new(WORK_DIR + '/Config/user.yml')
msg = ''
args = ARGV
target_tweet_id = 1

# 引数チェック
case args.length
when 0
  puts 'args:(reply target tweet_id)(text)'
  exit
when 1
  # reply対象idのバリデーション
  target_tweet_id = args[0].to_i
  if !target_tweet_id.is_a?(Integer) || target_tweet_id < 1
    puts 'target_tweet_id invalid!'
    exit
  end
  # replyIDだけが設定されていた場合は標準入力を受け取る
  print 'input massage! : '
  msg = STDIN.gets
else
  target_tweet_id = args.shift.to_i
  # 半角スペース対応
  Array(args).each { |text| msg += text + ' ' }
  msg[/ $/] = '' if msg[/ $/]
end
tweet = tweet_user.reply(target_tweet_id, msg)
tweet_user.tweet_print_console(tweet)
