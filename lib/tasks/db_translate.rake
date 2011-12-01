require 'fileutils'
require 'active_record' unless Rails::VERSION::STRING.to_f < 2.3
module ActiveRecord
  class Base
    
    def self.to_yaml(path, object)
      chunk_size = ENV["CHUNK"].try(:to_i)
      chunk_size ||= 1000
      
      result = Hash.new
      
      count = self.count
      first_time = true
      
      yml_export_file = "#{path}/#{object.table_name}.yml"
      if File.exists?(yml_export_file)
        File.delete(yml_export_file)
        puts "[NOTICE] Deleting #{yml_export_file} for a clean re-export of data"
      end
      
      puts "#{self.name}: exporting #{count} records"
      minimum_id = 0
      chunk_num = 0
      if count > 0
        while minimum_id
          object_collection = self.find(:all,
            :limit => chunk_size,
            :conditions => ["id > ?",minimum_id],
            :order => "id asc")
          object_collection.each do |o|
            attributes = o.attributes
            result["#{self.name.to_s.downcase}_#{attributes["id"]}"] = o.attributes
          end
          
          minimum_id = (object_collection.empty? || count < chunk_size) ? nil : object_collection.last.id
          
          chunk_num += 1
          puts "#{self.name}: #{chunk_size * chunk_num}/#{count} (#{(((chunk_size * chunk_num) / count.to_f) * 100).round}%)" unless (result.empty? || count < chunk_size)
          
          write_file yml_export_file, first_time ? result.to_yaml : result.to_yaml.split("\n")[1..-1].join("\n")+"\n"
          result = Hash.new
          first_time = false
        end
      end
      puts "#{self.name}: exported #{count} records"
    end
  end
end


def write_file(filename, contents)
  action = File.exists?(filename) ? "Appended to" : "Wrote"
  
  File.open(filename, "a") do |f|
    f << contents
  end
  
  puts "[FILE] #{action} #{filename}" unless contents.strip.empty?
end


def habtm_fixtures(object)
  path = RAILS_ROOT + "/production_data"
  
  hatbms = object.reflect_on_all_associations.collect{|i| i if i.macro == :has_and_belongs_to_many}.compact
  h = Hash.new
  
  hatbms.each_with_index do |m, i|
    table = m.options[:join_table]
    p = "#{path}/#{table}.yml"
    object2 = m.klass
    
    h = Hash.new
    object.find(:all).each_with_index do |o, i|
       associations = o.send m.klass.table_name
       associations.each do |a|
         h[a.class.to_s.underscore + i.to_s] = {"#{o.class.to_s.underscore}_id" => o.id,
                "#{a.class.to_s.underscore}_id" => a.id
                }
       end
       
    end
    write_file p, h.to_yaml
  end
end


namespace :db do

  desc "Load fixtures into the current environment's database.  Load specific fixtures using FIXTURES=x,y"
  task :from_yaml => :environment do
    require 'active_record/fixtures'
    ActiveRecord::Base.establish_connection(RAILS_ENV.to_sym)
    (ENV['FIXTURES'] ? ENV['FIXTURES'].split(/,/) : Dir.glob(File.join(RAILS_ROOT, 'production_data', '*.yml'))).each do |fixture_file|
      puts "importing #{fixture_file}"
      Fixtures.create_fixtures('production_data', File.basename(fixture_file, '.*'))
    end
  end
 
  desc "Dump all data to the production_data folder"
  task :to_yaml => :environment do
    ############ This is to give a time calculation at the end ##################
      require 'time'
      include ActionView::Helpers::TextHelper
      
      def seconds_fraction_to_time(seconds)
        hours = 0
        mins = 0
        if seconds >=  60
          mins = (seconds / 60).to_i 
          seconds = (seconds % 60 ).to_i
          
          if mins >= 60 then
            hours = (mins / 60).to_i 
            mins = (mins % 60).to_i
          end
        else
          mins = 0
          hours = 0
          seconds = seconds.floor
        end
        
        total_time = ""
        if hours > 0
          total_time << pluralize(hours, 'hour') + ", "
        end
        
        if mins > 0
          total_time << pluralize(mins, 'minute') + " and "
        end
        
        if seconds > 0
          total_time << pluralize(seconds, 'second')
        else
          total_time << "0 seconds"
        end
        
        total_time
      end
    ################################################################################
    
    path = RAILS_ROOT + "/production_data"
    
    models = ENV["MODELS"].split(",").collect{ |m| m.camelize.singularize.gsub(".rb", "")} if ENV["MODELS"]
    models ||= Dir.glob("#{RAILS_ROOT}/app/models/*.rb").collect{|c| c.gsub("#{RAILS_ROOT}/app/models/", "").gsub(".rb", "").camelize}
    
    start_time = Time.now
    
    FileUtils.mkdir_p path rescue nil
    models.each do |m|
      begin
        this_models_start_time = Time.now
        
        object = m.constantize
        puts "[DB] Dumping data for #{object}"
        str =  object.to_yaml(path, object)
        
        # get the association data for has_and_belongs_to_many
        habtm_fixtures(object)
        
        puts "[TIME] It took #{seconds_fraction_to_time(Time.now - this_models_start_time.to_time)} to export the data for the #{m} model"
      rescue => e
        puts "[ERROR] #{e} skipping '#{m}' - not a model"
      end
    end
    puts "[TOTAL TIME] It took #{seconds_fraction_to_time(Time.now - start_time.to_time)} total to export the data your requested"
  end
end