namespace :lazy do

  namespace :logger do

    desc "Begin recording all generators and nukes run in the application, logging to logs/generator.log"
    task :install do # No reason to invoke the environment, but should I - to ensure we're in a Rails app?
      move('script/generate','script/rails_generate')    
      File.open('script/generate','w',0755) do |f|
        f.write(%Q{#!/usr/bin/env ruby
  
File.open("log/generator.log","a"){|f|f.puts("script/generate "+ARGV.join(" "))}
`ruby script/rails_generate #\{ARGV.join(" ")\}`})
      end

      File.open('log/generator.log','w') do |f|
        f.write(%Q{# Generator Log
# Courtesy of lazy_developer, Copyright (c) 2009 Brian P. Hogan & Kevin W. Gisi
})
      end
    end

    desc "Do not log generate and nuke commands"
    task :remove do # Same question
      move('script/rails_generate','script/generate')
    end

    def move(target,destination)
      puts "#{target} -> #{destination}"
      `mv #{target} #{destination}`
    end
  end
end
