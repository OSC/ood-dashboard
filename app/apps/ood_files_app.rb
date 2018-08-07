# utility class for dealing with apps that play "files" role
class OodFilesApp
  class << self
    # an array of Pathname objects to check for the existence of and access to
    # should always be []
    # set in config/initializers/ood.rb
    attr_accessor :candidate_favorite_paths
  end
  self.candidate_favorite_paths = []


  # esure that [] is returned if class variable is not set
  def candidate_favorite_paths
    self.class.candidate_favorite_paths || []
  end

  # when showing a link to the file explorer we always show
  # a link to the user's home directory
  # returns an array of other paths provided as shortcuts to the user
  def favorite_paths
    fav_paths = []
    candidate_favorite_paths.each { |item|
      if item.class == Pathname
        fav_paths << FavoritePath.new(item) if okay(item)
      elsif item.class == FavoritePath
        fav_paths << item if okay(item)
      elsif item.class == Hash
        item.each { |item_pathname, item_title|
          fav_paths << FavoritePath.new(item_pathname, title: item_title) if okay(item_pathname)
        }
      end
    }
    fav_paths
  end
  
  private
  
  def okay(pathname)
    pathname.directory? && pathname.readable? && pathname.executable?
  end
  
end
