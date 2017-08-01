#!/usr/bin/env ruby
# frozen_string_literal: true

WORK_DIR = File.expand_path('./', File.dirname(__FILE__))
require_relative 'Class/tetesol_twitter'
require_relative 'Class/tetesol_streaming'
require_relative 'Class/tetesol_bot.rb'
begin
  rest_client   = TetesolTwitter.new(WORK_DIR + '/Config/unko.yml')
  stream_client = TetesolStreaming.new(WORK_DIR + '/Config/stream.yml')
  last_saw_id = "1"

  #使用機能判定
  args = ARGV
  func_name = ""
  func_name = "debug_mode" if args.delete("-d") or args.delete("-debug")
  #puts "func#{func_name}"

  #最後に反応したtweet_idを取得
  last_saw_id = rest_client.read_textfile_or_new(WORK_DIR + "Config/.last_saw_id")
  last_saw_id ="1" if last_saw_id.empty?
  last = last_saw_id.to_i

  #botクラス読み込み
  conver_bot = TetesolBot.new(WORK_DIR + "Config/user.yml", WORK_DIR + "Config/reaction-condition.yml")

  #replyから反応
  replied_id = 1
=begin
  monitored_tl = rest_client.mentions_timeline_bot(last_saw_id)
  monitored_tl.reverse.each do |tweet|
=end
pp stream_client
puts "why nilclass..."
exit
  stream_client.user do |event|
    pp event
    pp event.class
  end
    #replied_id = conver_bot.reaction(tweet) if !tweet.retweet?
    saw_id = conver_bot.reaction(event)
    last = (saw_id < last)? last : saw_id if saw_id.is_a?(Integer)

rescue Interrupt => e
  puts "\nbot off."
  #最後のtweet_idを保存
  last_saw_id = last.to_s
  puts "saw_id : #{last_saw_id}"
  rest_client.write_text_to_file(WORK_DIR + "Config/.last_saw_id", last_saw_id)
end
