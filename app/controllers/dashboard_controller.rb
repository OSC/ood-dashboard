class DashboardController < ApplicationController
  def index
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
