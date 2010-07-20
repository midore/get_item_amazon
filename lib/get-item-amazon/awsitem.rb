module AmazonAPI

  class AwsItem
    # AwsItem needs ary values to get the BookItem and MusicItem.
    # setup attr_accessor
    ary = [
      "Author", "Binding", "Creator",
      "EAN", "ISBN", "Label",
      "Manufacturer", "NumberOfPages",
      "ProductGroup", "ProductTypeName",
      "PublicationDate", "Publisher", "Studio",
      "Title", "MediumImage", "Price", "Edition",
      "Rank", "DetailPageURL", "Artist",
      "Format", "NumberOfDiscs", "OriginalReleaseDate",
      "PackageQuantity", "ReleaseDate", "UPC", "RunningTime"
    ].each{|x| attr_accessor x.downcase.to_sym}

    def initialize(h)
      return nil unless h
      set_up(h)
      @created ||= Time.now.to_s
    end

    def detail
      str = ""
      ins_a.each{|i| str << i.to_s.gsub("@",'').upcase + ":\s" + self[i] + "\n" }
      return str
    end

    def set_up(h)
      h.each{|k,v|
        begin
          self.send("#{k.downcase.to_sym}=", v)
        rescue NoMethodError
          next # ignore new value.
        end
        }
    end

    # def detail needs [] and ins_a
    alias [] instance_variable_get
    alias ins_a instance_variables

    private :set_up, :[], :ins_a

  end

  class AwsXML
    # reference: http://yugui.jp/articles/850
    # about xml.force_encoding("UTF-8")
    def initialize(xml, aws_id=nil)
      if xml
        (xml.include?("Error")) ? (print "ErrorXML \n") : @xml = REXML::Document.new(xml)
      end
      @h = Hash.new
      @aws_id = aws_id
    end

    def xml_to_h
      return nil unless @xml
      getelement
      set_data
      return @h
    end

    private
    def getelement
      ei = @xml.root.elements["Items/Item"]
      @attrib = get(ei, "ItemAttributes")
      @img = get(ei, "MediumImage")
      @url = get(ei, "DetailPageURL")
      @rank = get(ei, "SalesRank").text
    end

    def set_data
      @attrib.each{|x| @h[x.name] = plural(@attrib, x.name)}
      @h.delete_if{|k,v| v.nil?}
      @h["MediumImage"] = @img.elements["URL"].text unless @img.nil?
      @h["Price"] = @attrib.elements["ListPrice/FormattedPrice"].text.gsub(/\D/,'')
      @h["Rank"] = @rank
      @h["DetailPageURL"] = seturl
    end

    def get(ele, str)
      ele.elements[str]
    end

    def plural(ele, str)
      e = ele.get_elements(str)
      case e.size
      when 0
      when 1 then ele.elements[str].text
      else
        @h[str] = e.map{|i| i.text}.join(" / ")
      end
    end

    def seturl
      return nil unless @url
      return nil unless @aws_id
      url = @url.text + "0%3Ftag%3D#{@aws_id}"
      return url
    end

  end

  class AmazonAccess

    def initialize(ean)
      @ean = ean 
      @aws_uri = URI.parse(jp_url)
    end

    def base
      return nil unless ean_ok?
      set_uri
      xml = access
      return nil unless xml
      h = AwsXML.new(xml, amazon_id).xml_to_h
      return nil unless h
      return AwsItem.new(h)
    end 

    private
    def ean_ok?
      return false if @ean.size < 9 or @ean.size > 13
      return false if m = /\D/.match(@ean)
      return true
    end
  end

  module AmazonAuth 

    private
    def set_uri
      # reference: http://diaspar.jp/node/239
      # about OpenSSL::Digest::SHA256.new
      @aws_uri.path = '/onca/xml'
      req = set_query.flatten.sort.join("&")
      msg = ["GET", @aws_uri.host, @aws_uri.path, req].join("\n")
      hash = OpenSSL::HMAC::digest(OpenSSL::Digest::SHA256.new, amazon_sec, msg)
      mh = [hash].pack("m").chomp
      sig = escape(mh)
      @aws_uri.query = "#{req}&Signature=#{sig}"
      return @aws_uri
    end

    def access
      host = @aws_uri.host
      request = @aws_uri.request_uri
      doc = nil
      begin
        Net::HTTP.start(host){|http|
          response = http.get(request)
          doc = response.body
        }
      rescue SocketError
        return print "SocketError \n"
      end
      v = doc.valid_encoding?
      return print "Not ValidXML\n" unless v
      return doc
    end

    def set_type(q)
      case @ean.size
      when 10 then q << ["SearchIndex=Books" ,"IdType=ISBN"]
      when 12 then q << ["SearchIndex=Music", "IdType=EAN"]
      when 13
        if m = /^978|^491/.match(@ean)
          q << ["SearchIndex=Books" ,"IdType=ISBN"]
        elsif m = /^458/.match(@ean)
          q << ["SearchIndex=DVD", "IdType=EAN"]
        else
          q << ["SearchIndex=Music", "IdType=EAN"]
        end
      end
      return q
    end

    def set_query
      q = [
        "Service=AWSECommerceService",
        "AWSAccessKeyId=#{amazon_key}",
        "Operation=ItemLookup",
        "ItemId=#{@ean}",
        "ResponseGroup=Medium",
        "Timestamp=#{local_utc}",
        "Version=2009-03-31"
      ]
      return set_type(q)
    end

    def escape(str)
      str.gsub(/([^ a-zA-Z0-9_.-]+)/){'%' + $1.unpack('H2' * $1.bytesize).join('%').upcase}.tr(' ', '+')
    end

    def local_utc
      escape(Time.now.utc.strftime('%Y-%m-%dT%H:%M:%SZ'))
    end
  end

  AmazonAccess.send :include, $MYAMAZON
  AmazonAccess.send :include, AmazonAuth

end

