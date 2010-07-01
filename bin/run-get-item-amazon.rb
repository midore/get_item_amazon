#!/path/to/ruby19
# coding: utf-8
#
#------------------------------------------
# run-get-item-amazon.rb
#------------------------------------------

(print "Error: Only Ruby 1.9\n"; exit) if RUBY_VERSION < "1.9"
(print "Error: LANG"; exit) unless Encoding.default_external.name == 'UTF-8'

module AmazonAPI

  class Start

    def own_dir
      dir = File.dirname(File.dirname(File.expand_path($PROGRAM_NAME)))
      lib = File.join(dir, 'lib')
      $LOAD_PATH.push(lib)
      $LOAD_PATH.delete(".")
    end

    def run
      own_dir
      # Your path
      conf = 'path/to/your/get-item-amazon-config'
      load conf, wrap=true
      require 'lib/get-item-amazon'
      ean = ARGV[0]
      # たのしいRuby 第3版
      ean ||= '9784797357400'
      exit if /\D/.match(ean)
      (print "Error: ean size\n"; exit) if ean.size < 9 or ean.size > 13
      item = AmazonAccess.new(ean).base
      exit unless item

      # EXAMPLE OUTPUT
      print "# Examples #\n\n"
      blog_output
      print "#--\n"
      output
    end

    def output
      # example
      print "-"*5,"\n"
      print item.title
      print item.artist
      print item.author
      print item.productgroup
      print item.detail
    end

    def blog_output
      # example
      print "<a href=\'#{item.detailpageurl}\'>#{item.title}</a>\n"
      print "EAN: #{item.ean}\n"
      print "AUTHOR: #{item.author}\n"
      print "CREATOR: #{item.creator}\n"
      print "<img\ssrc=\'#{item.mediumimage}\' alt=\'amazon-img\'>\n\n"
    end
    private :own_dir
  end
end

AmazonAPI::Start.new.run

