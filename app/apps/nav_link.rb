class NavLink
  # icon - font awesome icon
  attr_accessor :icon, :text, :url, :separator

  def initialize(icon: "gear",text:,url:,separator: false)
    @separator = separator
    @icon = icon
    @text = text
    @url = url
  end
end
