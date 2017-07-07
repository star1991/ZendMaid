class CreateAttachedNotes < ActiveRecord::Migration
  def change
    create_table :attached_notes do |t|
      t.text :body
      t.references :noteable, :polymorphic => true
      
      t.timestamps
    end
    
    add_index :attached_notes, [:noteable_id, :noteable_type]
  end
end
