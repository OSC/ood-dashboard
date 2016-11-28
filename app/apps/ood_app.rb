class OodApp
  attr_reader :router
  delegate :owner, :caption, :url, :type, :path, to: :router

  PROTECTED_NAMES = ["shared_apps", "cgi-bin", "tmp"]

  def accessible?
    path.executable? && path.readable?
  end
  alias_method :rx?, :accessible?

  def valid_dir?
    path.directory? &&
    ! self.class::PROTECTED_NAMES.include?(path.basename.to_s) &&
    ! path.basename.to_s.start_with?(".")
  end

  def initialize(router)
    @router = router
  end

  def name
    path.basename.to_s
  end

  def title
    manifest.name.empty? ? name.titleize : manifest.name
  end

  def has_gemfile?
    path.join("Gemfile").file? && path.join("Gemfile.lock").file?
  end

  def category
    manifest.category.empty? ? router.category : manifest.category
  end

  def subcategory
    manifest.subcategory
  end

  def role
    manifest.role
  end

  def bundler_helper
    @bundler_helper ||= BundlerHelper.new(path)
  end

  def manifest
    @manifest ||= load_manifest
  end

  def icon_path
    path.join("icon.png")
  end

  # Get the output of `git describe`
  #
  # @return [String] tag or branch or sha
  def git_version
    `GIT_DIR=#{path}/.git git describe --always --tags`.strip
  end

  # Get the current commit sha
  #
  # @return [String] sha of the HEAD
  def git_sha
    `GIT_DIR=#{path}/.git git rev-parse --short HEAD`.strip
  end

  # Get the url of the remote origin
  #
  # @return [String] url (either ssh or https)
  def git_remote_origin_url
    #FIXME: copied from Product@get_git_remote
    `cd #{path} 2> /dev/null && HOME="" git config --get remote.origin.url 2> /dev/null`.strip
  end

  def badge_url
    # Borrowed from https://www.debuggex.com/r/H4kRw1G0YPyBFjfm
    repo = git_remote_origin_url.scan(/((git|ssh|http(s)?)|(git@[\w\.]+))(:(\/\/)?)([\w\.@\:\/\-~]+)(\.git)(\/)?/)
    # ex. https://badge.fury.io/gh/osc%2Food-fileeditor.svg
    "https://badge.fury.io/gh/#{repo[0][6].gsub("/", "%2F")}.svg"
  end

  # Get the owner, group, and octal access rights via stat on the app directory
  #
  # @return [Hash] with user, group, and permissions
  def stat
    {
      user: OodSupport::User.new(path.stat.uid).name,
      group: OodSupport::Group.new(path.stat.gid).name,
      permissions: "%o" % path.stat.mode
    }
  end

  class SetupScriptFailed < StandardError; end
  # run the production setup script for setting up the user's
  # dataroot and database for the current app, if the production
  # setup script exists and can be executed
  def run_setup_production
    Bundler.with_clean_env do
      setup = "./bin/setup-production"
      Dir.chdir(path) do
        if File.exist?(setup) && File.executable?(setup)
          output = `bundle exec #{setup} 2>&1`
          unless $?.success?
            msg = "Per user setup failed for script at #{path}/#{setup} "
            msg += "for user #{Etc.getpwuid.name} with output: #{output}"
            raise SetupScriptFailed, msg
          end
        end
      end
    end
  end

  private

  def load_manifest
    default = path.join("manifest.yml")
    alt = path.dirname.join("#{path.basename}.yml")
    alt.exist? ? Manifest.load(alt) : Manifest.load(default)
  end
end
