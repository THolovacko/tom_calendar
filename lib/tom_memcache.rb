module TomMemcache
  def self.get(key)
    return `tom_memcache_get "#{key}"`.freeze
  end

  def self.set(key, value, expiration_in_seconds)
    `tom_memcache_set "#{key}" "#{value}" "#{expiration_in_seconds}"`
  end
end
