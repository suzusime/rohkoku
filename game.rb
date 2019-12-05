require 'wareki'
require 'json'

class Clock
  # ニュースリストを読み込み
  def load_news
    File.open("news_list.txt", mode="r") do |f|
      @news_list = f.readlines
    end
    @news_framecount=0
    @news_index=0
  end

  # ニュースリストを更新
  def refresh_news
    if @now.min % 30 == 1 && @now.sec == 0 then
      if not @was_news_updated then
        spawn "ruby get_news.rb > news_list.txt"
        @was_news_updated=true
        puts "news refreshed!"
      end
    else
      @was_news_updated=false
    end
  end

  # ニュースリストを再読込
  def reload_news
    if @now.min % 30 == 2 && @now.sec == 0 then
      if not @was_news_reloaded then
        load_news
        @was_news_reloaded=true
        puts "news reloaded!"
      end
    else
      @was_news_reloaded=false
    end
  end

  # 気象情報を読み込み
  def load_kisyo
    File.open("kisyo.json") do |f|
      @kisyo = JSON.load(f)
    end
    puts @kisyo
  end

  # 気象情報を更新
  def refresh_kisyo
    if @now.min % 30 == 3 && @now.sec == 0 then
      if not @was_kisyo_updated then
        spawn "ruby tenki.rb"
        @was_kisyo_updated=true
        puts "kisyo refreshed!"
      end
    else
      @was_kisyo_updated=false
    end
  end

  # 気象情報を再読込
  def reload_kisyo
    if @now.min % 30 == 4 && @now.sec == 0 then
      if not @was_kisyo_reloaded then
        load_kisyo
        @was_kisyo_reloaded=true
        puts "kisyo reloaded!"
      end
    else
      @was_kisyo_reloaded=false
    end
  end
  # 構築関数
  def initialize
    @today = Wareki::Date.today
    @now = Time.now
    @news_text="ここにニュースが入る"
    load_news
    load_kisyo
    @asciifont = SDL2::TTF.open("ShareTechMono-Regular.ttf", 96)
    @was_news_updated=false
    @was_news_reloaded=false
    @was_kisyo_updated=false
    @was_kisyo_reloaded=false
  end

  def update
    # 時刻の更新
    @today = Wareki::Date.today
    @now = Time.now
    
    # テキストが画面から消えたら次のニュースに移る
    news_text_width = get_size_text(@news_text)[0]
    news_x = 480 - @news_framecount*1.5
    if news_x + news_text_width < 0 then
      @news_index= (@news_index+1) % @news_list.length
      @news_framecount=0
    end
  
    # 定期的に行う処理
    refresh_news
    reload_news
    refresh_kisyo
    reload_kisyo
  end

  def draw
    # 時刻の表示
    set_fontsize(32)
    #text(now.strftime("%Y-%m-%d %H:%M:%S"), x: 10, y: 10, font: asciifont)
    if @today.era_year == 1 then
      # 元年だけは漢字で表示する
      text(@today.strftime("%JYK年 %m月 %d日"), x: 10, y: 10)
    else
      text(@today.strftime("%Jy年 %m月 %_d日"), x: 10, y: 10)
    end
    set_fontsize(90)
    text(@now.strftime("%H  %M  %S"), x:10, y:50)
    set_fontsize(32)
    text("#{' '*15}時#{' '*15}分#{' '*15}秒", x: 10, y: 98)
  
    # 線を引く
    draw_line(0, 50, 480, 50, [128, 128, 128]) 
    draw_line(0, 145, 480, 145, [128, 128, 128]) 
  
    # ニュースの表示
    set_fontsize(20)
    @news_text = @news_list[@news_index].chomp
    news_x = 480 - @news_framecount*1.5
    text(@news_text, x: news_x, y: 150) 
    @news_framecount+=1

    # 天気の表示
    text("天気", x: 0, y: 176)
    @kisyo["weather"]["times"].each_with_index do |v, i|
      text(v, x:20, y:200+24*i)
    end
    @kisyo["weather"]["values"].each_with_index do |v, i|
      text(v, x:100, y:200+24*i)
    end
  end
end

# 唯一の時計オブジェクトをつくる
clock = Clock.new

mainloop do
  # ウインドウのクリア
  clear_window

  clock.update
  clock.draw
 

  exit if keydown?("ESCAPE")
end
