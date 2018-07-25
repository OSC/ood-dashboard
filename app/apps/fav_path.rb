class FavPath < Pathname
  def initialize(arg, title: nil)
    super(arg)
    @title = title
  end

  attr_accessor :title

end
