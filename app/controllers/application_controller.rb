class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :set_user, :set_nav_groups, :set_announcement, :set_recent_dev_apps

  def set_user
    @user = User.new
  end

  def set_nav_groups
    #TODO: for AweSim, what if we added the shared apps here?
    @nav_groups = OodAppGroup.select(titles: NavConfig.categories, groups: sys_app_groups)
  end

  # get a list of recent dev apps the current user has access to (up to 8)
  def set_recent_dev_apps
    # FIXME: really, what i want to know is if user.developer?
    # and have a method to get a list of dev apps, and a list of recently
    # accessed apps, for a given user (i.e. the current user)
    #
    if NavConfig.show_develop_dropdown
      @recent_dev_apps = DevRouter.apps(require_manifest: false).sort_by {|a|
        a.modified_at.to_i
      }.reverse[0,6]
    else
      []
    end
  end

  def sys_app_groups
    @sys_app_groups ||= OodAppGroup.groups_for(apps: SysRouter.apps)
  end

  def set_announcement
    path = Pathname.new(ENV["OOD_ANNOUNCEMENT_PATH"] || "/etc/ood/config/announcement.md")
    @announcement = path.read if path.file?
  rescue => e
    logger.warn "Failed to read announcement file at: #{path} with error: #{e.message}"
  end
end
