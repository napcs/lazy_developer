require 'lazy_developer'
require 'rails'
module LazyDeveloper
  class Railtie < Rails::Railtie
    railtie_name :lazy_developer

    rake_tasks do
      load "tasks/lazy_developer_tasks.rake"
      load "tasks/db_migrate_merge.rake"
      load "tasks/db_translate.rake"
      load "tasks/nuke.rake"
      load "tasks/svn.rake"
      load "tasks/rspec.rake"
      load "tasks/test_unit.rake"
      load "tasks/git.rake"
    end
  end
end