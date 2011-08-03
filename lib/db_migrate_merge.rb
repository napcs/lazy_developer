class DbMigrateMerge
  def self.generate_down_indexes lines
    indexes = lines.collect do |line|
      columns_regex = /add_index "[^"]+", ?(?::column ?=> ?)?(\[[^\]]+\]|"[^"]+")/

      index_regex = /add_index "[^"]+", ?(?::name ?=> ?)?"([^"]+)"/
      table_regex = /add_index "([^"]+)"/

      if line =~ table_regex
        table_name = $1
        columns = line =~ columns_regex
        if columns
          if $1.index "["
            "remove_index :#{table_name}, :column => #{$1}"
          else
            "remove_index :#{table_name}, :column => [#{$1}]"
          end
        elsif line =~ index_regex
          "remove_index :#{table_name}, :name => \"#{$1}\""
        end
      end

    end

    indexes.compact.reverse.join("\n  ")
  end

end
