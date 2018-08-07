class FavoritePath
  
  def initialize(path, title: nil)
    @path = Pathname.new(path)
    @title = title
  end
  
  attr_accessor :path, :title

end
