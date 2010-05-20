#!/path/to/your/ruby191
# coding: utf-8

$LOAD_PATH.delete(".")
load '/path/to/config', wrap=true
require 'path/to/your/get-item-amazon/get_item_amazon.rb'

ean = '9784797357400'
item = AmazonAPI::AmazonAccess.new(ean).base
exit unless item

print "\n--------\n"
print item.title
print "\n--------\n"
print item.artist
print item.author
print "\n--------\n"
print item.productgroup
print "\n--------\n"
print item.detail

# All index(xxx) of detail be able to print item.xxxx
# print item.binding
# print item.creator
# print item.ean
# ...
#
=begin
% ./run_get_item_amazon.rb
--------
たのしいRuby 第3版
--------
高橋 征義 / 後藤 裕蔵
--------
Book
--------
AUTHOR: 高橋 征義 / 後藤 裕蔵
BINDING: 単行本
CREATOR: まつもと ゆきひろ
EAN: 9784797357400
EDITION: 第3版
ISBN: 4797357401
LABEL: ソフトバンククリエイティブ
MANUFACTURER: ソフトバンククリエイティブ
NUMBEROFPAGES: 544
PRODUCTGROUP: Book
PRODUCTTYPENAME: ABIS_BOOK
PUBLICATIONDATE: 2010-03-31
PUBLISHER: ソフトバンククリエイティブ
STUDIO: ソフトバンククリエイティブ
TITLE: たのしいRuby 第3版
MEDIUMIMAGE: http://ecx.images-amazon.com/images/I/41aNbddsxFL._SL160_.jpg
PRICE: 2730
RANK: 28921
DETAILPAGEURL: http://www.amazon.co.jp/dp/4797357401?tag=midore-22
=end

