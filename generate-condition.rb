#!/usr/bin/env ruby
require 'yaml'
require 'pp'
WORK_DIR=File.expand_path(__FILE__).sub(/[^\/]+$/,'')
require WORK_DIR + './Class/BotSettings.rb'
require WORK_DIR + './Class/BotSetting.rb'

#対話型インデックス選択
# @param 選択肢となる配列
# @param 渡された配列の要素が連想形式だった場合は指定
def select_index(enum, elem = "", allow_new = false)
  input_num = 0
  loop do
    enum.each_index do |index|
     puts "  #{index} --> #{enum[index]}"           if elem == ""
     puts "  #{index} --> #{enum[index][elem]}" unless elem == ""
    end
    puts "  #{enum.length} --> [新規作成]" if allow_new == true
    print '番号を入力 : '
    input_num = STDIN.gets.chomp
    if not input_num =~ /\A[0-9]+\z/
      puts "***数字を入力してください***"
    elsif input_num.to_i > enum.length
      puts "***範囲外です***"
    else
      break
    end
  end
  return input_num.to_i
end

#設定する内容が配列内で想定されたものであればその文字を返し、違えば空文字を返す
def choose_except_array(except_array)
  input_text = ""
  input_text = STDIN.gets.chomp
  except_array.include?(input_text)
  return input_text
end

#yamlに吐き出して終了
def output_file(data)
end
###
#初期化
###
#コメント作成
comment = ""
DATA.each_line { |line| comment << '# ' << line }
#メニュー用配列
cond_categories  = ["reply", "timeline", "self", "delete", "fav_me", "fav", "follow"].freeze
cond_categories_description  = ["リプライ", "ホームタイムラインのツイート", "自分のツイート", "ツイート削除イベント", "自分のツイートがファボられたイベント", "誰かがファボったイベント", "フォローされた"].freeze
react_categories = ["reply", "tweet", "delete", "fav", "follow", "log"].freeze
react_categories_description = ["リプライを返す", "何かツイートする", "対象を削除する(?)", "お気に入りに追加する", "そのユーザをフォローする", "保存出力しておく"]

#現在の条件設定ファイル読み込み
setting_file_path = WORK_DIR + 'Config/reaction-condition.yml'
if File.exist?(setting_file_path) then
  setting_file = File.open(setting_file_path, "r+")
  hash_array = YAML.load_file(setting_file_path)
  hash_array.each_with_index { |item,index|
    unless item.instance_of?(Hash)
      puts "#{setting_file_path}の#{index+1}番目は中身が何かおかしいです..."
      exit
    end
  }
else
  setting_file = File.open(setting_file_path, "w")
  setting_file.write(comment)
end

###
# ファイル読み込み
###
#設定するクライアント名を入力
client_file_name = ""
loop do
  print '使用させたいクライアント名称を入力 : '
  input_file_name = STDIN.gets.chomp
  if File.exist?(WORK_DIR + "Config/#{input_file_name}.yml")
    client_file_name = input_file_name
    break
  else
    puts WORK_DIR + "Config/#{input_file_name}.yml"
    puts "その名称のクライアント設定ファイルは存在しません。"
  end
end

#ymlから取り出した設定配列のうち、編集する設定を選ぶ
selected_array = hash_array.select{|item| item[:client] == client_file_name}
hash_array.select!{|item| item[:client] != client_file_name} #選択中の要素を削除
while true
  puts '[設定する条件の番号を以下より選んでください]'
  edit_index = select_index(selected_array, :description, true) #選択番号を格納
  if edit_index < selected_array.length #既存が選択された場合
    edit_setting = selected_array.delete_at(edit_index) #選択要素を取り出す
    client    = edit_setting[:client]
    condition = edit_setting[:condition]
    reactions = edit_setting[:reaction]
    is_new    = false
    break
  elsif edit_index == selected_array.length #新規作成が選択された場合
    client    = client_file_name
    condition = {category: ""}
    reactions  = [{category: []}]
    is_new    = true
    break
  end
end
hash_array << selected_array #編集中以外の要素を全てhash_arrayに

#設定するインスタンス生成
setting = BotSetting.new(client, condition[:category], reactions)

###
# 反応条件指定
###
# カテゴリ設定
puts "現在設定されている条件カテゴリ : #{setting.condition.category}"
puts '[反応する条件カテゴリを設定してください]'
operation_kinds = ["変更しない", "条件を変更", "この条件を削除"]
operation_index = select_index(operation_kinds)
pp operation_index
case operation_index
when 0
when 1
  puts 'カテゴリを入力 : '
  input_num = select_index(cond_categories_description)
  setting.condition.category = cond_categories[input_num]
when 2
  print '正気か？ [yes/*] : '
  input = STDIN.gets.chomp
  if input.match(/\Ayes\z/)
    output_yml(hash_array) #今弄っている設定以外で出力を始める
    puts '削除完了！'
    exit
  end
end

# tweet,reply等が含まれている場合、テキストの配列を設定
if input_num.between?(0, 2)
  puts "[反応するテキストを設定します]"
  loop do
    puts "現在設定されている反応テキスト : #{setting.condition.condition_text}"
    input_text = STDIN.gets.chomp
    setting.coniditon.condition_text.push(input_text)
    print '他にも設定しますか？[y/n] :'
    input = STDIN.gets.chomp
    break unless input.match(/^[yY]/)
  end
end
pp setting.condition.condition_text
exit

###
# 反応動作設定
###
set_react = setting.condition
loop do
  puts '[反応する動作カテゴリを設定してください]'
  if not set_react[:category].nil? && 0 < set_react[:category].length
    print '現在設定されている条件カテゴリ : '
    set_react[:category].each {|i| print i }
    print "\n"
  end
  print 'カテゴリを入力 : '
  input_category = choose_except_array(react_categories)
  if input_category.empty?
    puts "#{input_category}は設定できませんでした。"
  else
      setting.condition.category.push(input_category)   if operation_index == 1
      setting.condition.category.delete(input_category) if operation_index == 2
      print '現在設定されている条件カテゴリ : '
      setting.condition.category.each {|i| print i }
      print "\n"
      print '他にも設定しますか？[y/n] :'
      input = STDIN.gets.chomp
      break unless input.match(/^[yY]/)
  end
end

#出力
 data = comment + setting.to_yaml
 pp data
 __END__
 botが反応する条件を書く
 必須でない項目は項目自体省略可能ですぞ

 - client:      使用するクライアント名 あらかじめConfig配下に設定ファイルを置く 必須
   description: この設定時の説明用エリア
   condition:
     category: timeline mention delete等反応する条件配列 *必須*
   - condition_texts: 反応するテキスト配列 空配列の場合は全てに反応する
     client:   配列として指定された、反応しても良いクライアント
     user:     配列として指定されたidのユーザーのみ反応する
     ng_user:  配列として指定されたidのユーザには反応しない '@'不要
     probability:   反応する確率 1で100% 0で反応しない 1がデフォ
   reactions:
     category: tweet reply follow fav等反応する動作の配列 *必須*
     replies: replyの場合は必須 それ以外は省略可
     - reaction_texts: 返答するテキスト 配列可 *必須*
       weight: 重み付け整数 数字が大きいほど上記テキストを返す可能性が高い 1がデフォ
       prefix: 接頭語 0..5でランダムについて重複投稿を回避
       suffix: 接尾語 0..5でランダムについて重複投稿を回避
   else:
     category: 確率に漏れた場合の動作カテゴリ
     replies: 上記に同じ
