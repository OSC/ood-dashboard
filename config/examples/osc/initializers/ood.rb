OodFilesApp.candidate_favorite_paths.tap do |paths|
  # add project space directories
  projects = User.new.groups.map(&:name).grep(/^P./)
  projects.each { |proj|
    paths[Pathname.new("/fs/project/#{proj}")] = "Project Space"
  }

  # add scratch space directories
  paths[Pathname.new("/fs/scratch/#{User.new.name}")] = "Scratch Space"
  projects.each { |proj|
    paths[Pathname.new("/fs/scratch/#{proj}")] = "Scratch Space"
  }
end

# uncomment if you want to revert to the old menu
# NavConfig.categories = ["Files", "Jobs", "Clusters", "Desktops", "Desktop Apps"]
