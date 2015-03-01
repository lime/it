module It
  class Interpolation
    attr_accessor :key, :label, :values

    def initialize(string, values)
      self.key, self.label = string[2..-2].split(':', 2)
      self.values = values

      convert_links
      convert_tags
    end

    def process
      check_input_values

      if label # Normal tags
        values[key].process(label.html_safe)
      elsif values[key].is_a?(It::Tag) # Empty tag
        values[key].process
      else # Normal interpolations, as I18n.t would do it.
        ERB::Util.h(values[key])
      end
    end

    private
    # Convert keys with String arguments into It::Links, if they are named link, link_* or *_link
    def convert_links
      if key =~ /(\Alink\Z|_link\Z|\Alink_)/ && values[key].is_a?(String)
        self.values[key] = It::Link.new(values[key])
      end
    end

    # Convert keys without arguments into It::Tags, if they are named tag_* or *_tag
    def convert_tags
      tag_regex = /(\Atag_|_tag\Z)/
      if key =~ tag_regex && values[key].nil?
        tag_name = key.remove(tag_regex)
        self.values[key] = It::Tag.new(tag_name)
      end
    end

    def check_input_values
      if !values.has_key?(key)
        raise KeyError, "key{#{key}} not found"
      elsif label && !values[key].is_a?(It::Tag)
        raise ArgumentError, "key{#{key}} has an argument, so it cannot resolved with a #{values[key].class}"
      end
    end
  end
end
