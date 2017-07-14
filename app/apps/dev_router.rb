class DevRouter
  attr_reader :name, :owner, :caption, :category

  def initialize(name, owner=OodSupport::Process.user.name)
    @name = name.to_s
    @owner = owner
    @caption = "Sandbox App"
    @category = "Sandbox Apps"
  end

  def self.apps(owner: OodSupport::Process.user.name, require_manifest: true)
    target = base_path(owner: owner)
    if target.directory? && target.executable? && target.readable?
      target.children.map { |d|
        ::OodApp.new(self.new(d.basename, owner))
      }.select { |d|
        d.valid_dir? && d.accessible? && (!require_manifest || d.manifest.valid?)
      }
    else
      []
    end
  end

  def self.base_path(owner: OodSupport::Process.user.name)
    Pathname.new "#{Dir.home(owner)}/#{ENV['OOD_PORTAL'] || "ondemand"}/dev"
  end

  def base_path
    self.class.base_path(owner: owner)
  end

  def type
    :dev
  end

  def url
    "/pun/dev/#{name}"
  end

  def path
    @path ||= base_path.join(name)
  end

  def token
    "#{type}/#{name}"
  end
end
