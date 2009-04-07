namespace :nuke do
  
  rule /^nuke/ do |t|
    Rake::Task['environment'].invoke
    
    root = t.name.gsub("nuke:", "").split(/:/)
    type = root[0]
    file = root[1].underscore
    
    puts "Nuking #{type} named #{file}"

    case type
      when "vc"
        nuke_controller(file)
        nuke_helper(file)
        nuke_view(file)
      when "all", "resource", "mvc"
        nuke_model(file)
        nuke_controller(file)
        nuke_helper(file)
        nuke_view(file)
      when "model", "m"
        nuke_model(file)
      when "controller", "c"
        nuke_controller(file)
      when "helper", "h"
        nuke_helper(file)
                  
    end    
  end
  
  def nuke_view(f)
        remove "app/views/#{f}"
        remove "spec/views/#{f}"
        
  end
  
  def nuke_model(f)
    remove "app/models/#{f}.rb"
    remove "spec/models/#{f}_spec.rb"
    remove "test/unit/#{f}_test.rb"
  end
  
  def nuke_helper(f)
    remove "app/helpers/#{f}_helper.rb"
    remove "spec/helpers/#{f}_helper_spec.rb"
    
  end
  def nuke_controller(f)
    remove "app/controllers/#{f}_controller.rb"
    remove "spec/controllers/#{f}_controller_spec.rb"
    remove "test/functional/#{f}_controller_test.rb"
  end
  
  def remove(file)
    scm = if File.exist?(".svn")
            "svn"
          elsif File.exist?(".git")
            "git"
          else
            ""
          end
    
    rm_cmd = scm.blank? ? "rm -rf" : "#{scm} rm"
    puts `#{rm_cmd} #{file}`
  end
  
  
end