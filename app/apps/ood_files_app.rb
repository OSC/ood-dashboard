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
    if candidate_favorite_paths.class == Hash
      candidate_favorite_paths.each { |path, title|
        favorite_paths_tmp += FavoritePath.new(path, title: title)
      }
      @favorite_paths ||= favorite_paths_tmp
    else
      @favorite_paths ||= candidate_favorite_paths.select { |p|
        p.directory? && p.readable? && p.executable?
      }.map { |p|
        case p.class
        when Pathname
          FavoritePath.new(p)
        when FavoritePath
          p
        end
      }
    end
  end
end
