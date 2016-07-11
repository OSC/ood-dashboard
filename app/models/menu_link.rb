class MenuLink
  attr_accessor :category, :subcategory, :collapse, :url, :title, :icon

  class Subcategory
    attr_accessor :title

    def initialize(title)
      @title = title
    end

    def self.primary
      "primary"
    end

    def self.secondary
      "secondary"
    end
  end

  def initialize(category: nil, subcategory: Subcategory.primary, collapse: false, url: "#", title: nil, icon: nil)
    @category = category
    @subcategory = subcategory
    @collapse = collapse
    @url = url
    @title = title
    @icon = icon
  end
end
