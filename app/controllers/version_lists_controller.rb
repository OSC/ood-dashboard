class VersionListsController < ApplicationController
  def index
    @build_path = ENV['OOD_BUILD_PATH'] || params[:build_path]
    raise "set query param ?build_path= or ENV['OOD_BUILD_PATH'] to valid directory: #{@build_path}" unless @build_path

    @apps = apps.concat(apps(@build_path))

    @apps = @apps.sort do |a,b|
      if a.name == b.name
        a.path.to_s <=> b.path.to_s
      else
        a.name <=> b.name
      end
    end

    # [abaqus [/users/...], abaqus[/var/www],
  end

  def show
    @path = params[:path]
    @apps = apps(@path)

    respond_to do |format|
      format.html  # show.index.erb
      format.json { render json: @apps.map { |app|
        {:name => app.name, :remote => app.git_remote_origin_url, :version => app.git_version, :sha => app.git_sha, :user => nil, :group => nil, :permissions => nil}.merge(app.stat)
      }
    }
    end
  end


  private

  def apps(path = SysRouter.base_path)
    PathRouter.apps(path || SysRouter.base_path, require_manifest: false).sort_by(&:name)
  end
end
