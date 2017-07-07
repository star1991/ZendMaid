class RenameColumnInstructionsToNotesInCustomers < ActiveRecord::Migration
  def up
    rename_column :customers, :instructions, :notes
  end

  def down
    rename_column :customers, :notes, :instructions
  end
end
