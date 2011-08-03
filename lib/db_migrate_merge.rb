class DbMigrateMerge
  def self.generate_down_indexes lines
    indexes = lines.collect do |line|
      columns_regex = /add_index "[^"]+", ?(?::column ?=> ?)?(\[[^\]]+\]|"[^"]+")/

      index_regex = /add_index "[^"]+", ?(?::name ?=> ?)?"([^"]+)"/
      table_regex = /add_index "([^"]+)"/

      if line =~ table_regex
        table_name = $1
        remove = "    remove_index :#{table_name},"

        columns = line =~ columns_regex
        if columns
          if $1.index "["
            "#{remove} :column => #{$1}"
          else
            "#{remove} :column => [#{$1}]"
          end
        elsif line =~ index_regex
          "#{remove} :name => \"#{$1}\""
        else
          raise Exception.new "Expected to find an index name or column names in the db/schema.rb file but none were found:\n #{line}"
        end
      end

    end

    indexes.compact.reverse.join("\n  ")
  end

end
