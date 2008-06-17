# Lazy Testing
# Kevin Gisi
# 06/17/08
# Copyright(c) 2008, released under MIT License

namespace :rcov do
    
  # Runs all unit tests, and determines coverage
  # only on the model level.
  desc "Run unit tests, and determine coverage on models."
  task :models do
    ENV["SHOW_ONLY"] = "m"
    Rake::Task['test:units:rcov'].invoke
  end
    
  # Runs all functional tests, and determines coverage
  # only on the controller level.
  desc "Run functional tests, and determine coverage on controllers."
  task :controllers do
    ENV["SHOW_ONLY"] = "c"
    Rake::Task['test:functionals:rcov'].invoke
  end
  
  # Runs all unit and functional tests, and determines
  # coverage on models and controllers respectively.
  desc "Run functional and unit tests, and get coverage for both."
  task :full do
    Rake::Task['rcov:models'].invoke
    Rake::Task['rcov:controllers'].invoke
  end
  
  # Runs all unit and functional tests, and determines
  # coverage on models and controllers respectively, ignoring errors.
  desc "Run functional and unit tests, and get coverage for both, ignoring errors."
  task :report do
    begin
      Rake::Task['rcov:models'].invoke
    ensure
      Rake::Task['rcov:controllers'].invoke
    end
  end
  
end
