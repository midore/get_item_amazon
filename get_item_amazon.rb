
# get_item_amazon.rb
begin
  raise "Error: only ruby 1.9.1" if RUBY_VERSION < "1.9.1"
  ext = Encoding.default_external.name
  raise "Error, LANG must be UTF-8" unless ext == 'UTF-8'
end

$:.unshift(File.dirname(__FILE__))

require 'time'
require 'timeout'
require 'rexml/document'
require 'uri'
require 'net/http'
require 'openssl'

require 'lib/get_item'

