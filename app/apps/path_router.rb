# A special router to use to instantiate an OodApp
# object if all you have is the path to the app
class PathRouter
  attr_reader :category, :caption, :url, :type, :path

  def initialize(path)
    @caption = nil
    @category = "App"
    @url = "#"
    @type = :path
    @path = Pathname.new(path)
  end

  def owner
    @owner ||= Etc.getpwuid(path.stat.uid).name
  end

  def self.apps(parent, require_manifest: true)
    target = Pathname.new(parent)
    if target.directory? && target.executable? && target.readable?
      target.children.map { |d|
        ::OodApp.new(self.new(d))
      }.select { |d|
        d.valid_dir? && d.accessible? && (!require_manifest || d.manifest.valid?)
      }
    else
      []
    end
  end
end
