
namespace :test do

  rule /^test/ do |t|
    root = t.name.gsub("test:","").split(/:/)
    if root.length >= 3
    flag = root[0]
    file_name = root[1]
    test_name = root[2]
    test_name = "" if test_name == "all"


      functional = (flag == "functionals" || flag == "f")
      unit = (flag == "units" || flag == "u")


      if (unit)
        file_path = "unit/#{file_name}_test.rb" 
      end

      if (functional)
        file_path = "functional/#{file_name}_controller_test.rb" 
      end

      if (!File.exist?("test/#{file_path}"))
        raise "No file found for #{file_path}" 
      end

      sh "ruby -itest test/#{file_path} -n /^test_#{test_name}/" 
    else
      puts "invalid arguments. Specify the type of test, filename, and test name"
    end
  end

  
 
  
end
