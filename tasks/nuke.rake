namespace :nuke do
  
  rule /^nuke/ do |t|
    if File.exist?('script/rails_generate')
      File.open("log/generator.log","a"){|f|f.puts("rake "+t.to_s)}  
    end
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
    p = f.classify.tableize
    s = p.singularize
    remove "app/models/#{s}.rb"
    remove "spec/models/#{s}_spec.rb"
    remove "test/unit/#{s}_test.rb"
    remove "test/fixtures/#{p}.yml" #plural
  end
  
  def nuke_helper(f)
    remove "app/helpers/#{f}_helper.rb"
    remove "spec/helpers/#{f}_helper_spec.rb"
  end

  def nuke_controller(f)
    remove "app/controllers/#{f}_controller.rb"
    remove "spec/controllers/#{f}_controller_spec.rb"
    remove "test/functional/#{f}_controller_test.rb"
    remove "test/unit/helpers/#{f}_helper_test.rb"
  end
  
  def remove(file)
    return unless File.exist?(file)

    scm = File.exist?(".svn") ? "svn rm" : ""
    rm_cmd = scm.blank? ? "rm -rf" : "#{scm}"
    puts 'delete  '.rjust(12) + file
    `#{rm_cmd} #{file}`
  end
  
end
