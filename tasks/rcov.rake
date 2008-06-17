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
      begin
        Rake::Task['rcov:controllers'].invoke
      ensure
        units = File.open("#{Dir.pwd}/coverage/units/index.html","r").read
        units = units[units.index("coverage_code")+15,10]
        units = units[0,units.index("<")]
        functionals = File.open("#{Dir.pwd}/coverage/functionals/index.html","r").read
        functionals = functionals[functionals.index("coverage_code")+15,10]
        functionals = functionals[0,functionals.index("<")]
        puts "+-----------------------------+"
        puts "| UNIT COVERAGE:       #{units.ljust(6)} |"
        puts "| FUNCTIONAL COVERAGE: #{functionals.ljust(6)} |"
        puts "+-----------------------------+"
      end
    end
  end
  
end
