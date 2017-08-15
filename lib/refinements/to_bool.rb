# Namespace for Ruby refinements
module Refinements
  # This module coerces an object into a boolean type
  # @example
  #   "false".to_bool
  #   #=> false
  # @example
  #   0.to_bool
  #   #=> false
  # @example
  #   "off".to_bool
  #   #=> false
  # @example
  #   any_other_object.to_bool
  #   #=> true
  # @example
  #   "".to_bool
  #   #=> nil
  # @see https://github.com/rails/rails/blob/fbeebded22f53337df339285164352f298639c63/activemodel/lib/active_model/type/boolean.rb
  module ToBool
    FALSE_VALUES = [false, 0, "0", "f", "F", "false", "FALSE", "off", "OFF"].to_set

    refine Object do
      # Coerces object to boolean type
      # @return [Boolean, nil]
      def to_bool
        self == "" ? nil : !FALSE_VALUES.include?(self)
      end
    end
  end
end
