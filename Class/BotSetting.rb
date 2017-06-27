#!/usr/bin/env ruby
###
# bot用の条件文を定義するクラス
###
class BotSetting < Hash
  attr_accessor :condition, :reactions
  CONDITION = Struct.new('Condition',
                     :category,
                     :condition_texts,
                     :client,
                     :user,
                     :ng_user,
                     :probability)

  REACTION = Struct.new('Reaction',
                     :category,
                     :replies,
                     :else)

  REPLY = Struct.new('Reply',
                     :reaction_texts,
                     :weight,
                     :prefix,
                     :suffix)

  ELSE = Struct.new('Else',
                     :category,
                     :replies)

  def initialize(condition_hash, reaction_array)
    h = condition_hash
    @condition = CONDITION.new(h[:category],
                           h[:condition_texts],
                           h[:client],
                           h[:user],
                           h[:ng_user],
                           h[:probability])
    @reactions = []
    Array(reaction_array).each do |a|
      @rep = []
      Array(a[:replies]).each do |r|
        rep = REPLY.new(r[:reaction_texts],
                        r[:weight],
                        r[:prefix],
                        r[:suffix])
        @rep.unshift(rep)
      end
      Array(a[:else]).each do |e|
        Array(e[:replies]).each do |er|
          @elsrep = REPLY.new(er[:reaction_texts],
                              er[:weight],
                              er[:prefix],
                              er[:suffix])
        end
        @els = ELSE.new(e[:category],
                         @elsrep)
      end
      rea = REACTION.new(a[:category],
                      @rep,
                      @els)
      @reactions.unshift(rea)
    end
  end

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

