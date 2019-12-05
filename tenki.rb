require 'rexml/document'
require 'json'
require 'open-uri'

doc = REXML::Document.new(open("http://www.data.jma.go.jp/developer/xml/feed/regular_l.xml"))
yohou_url=""

# 最新の府県天気予報へのリンクを取得
doc.elements.each("feed/entry") do |entry|
  content = entry.elements["content"].text
  if content == "【京都府府県天気予報】" then
    yohou_url = entry.elements["link"].attributes["href"]
    break
  end
end

yohou = REXML::Document.new(open(yohou_url))
timedefs = []

# outputはここに入れる
output = Hash.new

# 区域予報
yohou.elements.each("Report/Body/MeteorologicalInfos[@type='区域予報']/TimeSeriesInfo/Item") do |item|
  area_code = item.elements["Area/Code"].text
  # 京都府南部
  if area_code == "260010" then
    #puts "南部！"
    item.elements.each("Kind/Property") do |prop|
      type = prop.elements["Type"].text
      if type == "天気" then
        times = []
        weathers = []
        item.parent.elements.each("TimeDefines/TimeDefine/Name") do |t|
          times.push t.text
        end
        prop.elements.each("WeatherPart/jmx_eb:Weather") do |w|
          weathers.push w.text
        end
        output["weather"] = { "times": times, "values": weathers } 
      end
    end
  end
end

File.open("kisyo.json", "w") do |f|
  JSON.dump(output, f)
end
