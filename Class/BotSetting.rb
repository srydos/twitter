#!/usr/bin/env ruby
require 'OpenStruct'
###
# bot用の条件文を定義するクラス
###
class BotSetting < OpenStruct
  attr_accessor :condition, :reaction
  def initialize(client, cond_category, react_category)
    @client = client
    @condition = Condition.new(cond_category)
    @reaction  = Reaction.new(react_category)
  end
  class Condition
    attr_accessor :category, :condition_text, :probability, :clinet, :user, :ng_user
    def initialize(category)
      @category = category
    end
  end
  class Reaction
    attr_accessor :category
    def initialize(category)
      @category = category
    end
    def set_reply(texts)
      @reply = Reply.new
    end
    class Reply
      attr_accessor :reaction_text, :weight, :prefix, :suffix
      def initialize(texts)
        @reaction_text = texts
      end
    end
  end


  #to_h
  def to_h
    hash = Hash.new

    return hash
  end

  #to_s
  def to_s
    return "#{@client}::#{@description}"
  end
end
