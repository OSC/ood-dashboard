module BatchConnectConcern
  extend ActiveSupport::Concern

  def bc_sys_app_groups
    OodAppGroup.groups_for(
      apps: nav_sys_apps.select(&:batch_connect_app?)
    )
  end

  def bc_usr_app_groups
    [
      OodAppGroup.new(
        title: "Shared Apps",
        apps: nav_usr_apps.select(&:batch_connect_app?)
      )
    ]
  end

  def bc_dev_app_groups
    OodAppGroup.groups_for(
      apps: nav_dev_apps.select(&:batch_connect_app?)
    )
  end
end
