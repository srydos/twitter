# frozen_string_literal: true

require 'twitter'
require 'yaml'
require 'pp'
# ててそるでストリーミングを使う時に読み込むクラス
class TetesolStreaming
  attr_accessor :client
  def initialize(key_file_path = '../Config/user.yml')
    @key_hash = YAML.load_file(key_file_path)
    config = {
      consumer_key:        @key_hash[:consumer_key],
      consumer_secret:     @key_hash[:consumer_secret],
      access_token:        @key_hash[:access_token],
      access_token_secret: @key_hash[:access_token_secret]
    }
    @client = Twitter::Streaming::Client.new(config)
  end

  def user
    @client.user
  end
end
