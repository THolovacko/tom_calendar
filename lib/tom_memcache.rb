module TomMemcache
  def self.get(key)
    result = `tom_memcache_get '#{key}'`.freeze
    result = nil if (result == '')
    result
  end

  def self.set(key, value, expiration_in_seconds)
    `tom_memcache_set '#{key}' '#{value}' '#{expiration_in_seconds}'`
  end
end
