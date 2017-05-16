#!/usr/bin/env ruby
require 'twitter'
require 'Sanitize'
require 'yaml'
require 'pp'
class TetesolStreaming
  attr_accessor :client
  def initialize( key_file_path = "" )
    if not key_file_path.empty? then
      @key_hash = YAML.load_file( key_file_path )
      config = {
        consumer_key:        @key_hash['consumer_key'],
        consumer_secret:     @key_hash['consumer_secret'],
        access_token:        @key_hash['access_token'],
        access_token_secret: @key_hash['access_token_secret']
      }
      @stream = Twitter::Streaming::Client.new(config)
    else
      puts 'cannot read file_path...'
      exit
    end
  end
end
