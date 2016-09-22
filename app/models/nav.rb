class Nav
  class Base
    attr_accessor :title, :url, :icon, :owner, :app, :path

    def to_partial_path
      "shared/#{self.class.name.underscore}"
    end
  end

  class Category < Base
    attr_accessor :links

    def initialize
      @links = []
    end

    def self.create(key, value)
      category = Category.new
      category.title = key

      if(value.kind_of?(Array))
        category.links += value.map {|v| Link.create(v) }
      elsif(value.kind_of?(Hash))
        category.links += value.map {|k,v| Category.create(k, v) }
      else
        # TODO:unhandled
      end

      category
    end
  end

  class Link < Base
    def initialize(params = {})
      params.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end

    def self.create(value)
      if(value.kind_of?(Hash))
        if(value.has_key?(:path) || value.has_key?("path"))
          Path.new(value)
        elsif(value.has_key?(:app) || value.has_key?("app"))
          App.new(value)
        else
          Link.new(value)
        end
      elsif(value.kind_of?(String))
        (value == "logout" || value == :logout) ? Nav::Logout.new : Nav::Separator.new
      else
      end
    end
  end

  class App < Link
  end

  class Path < Link
  end

  class Separator < Base
  end

  class Logout < Base
  end

end
