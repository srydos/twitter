#!/usr/bin/env ruby
###
# bot用の条件文を定義するクラス
###
class BotSetting < Hash
  attr_accessor :condition, :reactions
  def initialize(condition_hash, reaction_array)
    h = condition_hash
    @@con = Struct.new('Condition', :category, :condition_texts, :client, :user, :ng_user, :probability)
    @@rea = Struct.new('Reaction' , :category, :replies)
    @@rep = Struct.new('Reply' , :reaction_texts, :weight, :prefix, :suffix)
    @@els = Struct.new('Else'  , :category , :replies)
    @condition = con.new(h[:category], h[:condition_texts], h[:client], h[:user], h[:ng_user], h[:probability])
    reaction_array.each do |h|
      #リアクションの配列かく
      @reactions.unshift(rea.new(h[:category], rep, els))
    end
  end

=begin
  #to_h
  def to_h
    #hash = Hash.new
    condition_hash = {
            condition_category:    @condition.category,
            condition_text:        @condition.condition_text,
            condition_probability: @condition.probability,
            condition_client:      @condition.client,
            condition_user:        @condition.user,
            condition_ng_user:     @condition.ng_user,
    }
    reaction_hash = {
            reaction_category:     @reaction.category,
            reaction_text:         @reaction.reaction_text,
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
=end

  #hashファイルからBotSetting生成
  def make_from_hash(hash)
    @client      = hash[:client]
    @description = hash[:description]
    @condition   = hash[:condition]
    @reaction    = hash[:reaction]
  end

  #to_s
  def to_s
    return "#{@client}::#{@description}"
  end
end

