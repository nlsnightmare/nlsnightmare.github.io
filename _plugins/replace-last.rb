require 'jekyll'
require 'liquid'

module Jekyll
  module ReplaceLastFilter
    # Replace last occurrence in a string
    #
    # Example:
    #   >> replace_last("string", "i", "o")
    #   => strong
    #
    # Arguments:
    #   input: (String)
    #   string_to_replace: (String)
    #   replacement: (String)
    def replace_last(input, str_to_replace, replacement) #, str_to_replace, replacement)
      str_rev = str_to_replace.reverse
      rep_rev = replacement.reverse
      "#{input.reverse.sub(str_rev, rep_rev).reverse}"
    end
  end
end


Liquid::Template.register_filter(Jekyll::ReplaceLastFilter)
