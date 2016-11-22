class VersionListsController < ApplicationController
  def index
  end

  def show
    path = params[:path] || SysRouter.base_path

    render json: PathRouter.apps(path).map { |app|
      {:name => app.name, :version => app.version, :user => nil, :group => nil, :permissions => nil}.merge(app.stat)
    }
  end
end
