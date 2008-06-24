# Lazy Specs
# Kevin Gisi
# 06/24/08
# Copyright(c) 2008, released under MIT License

namespace :spec do
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