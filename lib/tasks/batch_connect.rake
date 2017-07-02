namespace :batch_connect do
  desc "Generate new batch connect session"
  task new_session: :environment do
    # Read in user settings
    app = ENV["BC_APP_TOKEN"] || abort("Missing environment variable BC_APP_TOKEN")
    ctx = ENV["BC_SESSION_CONTEXT"]
    fmt = ENV["BC_RENDER_FORMAT"]

    # Initialize objects
    app   = BatchConnect::App.from_token app
    fmt ||= app.cluster.job_config[:adapter] if app.cluster
    session_ctx = app.build_session_context
    session_ctx.from_json( ctx ? File.read(ctx) : "{}" )

    # Generate new session
    session = BatchConnect::Session.new
    session.save(app: app, context: session_ctx, format: fmt)
  end
end
