class Date
  def following_monday
    (self + 2.days).monday
  end

  def preceding_friday
    following_monday - 3.days
  end

  def weekend?
    saturday? || sunday?
  end
end


#
# Backport fix for https://github.com/rails/rails/issues/3727
# Was reverted from 3-2-stable because it caused breaking changes
# Unfucks astral plane characters
#
module ActiveSupport
  module JSON
    module Encoding
      class << self
        def escape(string)
          string = string.encode(::Encoding::UTF_8, :undef => :replace).force_encoding(::Encoding::BINARY)
          json = string.gsub(escape_regex) { |s| ESCAPED_CHARS[s] }
          json = %("#{json}")
          json.force_encoding(::Encoding::UTF_8)
          json
        end
      end
    end
  end
end
