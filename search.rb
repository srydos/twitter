#!/usr/bin/env ruby
# frozen_string_literal: true

WORK_DIR = File.expand_path('./', File.dirname(__FILE__))
require_relative 'Class/tetesol_twitter'
search_user = TetesolTwitter.new(WORK_DIR + '/Config/user.yml')

if search_user.nil?
  puts 'user.yml is not found...'
  exit
end
# 最後に取得したツイートid取得
args = ARGV
case args.length
when 0
  puts 'what should i search...?'
  exit
when 1
  @count = 15
  query = args[0]
  begin
    timeline = search_user.popular_search(query, @count)
  rescue
    puts 'search request error...?'
  end
  search_user.tweet_to_yaml(timeline)
  exit
else
  msg = ''
  msg += '#' if args.delete('-h')
  args.each do |text|
    msg += text + ' '
  end
  msg[/ $/] = ''
  @count = 15
  query = msg.to_s
  begin
    timeline = search_user.popular_search(query, @count)
  rescue
    puts 'search request error...?'
  end
  search_user.tweet_print_console(timeline)
  search_user.tweet_print_yaml(timeline.to_h)
end
