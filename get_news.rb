#!/usr/bin/env ruby

require 'rss'

# date_from以降の記事をリスト化する
def make_newslist(media_name, url, date_from)
  rss = RSS::Parser.parse(url)
  retval = []
  rss.items.each do |item|
    if item.pubDate - date_from > 0 then
      retval.push "【#{media_name}】#{item.title}……#{item.description}"
    end
  end
  return retval
end

news_list = []
date_from = Time.now - 12 * 60 * 60 # 12時間

news_list.concat make_newslist("NHKニュース・国際", "https://www.nhk.or.jp/rss/news/cat6.xml", date_from)
news_list.concat make_newslist("NHKニュース・社会", "https://www.nhk.or.jp/rss/news/cat1.xml", date_from)
news_list.concat make_newslist("NHKニュース・経済", "https://www.nhk.or.jp/rss/news/cat5.xml", date_from)
news_list.concat make_newslist("NHKニュース・政治", "https://www.nhk.or.jp/rss/news/cat4.xml", date_from)

puts news_list

