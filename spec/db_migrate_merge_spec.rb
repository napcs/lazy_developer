current_directory = File.join File.dirname(__FILE__)
require File.join(current_directory, '../lib/db_migrate_merge')

describe DbMigrateMerge do
  describe "#remove_index" do
    it "handles indexes with only one column name" do

      line1 = <<-eof
add_index "versions", "versioned_id", :name => "index_versions_on_versioned_type_and_versioned_id"
      eof

      line2 = <<-eof
        "add_index "audited", "transaction", :name => "index_audited_on_transaction"
eof

      expected_line_1 = <<-eof
remove_index :audited, "transaction", :name => :index_audited_on_transaction
eof

expected_line_2 = <<-eof
  remove_index :versions, "versioned_id", :name => :index_versions_on_versioned_type_and_versioned_id
eof

      expected = [expected_line_1,expected_line_2].join()[0..-2]
      DbMigrateMerge.generate_down_indexes([line1,line2]).should == expected

    end


    it "handles indexes with an array of column names" do
      line = <<-eof
add_index "versions", ["versioned_type", "versioned_id"], :name => "index_versions_on_versioned_type_and_versioned_id"
eof

expected = <<-ex
remove_index :versions, ["versioned_type", "versioned_id"], :name => :index_versions_on_versioned_type_and_versioned_id
ex
      DbMigrateMerge.generate_down_indexes([line]).should == expected[0..-2]
    end
  end

end
