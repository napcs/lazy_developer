class DbMigrateMerge
  def self.generate_down_indexes lines
    indexes = lines.collect do |line|
      multiple_columns_regex = /add_index "(.*)", \[([^\]]+)\], :name => "(.*)"/
      single_columns_regex = /add_index "(.*)", (.*), :name => "(.*)"/

      if line =~ multiple_columns_regex
        table_name = $1
        column_names = $2
        index_name = $3
        "remove_index :#{table_name}, [#{column_names}], :name => :#{index_name}"

      elsif line =~ single_columns_regex
        table_name = $1
        column_name = $2
        index_name = $3
        "remove_index :#{table_name}, #{column_name}, :name => :#{index_name}"

      end
    end

    indexes.compact.reverse.join("\n  ")
  end


end
