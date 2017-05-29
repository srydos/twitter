#!/usr/bin/env ruby
###
# bot用の条件文を定義するクラス
###
class BotSetting
  attr_accessor :client, :condition, :reaction
  def initialize(client, cond_category, react_category_array)
    @client = client
    @condition = Condition.new(cond_category)
    @reaction  = []
    react_category_array.each { |item| @reaction.push(Reaction.new(item))}
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
    #hash = Hash.new
    condition_hash = {
            condition_category:    @condition.category,
            condition_text:        @condition.text,
            condition_probability: @condition.probability,
            condition_client:      @condition.client,
            condition_user:        @condition.user,
            condition_ng_user:     @condition.ng_user,
    }
    reaction_hash = {
            reaction_category:     @reaction.category,
            reaction_text:         @reaction.text,
            reaction_weight:       @reaction.weight,
            reaction_prefix:       @reaction.prefix,
            reaction_suffix:       @reaction.suffix
    }
    hash = {
            client:      @client,
            description: @description,
            condition:   condition_hash,
            reaction:    reaction_hash,
    }
    
    return hash
  end

  #to_hash
  alias to_hash to_h

  #hashファイルからBotSetting生成
  def make_from_hash(hash)
    @client      = hash[:client]
    @description = hash[:description]
    @condition   = hash[:condition]
    @reaction    = hash[:reaction]
    #@condition.category    = hash[:condition_category]
    #@condition.text        = hash[:condition_text]
    #@condition.probability = hash[:condition_probability]
    #@condition.client      = hash[:condition_client]
    #@condition.user        = hash[:condition_userclient]
    #@condition.ng_user     = hash[:condition_ng_user]
    #@reaction.category     = hash[:reaction_category]
    #@reaction.text         = hash[:reaction_text]
    #@reaction.weight       = hash[:reaction_weight]
    #@reaction.prefix       = hash[:reaction_prefix]
    #@reaction.suffix       = hash[:reaction_suffix]
  end

  #to_s
  def to_s
    return "#{@client}::#{@description}"
  end
end
