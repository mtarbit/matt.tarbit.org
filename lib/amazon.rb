require 'rubygems'
require 'cgi'
require 'uri'
require 'time'
require 'hmac-sha2'
require 'base64'
require 'httparty'

module REXML
  class Source
    def match(pattern, cons=false)
      @buffer.force_encoding('UTF-8')
      md = pattern.match(@buffer)
      @buffer = $' if cons and md
      return md
    end
  end
end

module Amazon
  ENDPOINT = URI.parse('http://ecs.amazonaws.co.uk/onca/xml')

  class Authorization
    def initialize(secret_key)
      @secret_key = secret_key
    end

    def url_encode(string)
      # Encoded as per AmProdAd API specifications
      CGI.escape(string).gsub("%7E", "~").gsub("+", "%20")
    end

    def params_to_querystring(params)
      # Canonicalized as per AmProdAd API specifications
      params = params.sort {|a,b| a.to_s <=> b.to_s }
      params.collect { |k,v| [url_encode(k.to_s), url_encode(v.to_s)].join('=') }.join('&')
    end

    def string_to_sign(querystring)
      # New-line seperated string as per AmProdAd API pseudo-grammar
      [ 'GET', ENDPOINT.host, ENDPOINT.path, querystring ].join("\n")
    end

    def signature_for_string(str)
      # Hash Message Authentication Code converted to a Base64 string
      hmac = HMAC::SHA256.new(@secret_key)
      hmac.update(str)
      Base64.encode64(hmac.digest).chomp
    end

    def signature_for_params(params)
      # Convert the params to a querystring and encode that as a signature
      querystring = params_to_querystring(params)
      signature_for_string(string_to_sign(querystring))
    end

    def sign(defaults, options)
      # Extend the parameters with a timestamp and an HMAC-SHA signature
      params = defaults.dup
      params.merge!(options)
      params.merge!(:Timestamp => Time.now.iso8601)
      params.merge!(:Signature => signature_for_params(params))
    end
  end

  class Product
    ALL_SEARCH_INDICES  = %w{Apparel Baby Blended Books Classical DVD Electronics HealthPersonalCare HomeGarden Kitchen Marketplace Music MusicTracks OutdoorLiving Software SoftwareVideoGames SportingGoods Tools Toys VHS Video VideoGames Watches}
    CORE_SEARCH_INDICES = %w{Books VideoGames Music DVD Electronics}

    include HTTParty
    base_uri ENDPOINT.scheme + '://' + ENDPOINT.host
    default_params :Service=>'AWSECommerceService', :ResponseGroup=>'Medium', :Sort=>'salesrank', :Country=>'UK', :Validate=>'True'

    def initialize(access_key, secret_key, associate_tag)
      @access_key = access_key
      @secret_key = secret_key
      @associate_tag = associate_tag
      self.class.default_params :AssociateTag => @associate_tag, :AWSAccessKeyId => @access_key
    end

    def search(search, options={})
      defaults = { :Operation => 'ItemSearch', :SearchIndex=>'Books', :Keywords => search }
      request(defaults.merge(options))
    end

    def lookup(search, options={})
      defaults = { :Operation => 'ItemLookup', :ItemId => search }
      request(defaults.merge(options))
    end

    def request(params={})

      # Add in the necessary parameters for authorization by the Amazon Product Advertising API
      params = Authorization.new(@secret_key).sign(self.class.default_params, params)

      # Then make our request
      res = self.class.get(ENDPOINT.path, { :query => params })

      # Look for an appropriate return value in the response
      items = res[params[:Operation] + 'Response']['Items']
      items =
      case items['Request']['IsValid']
        when 'True' then  items['Item']
        when 'False' then items['Request']['Errors']['Error']['Message']
      end

      # Return it if we found one, or just use the raw response
      items || res

    end

  end
end
