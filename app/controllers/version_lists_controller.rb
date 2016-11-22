class VersionListsController < ApplicationController
  def index
  end

  def show
    @path = params[:path] || SysRouter.base_path
    @apps = PathRouter.apps(@path, require_manifest: false).sort_by(&:name)

    respond_to do |format|
      format.html  # show.index.erb
      format.json { render json: @apps.map { |app|
        {:name => app.name, :remote => app.git_remote_origin_url, :version => app.git_version, :sha => app.git_sha, :user => nil, :group => nil, :permissions => nil}.merge(app.stat)
      }
    }
    end
  end
end
