require 'fileutils'
namespace :db do

  namespace :migrate do

    desc "Uses schema.rb to build a new base migration with the timestamp of the current migration. Other migrations are   moved to a backup folder."
    task :compact => [:abort_if_pending_migrations, :environment] do

      file = File.read("#{RAILS_ROOT}/db/schema.rb")

      main_content_regex = /ActiveRecord::Schema.define\(:version => (.*)\) do(.*)^end/m
      main_content_regex.match file
      create_part = $2 # the second group holds what I want.

      lines = file.split("\n")

      table_regex = /create_table (.*),(.*)/

      index_regex = /add_index "(.*)", \[(.*)\], :name => "(.*)"/

      tables = lines.collect{|line| "  drop_table #{$1}" if line =~ table_regex }

      # hack to correct spacing so it "looks pretty"
      create_part.gsub!("\n", "\n  ")

      # reverse the order so the indexes get taken out in the opposite order
      # they were added. Also add two spaces to the start of each line
      drop_tables =  tables.compact.reverse.join("\n  ")
      drop_indexes = DbMigrateMerge.generate_down_indexes lines
      drop_indexes = drop_indexes.join("\n    ")

      new_migration = %Q{# Migration created #{Time.now.to_s} by lazy_developer
class InitialMigration < ActiveRecord::Migration
  def self.up
    #{create_part}
  end

  def self.down
    #{drop_indexes}

  #{drop_tables}
  end
end
}
    version =  ActiveRecord::Migrator.current_version
    backups = RAILS_ROOT+"/db/migrate_#{version}"

    svn=File.exist?(RAILS_ROOT+"/db/migrate/.svn")
    if svn
      `svn mkdir #{backups}`
      Dir.glob(RAILS_ROOT+"/db/migrate/*").each do |migration|
        puts "moving #{migration}"
        `svn mv #{migration} #{backups}`
      end
    else
      FileUtils.mv(RAILS_ROOT+"/db/migrate", backups)
      FileUtils.mkdir(RAILS_ROOT+"/db/migrate")
    end

    new_file = RAILS_ROOT+"/db/migrate/#{version}_initial_migration.rb"

    File.open(new_file, "w") do |f|
      f << new_migration
    end

    `svn add #{new_file}` if svn

    puts "Created #{new_file}."
    puts "Previous migrations are in #{backups}"
    end

  end

end
