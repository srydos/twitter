#!/usr/bin/env ruby
# frozen_string_literal: true

WORK_DIR = File.expand_path('./', File.dirname(__FILE__))
require_relative 'Class/tetesol_twitter'
require_relative 'Class/tetesol_streaming'
require_relative 'Class/tetesol_bot.rb'
begin
  rest_client   = TetesolTwitter.new(WORK_DIR + '/Config/unko.yml')
  stream_client = TetesolStreaming.new(WORK_DIR + '/Config/stream.yml')

  # 最後に反応したtweet_idを取得
  last_saw_id = rest_client.read_textfile_or_new('Config/.last_saw_id')
  last_saw_id ||= '1' if last_saw_id.empty?
  last = last_saw_id.to_i

  # botクラス読み込み
  conver_bot = TetesolBot.new('Config/user.yml',
                              'Config/reaction-condition.yml')

  # replyから反応
  # replied_id = 1
  # monitored_tl = rest_client.mentions_timeline_bot(last_saw_id)
  # monitored_tl.reverse.each do |tweet|
  pp stream_client
  puts 'why nilclass...'
  exit
  stream_client.user do |event|
    pp event
    pp event.class
  end
  # replied_id = conver_bot.reaction(tweet) if !tweet.retweet?
  saw_id = conver_bot.reaction(event)
  last = saw_id < last ? last : saw_id if saw_id.is_a?(Integer)
rescue Interrupt
  puts '\nbot off.'
  # 最後のtweet_idを保存
  last_saw_id = last.to_s
  puts 'saw_id : #{last_saw_id}'
  rest_client.write_text_to_file(WORK_DIR + 'Config/.last_saw_id', last_saw_id)
end
