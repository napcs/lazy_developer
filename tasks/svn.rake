
def get_svn_root
   `svn info | grep URL`.gsub("URL: ", "").gsub("/trunk", "").chop!
end

def get_svn_tags
  cmd = "svn ls #{get_svn_root}/tags"
  `#{cmd}`.chop!  
end



namespace :svn do
  desc "display the root path for svn"
  task :root do
    
    puts get_svn_root
  end
  
  desc "create tag  - expects TAG='tag_name"
  task :tag do
    raise "You have to pass a tag name -  rake svn:tag TAG=rel_1-0-0" if ENV["TAG"].nil?
    tagname = ENV["TAG"]
    `svn cp #{get_svn_root}/trunk #{get_svn_root}/tags/#{tagname} -m "tag created by Lazy Developer"`
  end
  
  
  
  namespace :tags do 
      desc "show the last tag, assuming you've used some sort of naming scheme that uses ascending order"
      task :last do
        
        puts get_svn_tags.split("\n").last
      end
  end
  desc "show the tags"
  task :tags  do
    
    puts get_svn_tags 
  end
  
 desc "Fix your app for use with Subversion by removing files you might not need."
 task :configure_for_svn do
   system "svn remove log/*"
   system "svn commit -m 'removing all log files from subversion'"
   system 'svn propset svn:ignore "*.log" log/'
   system "svn update log/"
   system "svn commit -m 'Ignoring all files in /log/ ending in .log'"
   system 'svn propset svn:ignore "*.db" db/'
   system "svn update db/"
   system "svn commit -m 'Ignoring all files in /db/ ending in .db'"
   system 'svn propset svn:ignore "*.sqlite3" db/'
   system "svn update db/"
   system "svn commit -m 'Ignoring all files in /db/ ending in .sqlite3'"
   system "svn move config/database.yml config/database.example"
   system "svn commit -m 'Moving database.yml to database.example to provide a template for anyone who checks out the code'"
   system 'svn propset svn:ignore "database.yml" config/'
   system "svn update config/"
   system "svn commit -m 'Ignoring database.yml'"
   system "svn remove tmp/*"
   system "svn commit -m 'Removing /tmp/ folder'"
   system 'svn propset svn:ignore "*" tmp/'
 end
  
  
  
  
  
end