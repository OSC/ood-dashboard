# utility class for dealing with apps that play "files" role
class OodFilesApp
  class << self
    # a hash of Pathname objects as keys paired with clarifying descriptions as
    # the corresponding values
    # should always be {}
    # see config/examples/osc/initializers/ood.rb
    attr_accessor :candidate_favorite_paths
  end
  self.candidate_favorite_paths = {}


  # esure that [] is returned if class variable is not set
  def candidate_favorite_paths
    self.class.candidate_favorite_paths || {}
  end

  # when showing a link to the file explorer we always show
  # a link to the user's home directory
  # returns an array of other paths provided as shortcuts to the user
  def favorite_paths
    @favorite_paths ||= candidate_favorite_paths.select {|path, desc|
      path.directory? && path.readable? && path.executable?
    }
  end
end
