
def get_svn_root
  `svn info`.grep(/URL/).to_s.gsub("URL: ", "").gsub("/trunk", "").chop!
end

def get_svn_tags
  cmd = "svn ls -v #{get_svn_root}/tags"
  # get a full list, sort on date.
  tags = `#{cmd}`.to_a.sort!
  output = ""
  tags.each do |tag|
    tmp =tag.split(" ")
    output << tmp[5..-1].to_s + "\n"
  end
  output
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
    `svn cp #{get_svn_root}/trunk #{get_svn_root}/tags/#{tagname} -m "Created tag #{tagname}"`
  end
  
  
  desc "create branch"
  task :branch do
    raise "You have to pass a tag name -  rake svn:tag TAG=rel_1-0-0" if ENV["TAG"].nil?
    branch = ENV["branch"]
    `svn cp #{get_svn_root}/trunk #{get_svn_root}/branches/#{branch} -m "Created tag #{branch}"`
  end
  
  
  namespace :log do
    def get_log(limit)
      l = limit ||  25
      result = `svn log --limit #{l}`
      
    end
    
    desc "Fetches the last 25 log entries - override limit wit LIMIT=x"
    task :latest do
      s = get_log(ENV["LIMIT"])
      puts s
    end
    
    desc "get last log entry"
    task :last do
      s = get_log(1)
    end
    
    desc ""
    
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