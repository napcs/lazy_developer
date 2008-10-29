# Remove the tasks we're going to replace
# Be very careful with this section and please
# don't use this if you don't know what it
# actually does!
Rake::TaskManager.class_eval do
  def delete_task(name)
    @tasks.delete(name)
  end
  Rake.application.delete_task("spec:models")
  Rake.application.delete_task("spec:controllers")
end

namespace :spec do
  
  desc "Run specs for models and show nice display"
  task :models do
    puts `ruby script/spec --format s -c spec/models/*_spec.rb`
  end
  
  desc "Run specs for controllers and show nice display"
  task :controllers do
    puts `ruby script/spec --format s -c spec/controllers/*_spec.rb`
  end

    # Provides a mechanism to run specs for the given model
    # or controller.
    #
    # Example:
    #   rake spec:models:user
    #   rake spec:controllers:sessions
    rule /^spec/ do |t|
      root = t.name.gsub("spec:","").split(/:/)
      if root.length >= 2
      flag = root[0]
      file_name = root[1]
      #test_name = root[2]
      test_name = "*" if test_name == "all"


        model = (flag == "model" || flag == "m")
        controller = (flag == "controllers" || flag == "c")


        if (model)
          file_path = "models/#{file_name}_spec.rb" 
        end

        if (controller)
          file_path = "controllers/#{file_name}_controller_spec.rb" 
        end

        if (!File.exist?("spec/#{file_path}"))
          raise "No file found for #{file_path}" 
        end

        puts `ruby script/spec -c --format s spec/#{file_path}`

      else
        puts "invalid arguments. Specify the type of test, filename, and test name"
      end
    end
  
  namespace :generate do
    
    desc "Populate spec sheets for models"
    task :models => :environment do
      def empty_spec(controller)
        ["# Spec Sheet created with Lazy Specs,",
          "# A component of lazy_developer",
          "",
          "require File.dirname(__FILE__) + '/../spec_helper'",
          "require '#{controller}'",
          "",
          "describe #{controller.camelize} do",
          "",
          "end"
          ]
      end
      folder = Dir.open('app/models')
      for file in folder
  		  unless file[0,1 ] == "." || File.exists?("spec/models/#{file[0,file.length-3]}_spec.rb")
  		    File.open("spec/models/#{file[0,file.length-3]}_spec.rb", File::WRONLY|File::EXCL|File::CREAT) do |f|
  		      puts "Generated spec/models/#{f}"
        		f.puts empty_spec(file[0,file.length-3])
        	end
        end
  		end
    end
    
    desc "Populate spec sheets for controllers"
    task :controllers => :environment do
      def empty_spec(controller)
        ["# Spec Sheet created with Lazy Specs,",
          "# A component of lazy_developer",
          "",
          "require File.dirname(__FILE__) + '/../spec_helper'",
          "require '#{controller}'",
          "",
          "describe #{controller.camelize} do",
          "  integrate_views",
          "",
          "end"
          ]
      end
      folder = Dir.open('app/controllers')
      for file in folder
  		  unless file[0,1 ] == "." || File.exists?("spec/controllers/#{file[0,file.length-3]}_spec.rb")
  		    File.open("spec/controllers/#{file[0,file.length-3]}_spec.rb", File::WRONLY|File::EXCL|File::CREAT) do |f|
  		      puts "Generated spec/controllers/#{f}"
        		f.puts empty_spec(file[0,file.length-3])
        	end
        end
  		end
    end
  end
end