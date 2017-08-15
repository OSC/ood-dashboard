class String
  FALSE_VALUES = ["0", "f", "F", "false", "FALSE", "off", "OFF"].to_set

  # Convert string to a boolean
  # @example
  #   "false".to_bool     #=> false
  # @example
  #   "0".to_bool         #=> false
  # @example
  #   "off".to_bool       #=> false
  # @example
  #   "".to_bool          #=> nil
  # @example
  #   "something".to_bool #=> true
  # @see https://github.com/rails/rails/blob/fbeebded22f53337df339285164352f298639c63/activemodel/lib/active_model/type/boolean.rb
  # @return [Boolean, nil]
  def to_bool
    self == "" ? nil : !FALSE_VALUES.include?(self)
  end
end
