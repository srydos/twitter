#!/usr/bin/env ruby
###
# bot用の条件文を定義するクラス
###
class BotSetting < Hash
  attr_accessor :condition, :reactions
  @@con = Struct.new('Condition', :category, :condition_texts, :client, :user, :ng_user, :probability)
  @@rea = Struct.new('Reaction' , :category, :replies, :else)
  @@rep = Struct.new('Reply' , :reaction_texts, :weight, :prefix, :suffix)
  @@els = Struct.new('Else'  , :category , :replies)
  def initialize(condition_hash, reaction_array)
    h = condition_hash
    @condition = @@con.new(h[:category], h[:condition_texts], h[:client], h[:user], h[:ng_user], h[:probability])
    @reactions = Array.new
    Array(reaction_array).each do |a|
      Array(a[:replies]).each do |r|
        @rep = @@rep.new(r[:reaction_texts], r[:weight], r[:prefix], r[:suffix])
      end
      Array(a[:else]).each do |e|
        Array(e[:replies]).each do |er|
          @elsrep = @@rep.new(er[:reaction_texts], er[:weight], er[:prefix], er[:suffix])
        end
        @els = @@els.new(e[:category], @elsrep)
      end
      rea = @@rea.new(h[:category], @rep, @els)
      @reactions.unshift(rea)
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

