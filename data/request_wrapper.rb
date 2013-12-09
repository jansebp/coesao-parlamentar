# Class for wrapping HTTParty requests
# Objects are returned as parsed responses
#  
# Aditional features from the wrapper:
#  * HEADERS (API did not work with default headers)
#  * caching
#  
# Remarks:
#  * caching only works with hardcoded params into URL string
#  * caching is hardcoded to work with XML, altough files are stored with raw content

class RequestWrapper
  CACHE_DIR = "cache/"
  HEADERS = { "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1309.0 Safari/537.17" }

  def self.get(url, params={}, headers={})
    # How can we make HTTParty generate the full URL for us? :(
    # The implementation of this method ignores params. At the moment this is
    # OK, as params are being hardcoded on the URL string
    cache = retrieve_cache(url, params)

    if cache
      return cache
    else
      # Make request
      headers.merge!(HEADERS)
      response = HTTParty.get(url, :headers => headers)  
      
      # Cache result
      cache!(response)
      
      raise IOError, response if response.code != 200

      return response.parsed_response
    end
  end

protected
  def self.cache_file_path(response)
    File.join(CACHE_DIR, response.request.path.to_s.split("/").last)
  end

  def self.cache!(response)
    File.open(cache_file_path(response), 'w') { |f| f.write(response.body) }
  end
  
  # This method should use HTTParty to generate the full url
  def self.retrieve_cache(url, params)
    filename = url.split("/").last
    filepath = File.join(CACHE_DIR, filename)

    if File.exists?(filepath)
      return parse(File.open(filepath, 'rb') { |f| f.read })
    else
      return
    end
  end

  def self.parse(string)
    MultiXml.parse(string)
  end
end
