#!/usr/bin/env ruby
# frozen_string_literal: true

WORK_DIR = File.expand_path('./', File.dirname(__FILE__))
require_relative 'Class/tetesol_twitter'
twitter_user = TetesolTwitter.new(WORK_DIR + '/Config/user.yml')

args = ARGV
if args.length > 2
  puts 'too many args...'
  exit
elsif args[0].nil? || args[0].empty?
  print 'arg : (reaction_target_id)'
  exit
end
target_tweet_id = args[0]
twitter_user.status target_tweet_id
