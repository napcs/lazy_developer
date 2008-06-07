
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
  
  desc "create tag"
  task :tag do
    raise "You have to pass a tag name -  rake svn:tag TAG=rel_1-0-0" if ENV["TAG"].nil?
    tagname = ENV["TAG"]
    `svn cp #{get_svn_root}/trunk #{get_svn_root}/tags/#{tagname} -m "tag created by Lazy Developer"`
  end
  
  
  
  namespace :tags do 
      desc "show the last tag"
      task :last do
        
        puts get_svn_tags.split("\n").last
      end
  end
  desc "show the tags"
  task :tags  do
    
    puts get_svn_tags 
  end
  
end