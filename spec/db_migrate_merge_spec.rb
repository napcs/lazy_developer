current_directory = File.join File.dirname(__FILE__)
require File.join(current_directory, '../lib/db_migrate_merge')

describe DbMigrateMerge do
  describe "#remove_index" do
    #___________________
   it "handles indexes with just a column name" do
      line = <<-eof
add_index "versions", "versioned_type"
eof

      expected = <<-ex
    remove_index :versions, :column => ["versioned_type"]
ex

      DbMigrateMerge.generate_down_indexes([line]).should == expected[0..-2]
    end





    #___________________
    it "handles indexes with only one column name and an index name" do

      line = <<-eof
add_index "audited", "transaction", :name => "index_audited_on_transaction"
eof

      expected_line = <<-eof
    remove_index :audited, :column => ["transaction"]
eof

      expected = [expected_line].join()[0..-2]
      DbMigrateMerge.generate_down_indexes([line]).should == expected

    end


    #___________________
    it "works with an array of column names and an index name" do
      line = <<-eof
add_index "versions", ["versioned_type", "versioned_id"], :name => "index_versions_on_versioned_type_and_versioned_id"
eof

      expected = <<-ex
    remove_index :versions, :column => ["versioned_type", "versioned_id"]
ex
      DbMigrateMerge.generate_down_indexes([line]).should == expected[0..-2]
    end

     it "handles indexes with a column name with the :column => hash rocket syntax" do
      line = <<-eof
add_index "versions", :column => ["versioned_type", "versioned_id"], :name => "index_versions_on_versioned_type_and_versioned_id"
eof

      expected = <<-ex
    remove_index :versions, :column => ["versioned_type", "versioned_id"]
ex

      DbMigrateMerge.generate_down_indexes([line]).should == expected[0..-2]

      line = <<-eof
add_index "versions", :column => ["versioned_type"], :name => "index_versions_on_versioned_type"
eof

      expected = <<-ex
    remove_index :versions, :column => ["versioned_type"]
ex

      DbMigrateMerge.generate_down_indexes([line]).should == expected[0..-2]


    end



     it "handles indexes with a column name with the :column => hash rocket syntax" do
      line = <<-eof
add_index "versions", :name => "index_versions_on_versioned_type_and_versioned_id"
eof

      expected = <<-ex
    remove_index :versions, :name => "index_versions_on_versioned_type_and_versioned_id"
ex

      DbMigrateMerge.generate_down_indexes([line]).should == expected[0..-2]

    end
  end

end
