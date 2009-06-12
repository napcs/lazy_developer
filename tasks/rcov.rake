namespace :spec do
  require 'spec/rake/spectask'
  spec_prereq = File.exist?(File.join(RAILS_ROOT, 'config', 'database.yml')) ? "db:test:prepare" : :noop
  
  
  [:models, :controllers, :views, :helpers, :lib].each do |sub|
    namespace sub do
      desc "RCov for #{sub}"
      Spec::Rake::SpecTask.new("rcov" => spec_prereq) do |t|
        t.spec_opts = ['--options', "\"#{RAILS_ROOT}/spec/spec.opts\""]
        t.spec_files = FileList["spec/#{sub}/**/*_spec.rb"]
        t.rcov = true
        
        t.rcov_opts = lambda do
          reg_exp = []
          reg_exp << case sub.to_s
                      when 'models'
                         'app\/models'
                      when 'views'
                         'app\/views'
                      when 'controllers'
                         'app\/controllers'
                      when 'helpers'
                         'app\/helpers'
                      when 'lib' 
                        'lib'
                     end
          reg_exp.map!{ |m| "(#{m})" }
          rcov_opts = " -x \"^(?!#{reg_exp.join('|')})\""
          rcov_opts.map {|l| l.chomp.split " "}.flatten
        end
     
      end
    end
  end
end

namespace :test do

  namespace :models do
    desc "Run unit tests, and determine coverage on models."
    task :rcov do
      ENV["SHOW_ONLY"] = "m"
      Rake::Task['test:units:rcov'].invoke
    end
  end
  
  namespace :controllers do
    desc "Run functional tests, and determine coverage on controllers."
    task :rcov do
      ENV["SHOW_ONLY"] = "c"
      Rake::Task['test:functionals:rcov'].invoke
    end
  end
  
  namespace :rcov do
    
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
        Rake::Task['test:models:rcov'].invoke
      ensure
        begin
          Rake::Task['test:controllers:rcov'].invoke
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
          to_write = "<html><body><h1>Rcov Report</h1>
          <div style=\"width:100%; height:50px; border: 1px solid black\"><div style=\"height: 50px; width: #{units}%; background-color: #33FF00; font-size: 18pt; font-style: bold\"><a href=\"units/index.html\">Unit: #{units}</a></div></div><br />
          <div style=\"width:100%; height:50px; border: 1px solid black\"><div style=\"height: 50px; width: #{functionals}%; background-color: #33FF00; font-size: 18pt; font-style: bold\"><a href=\"functionals/index.html\">Functional: #{functionals}</a></div></div>
          </body></html>"
          File.open("coverage/report.html", "w") do |f|
        		f.puts to_write
        	end
      	
        	if PLATFORM['darwin']
            system("open #{pwd}/coverage/report.html")
          end
        end
      end
    end
  end
  
end


namespace :rcov do
    
  # Runs all unit tests, and determines coverage
  # only on the model level.
  desc "Run unit tests, and determine coverage on models."
  task :models do
    Rake::Task['test:models:rcov'].invoke
  end
    
  # Runs all functional tests, and determines coverage
  # only on the controller level.
  desc "Run functional tests, and determine coverage on controllers."
  task :controllers do
    Rake::Task['test:controllers:rcov'].invoke
  end
  
  desc "Run functional and unit tests, and get coverage for both, ignoring errors."
  task :report do
    Rake::Task['test:rcov:report'].invoke
  end
  
  desc "Run functional and unit tests, and get coverage for both."
  task :full do
    Rake::Task['test:rcov:full'].invoke
  end
  
end
