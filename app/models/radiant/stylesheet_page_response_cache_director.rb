module Radiant
  class StylesheetPageResponseCacheDirector < Radiant::PageResponseCacheDirector
    def self.cache_timeout
      @cache_timeout ||= 30.days
    end
  end
end