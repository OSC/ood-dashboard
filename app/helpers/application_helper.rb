module ApplicationHelper
  def clusters
    OodAppkit::Clusters.new(OodAppkit.clusters.select(&:valid?).select(&:hpc_cluster?))
  end

  def login_clusters
    OodAppkit::Clusters.new(clusters.select(&:login_server?))
  end
end
