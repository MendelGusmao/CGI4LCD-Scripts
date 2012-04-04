require 'digest/sha1'
require 'fileutils'
require 'open-uri'
require 'yaml'

class Simplecache

  def self.cache url, timeout = 60
    content = ""
    missed = false
    
    cache_file = [ "cache/", Digest::SHA1.hexdigest(url), ".txt" ].join("")

    unless File::exists?(cache_file)
      FileUtils::touch([cache_file]) 
      timeout = 0
    end
    
    if Time.now - File.new(cache_file).mtime > timeout
      content = open(url, "r") { |file| file.read }
      open(cache_file, "w") { |file| file.write(content) }
      missed = true
    else
      content = open(cache_file, "r") { |file| file.read }
      missed = false
    end
     
    [content, missed, cache_file]

  end
  
  def self.store url, to_append = [], &block

    cache_file = [ "cache/", Digest::SHA1.hexdigest(url), ".yaml" ].join("")

    content = []

    open(cache_file, "r") do |file|
      content = YAML::load(file.read) unless file.size == 0
    end
    
    filtered_content = yield(content, to_append) if block_given?

    if filtered_content != content
      open(cache_file, "w") do |file|
        file.write(YAML::dump(content))
      end
    end
    
    content

  end

end  
