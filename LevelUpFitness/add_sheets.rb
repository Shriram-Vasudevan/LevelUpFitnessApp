require 'xcodeproj'

project_path = 'LevelUpFitness.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.find { |t| t.name == 'LevelUpFitness' } || project.targets.first

group = project.main_group.find_subpath('LevelUpFitness/Views', true)
file_path = 'LevelUpFitness/Views/GymSessionPlaceholders.swift'
file_ref = group.files.find { |f| f.path == 'GymSessionPlaceholders.swift' || f.path == file_path }

if file_ref.nil?
  file_ref = project.new_file(file_path)
  group << file_ref
  
  target.source_build_phase.add_file_reference(file_ref, true)
  project.save
  puts "Added GymSessionPlaceholders.swift successfully."
else
  puts "FriendRoomSheets.swift already in target."
end
