class CreateTemplateJobs < ActiveRecord::Migration
  def change
    create_table :template_jobs do |t|
      t.datetime :scheduled_on
      t.datetime :sent_on
      t.references :sendable, :polymorphic => true
      t.references :reportable, :polymorphic => true
      
      t.timestamps
    end
    
    add_index :template_jobs, :scheduled_on
    add_index :template_jobs, [:sendable_id, :sendable_type]
    add_index :template_jobs, [:reportable_id, :reportable_type]
  end
end
