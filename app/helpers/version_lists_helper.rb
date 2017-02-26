module VersionListsHelper
  def compare_versions_github_link(app1, app2)
    return "" if app1.git_version == app2.git_version
    return "Git remotes differ" if app1.git_remote_origin_url != app2.git_remote_origin_url

    rx = /((git@github\.com:)|(https:\/\/github\.com\/))(.*)\.git/

    # FIXME: the check to see if repos differ should be done prior to this
    repo1 = app1.git_remote_origin_url.match(rx).captures.last
    repo2 = app2.git_remote_origin_url.match(rx).captures.last

    if repo1 && repo2 && repo1 == repo2
      repo = $4
      link_to "#{app1.git_version}...#{app2.git_version}", ("https://github.com/%s/compare/%s...%s" % [repo, app1.git_version, app2.git_version]), target: "_blank"
    else
      "not a git repo or repos differ"
    end
  end
end
