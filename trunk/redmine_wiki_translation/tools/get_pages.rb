#!/usr/bin/env ruby

WIKI_INDEX_URL = 'http://www.redmine.org/projects/redmine/wiki/Page_index'
PAGES_DIR='../original'

require 'rubygems'
require 'open-uri'
require 'hpricot' # HTML parser (gem install hpricot)


# Wikiの索引取得
base_uri =  URI(WIKI_INDEX_URL)
html = base_uri.read

# 索引からwikiページのURLを切り出す
doc = Hpricot(html)
items = doc / "div#content" / "li"
page_hrefs = items.map {|item| (item/:a).first[:href]}

# WikiをTextileとしてダウンロードする
pwd = File.dirname($0)
page_hrefs.each do |href|
  page_uri = base_uri.merge("#{href}?format=txt")
  puts page_uri
  page_content = page_uri.read
  file_name = File.join(pwd, PAGES_DIR, File.basename(page_uri.path))
  open(file_name, "w") do |io|
    io.write page_content
  end
end
