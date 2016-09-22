class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :set_user, :set_logout_url, :set_nav_categories

  def set_nav_categories
    config = Rails.root.join("config/nav.yml")
    yaml = ERB.new(Pathname.new(config).read).result
    @nav_categories = Nav.categories(YAML.load(yaml))
  end

  def set_user
    @user = User.new
  end

  def set_logout_url
    @logout_url = "/oidc?logout="

    #FIXME: HACK - delete when no longer using websvcs08
    @logout_url = "/oidc/?logout=" if request.base_url =~ /websvcs08\.osc\.edu/
    #end HACK

    @logout_url = @logout_url + ERB::Util.u(request.base_url)
  end
end
