require 'jekyll'
require 'liquid'

module Jekyll
  module StartsWithFilter
    def starts_with(input, string) #, str_to_replace, replacement)
      input.start_with? string
    end
  end
end


Liquid::Template.register_filter(Jekyll::StartsWithFilter)

