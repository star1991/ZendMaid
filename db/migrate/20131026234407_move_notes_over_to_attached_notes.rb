class MoveNotesOverToAttachedNotes < ActiveRecord::Migration
  def up
    Customer.reset_column_information
    
    Customer.all.each do |customer|
      if customer.notes.present?
        attached_note = customer.attached_notes.build(:body => customer.notes)
        attached_note.save!
      end
    end
    
    remove_column :customers, :notes
  end

  def down
    
    add_column :customers, :notes, :text
  end
end
