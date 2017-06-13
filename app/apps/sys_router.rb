class SysRouter
  attr_reader :name, :path

  #TODO: consider making SysRouter a subclass of
  # OodAppkit::Url

  # TODO: consider memoizing this for the duration of the request
  # one way would be to instantiate a new SysRouter and then use that same
  # instance
  def self.app_exists?(name)
    OodApp.new(SysRouter.new(name)).valid_dir?
  end

  def self.apps(require_manifest: true)
    target = base_path
    if target.directory? && target.executable? && target.readable?
      base_path.children.map { |d|
        app = ::OodApp.new(self.new(d.basename))

        # if the app directory does not contain a manifest, look for directories
        # with valid manifests in the sub directories of this directory
        if ! app.manifest.exist? && d.directory? && d.executable? && d.readable?
          d.children.map { |subapp_dir| ::OodApp.new(self.new(subapp_dir.basename, subapp_dir))}
        else
          app
        end
      }.flatten.select { |d|
        d.valid_dir? && d.accessible? && (!require_manifest || d.manifest.valid?)
      }
    else
      []
    end
  end

  def initialize(name, path = nil)
    @name = name.to_s
    @path = path || self.class.base_path.join(name)
  end

  def token
    "#{type}/#{name}"
  end

  def self.base_path
    Pathname.new "/var/www/ood/apps/sys"
  end

  def type
    :sys
  end

  def owner
    :sys
  end

  def caption
    "System Installed App"
  end

  def category
    "System Installed Apps"
  end

  def url
    "/pun/sys/#{name}"
  end
end
