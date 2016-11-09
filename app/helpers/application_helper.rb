module ApplicationHelper
  def clusters
    OodAppkit::Clusters.new(OodAppkit.clusters.select(&:valid?).select(&:hpc_cluster?))
  end

  def login_clusters
    OodAppkit::Clusters.new(clusters.select(&:login_server?))
  end

  def restart_url
    "/nginx/stop?redir=#{root_path}"
  end

  def passwd_url
    ENV['OOD_DASHBOARD_PASSWD_URL'] || "#"
  end

  def app_icon_tag(app)
    if app.icon_path.file?
      image_tag app_icon_path(app.name, app.type, app.owner), class: 'app-icon', title: app.icon_path
    else # default to font awesome icon
      icon = (app.manifest.icon =~ /fa:\/\/(.*)/) ? $1 : "gear"
      content_tag(:i, "", class: ["fa", "fa-#{icon}", "app-icon"] , title: "FontAwesome icon specified: #{icon}")
    end
  end
end
