VERSION="1.1.0"

namespace :lazy do
  desc "Shows the version of Lazy Developer this app uses"
  task :version do
    puts "LazyDeveloper v#{VERSION}"
  end

end


namespace :db do
  
    # Override the original Rake task to clone the test database too
    task :migrate do
       unless RAILS_ENV == "production"
        puts "Preparing Test database"
        Rake::Task['db:test:clone'].invoke
      end
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