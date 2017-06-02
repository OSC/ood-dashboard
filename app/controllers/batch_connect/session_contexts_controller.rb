class BatchConnect::SessionContextsController < ApplicationController
  # GET /batch_connect/<app_token>/session_contexts/new
  def new
    set_app
    set_sub_apps
    set_render_format
    set_session_context

    # Redirect to first valid sub app otherwise first invalid sub app
    unless @sub_apps.include? @app
      sub_app_token = ( @sub_apps.select(&:valid?).first || @sub_apps.first ).token
      redirect_to new_batch_connect_session_context_url(token: sub_app_token)
    end

    if @app.valid?
      # Read in context from cache file
      @session_context.from_json(cache_file.read) if cache_file.file?
    else
      @session_context = nil  # do not display session context form
      flash.now[:alert] = <<-EOT.html_safe
        #{@app.validation_reason} Please contact support if you see this message
      EOT
    end
  rescue BatchConnect::App::AppNotFound => e
    flash.now[:alert] = e.message
    @app = nil
  end

  # POST /batch_connect/<app_token>/session_contexts
  # POST /batch_connect/<app_token>/session_contexts.json
  def create
    set_app
    set_sub_apps
    set_render_format
    set_session_context

    # Read in context from form parameters
    @session_context.attributes = session_contexts_param

    @session = BatchConnect::Session.new
    respond_to do |format|
      if @session.save(app: @app, context: @session_context, format: @render_format)
        cache_file.write(@session_context.to_json)  # save context to cache file
        format.html { redirect_to batch_connect_sessions_url, notice: 'Session was successfully created.' }
        format.json { head :no_content }
      else
        format.html { render :new }
        format.json { render json: @session_context.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Set the app from the token
    def set_app
      @app = BatchConnect::App.from_token params[:token]
    end

    # Set the list of sub apps
    def set_sub_apps
      @sub_apps = @app.sub_app_list
    end

    # Set the session context from the app
    def set_session_context
      @session_context = @app.build_session_context
    end

    # Set the rendering format for displaying attributes
    def set_render_format
      @render_format = @app.cluster.job_config[:adapter] if @app.cluster
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def session_contexts_param
      params.require(:batch_connect_session_context).permit(@session_context.attributes.keys)
    end

    # Store session context into a cache file
    def cache_file
      OodAppkit.dataroot.join(@app.token).tap { |p| p.mkpath unless p.exist? }.join("context.yml")
    end
end
