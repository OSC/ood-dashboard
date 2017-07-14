class DashboardController < ApplicationController
  def index
    flash.now[:alert] = "OnDemand requires a newer version of the browser you are using. Current browser requirements include IE Edge, Firefox 19+, Chrome 34+, Safari 8+." unless view_context.browser.modern?
    flash.now[:alert] = "OnDemand is not yet optimized for mobile use." if view_context.browser.device.mobile?

    @motd = MotdFile.new.formatter
  end

  def logout
  end

  def favorite_paths
    render json: {
        html:
            render_to_string(
                partial: 'layouts/nav/favorite_paths',
                formats: :html,
                layout: false
            )
    }
  end
end
