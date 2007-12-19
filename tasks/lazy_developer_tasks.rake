
namespace :test do

  rule /^test/ do |t|
    root = t.name.gsub("test:","").split(/:/)
    if root.length >= 3
    flag = root[0]
    file_name = root[1]
    test_name = root[2]
    test_name = "" if test_name == "all"


      functional = (flag == "functionals" || flag == "f")
      unit = (flag == "units" || flag == "u")


      if (unit)
        file_path = "unit/#{file_name}_test.rb" 
      end

      if (functional)
        file_path = "functional/#{file_name}_controller_test.rb" 
      end

      if (!File.exist?("test/#{file_path}"))
        raise "No file found for #{file_path}" 
      end

      sh "ruby test/#{file_path} -n /^test_#{test_name}/" 
    else
      puts "invalid arguments. Specify the type of test, filename, and test name"
    end
  end

  
 
  
end



namespace :db do
  
    # Override the original Rake task to clone the test database too
    task :migrate do
      puts "Preparing Test database"
      Rake::Task['db:test:clone'].invoke
    end

    # Drops and remigrates tables in case you hurt your database somehow
    # Borrowed from http://errtheblog.com/post/3
    desc "Drops and re-migrates tables"
    task :remigrate => :environment do 
        # don't run in production mode
        return unless %w(development test).include? RAILS_ENV
        ActiveRecord::Base.connection.tables.each { |t| ActiveRecord::Base.connection.drop_table t }
        Rake::Task['db:migrate'].invoke

    end
  
  
end





namespace :rails do
  
  namespace :install do 
   
    desc "installs your favorite plugins by looking in your home folder for a file called .plugins"
    task :plugins do
    
     File.open("#{ENV['HOME']}/.plugins", "r") do |f|
       while (line = f.gets)
         begin
         sh "ruby script/plugin install #{line}"
         rescue
           puts "Couldn't install #{line}"
         end
       end
        
     end
    end
  
    desc "installs the required gems for this project"
    task :gems do
     sudo = PLATFORM.include?("win32") ? "" : "sudo"
     File.open("./.gems", "r") do |f|
       while (line = f.gets)
         begin
         sh "#{sudo} gem install #{line} --include-dependencies"
         rescue
           puts "Couldn't install #{line}"
         end
       end
        
     end
     
    end  #install
    
  end # rails
  
  namespace :clear do
    desc "Clean up all temp, logs, and docs"
    task :all do
      
      Rake::Task['tmp:clear'].invoke
      Rake::Task['log:clear'].invoke
      Rake::Task['doc:clobber_rails'].invoke
      
    end
  end
end