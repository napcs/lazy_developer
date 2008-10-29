require 'fileutils'
module ActiveRecord
  class Base
    
    def self.to_yaml
      object_collection = self.find(:all)
      result = Hash.new
      object_collection.each_with_index do |o, i|
        attributes = o.attributes
        result["#{self.name.to_s.downcase}_#{i}"] = o.attributes        
      end
      result.to_yaml
    end
    
  end
  
end

def write_file(filename, contents)
  puts filename
  File.open(filename, "w") do |f|
    f << contents
  end
end

def habtm_fixtures(object)
  path = RAILS_ROOT + "/test/fixtures/live"
  
  hatbms = object.reflect_on_all_associations.collect{|i| i if i.macro == :has_and_belongs_to_many}.compact
  h = Hash.new
  
  hatbms.each_with_index do |m, i|
    table = m.options[:join_table]
    p = "#{path}/#{table}.yml"
    object2 = m.klass
    
    h = Hash.new
    object.find(:all).each_with_index do |o, i|
       associations = o.send m.klass.to_s.downcase.pluralize
       associations.each do |a|
         h[a.class.to_s.downcase + i.to_s] = {"#{o.class.to_s.downcase}_id" => o.id,
                "#{a.class.to_s.downcase}_id" => a.id
                }
       end 
       
    end
    write_file p, h.to_yaml
    
    
  end

  
end


namespace :db do

  desc "Load fixtures into the current environment's database.  Load specific fixtures using FIXTURES=x,y"
  task :import => :environment do
    require 'active_record/fixtures'
    ActiveRecord::Base.establish_connection(RAILS_ENV.to_sym)
    (ENV['FIXTURES'] ? ENV['FIXTURES'].split(/,/) : Dir.glob(File.join(RAILS_ROOT, 'test', 'fixtures/live', '*.{yml,csv}'))).each do |fixture_file|
      Fixtures.create_fixtures('test/fixtures/live', File.basename(fixture_file, '.*'))
    end
  end
 
  desc "Dump all data to fixtures/live folder"
  task :export => :environment do
    path = RAILS_ROOT + "/test/fixtures/live"
    #models = %W{Account Profile Portfolio Item Presentation Publication Experience Proficiency Skill Role}
    
    models= Dir.glob("#{RAILS_ROOT}/app/models/*.rb").collect{|c| c.gsub("#{RAILS_ROOT}/app/models/", "").gsub(".rb", "").camelize}
    FileUtils.mkdir_p path rescue nil
    models.each do |m|
      begin
      object = m.constantize
      
      str =  object.to_yaml

      write_file "#{path}/#{object.table_name}.yml", str
      habtm_fixtures(object)
      rescue
        "skipping - not a model"
      end
    end
    
  end
  
end