require 'jekyll'
require 'liquid'

module Jekyll
  module MinFilter
    # get at least the given value
    #
    # Example:
    # >> 0 | min:1
    # => 1
    def min(input, value)
      if input > value
        input
      else
        value
      end
    end
  end
end

Liquid::Template.register_filter(Jekyll::MinFilter)