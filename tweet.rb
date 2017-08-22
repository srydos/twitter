#!/usr/bin/env ruby
# frozen_string_literal: true

WORK_DIR = File.expand_path('./', File.dirname(__FILE__))
require_relative 'class/tetesol_twitter'
tweet_user = TetesolTwitter.new(WORK_DIR + '/config/user.yml')

msg = ''
args = ARGV
args.each do |text|
  msg += text + ' '
end
if args.empty?
  print 'input massage! : '
  msg = STDIN.gets
end
msg.lstrip
begin
  tweet = tweet_user.tweet(msg)
  tweet_user.tweet_print_console(tweet)
rescue
  puts 'tweet error!'
  exit
end
