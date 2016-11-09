class NavConfig
  class << self
    attr_accessor :categories, :help_dropdown_links, :user_dropdown_links
  end
  self.categories = ["Files", "Jobs", "Clusters", "Desktops"]

  # array of NavLink objects
  self.help_dropdown_links = []
  self.user_dropdown_links = []
end
