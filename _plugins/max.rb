require 'jekyll'
require 'liquid'

module Jekyll
  module MaxFilter
    def max(input, value)
      if input > value
        input
      else
        value
      end
    end
  end
end