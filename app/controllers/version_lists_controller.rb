class VersionListsController < ApplicationController
  def index
  end

  def show
    path = params[:path] || SysRouter.base_path

    render json: PathRouter.apps(path).map { |app|
      {:name => app.name, :remote => app.git_remote_origin_url, :version => app.git_version, :sha => app.git_sha, :user => nil, :group => nil, :permissions => nil}.merge(app.stat)
    }
  end
end
