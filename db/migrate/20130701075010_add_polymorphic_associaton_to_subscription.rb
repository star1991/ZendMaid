class AddPolymorphicAssociatonToSubscription < ActiveRecord::Migration
  def up
    remove_index :subscriptions, :customer_id
    remove_column :subscriptions, :customer_id
    
    remove_column :subscriptions, :frequency
    add_column :subscriptions, :frequency, :integer
    
    add_column :subscriptions, :materialized_until, :datetime
    add_column :subscriptions, :constraints, :text
    add_column :subscriptions, :repeat_on, :text
    
    
    change_table :subscriptions do |t|
      t.references :subscriptionable, :polymorphic => true
    end
    add_index :subscriptions, [:subscriptionable_type, :subscriptionable_id], :name => "index_subscriptions_polymorphic_associations"
  end
  
  def down
    add_column :subscriptions, :customer_id
    add_index :subscriptions, :customer_id
    
    remove_column :subscriptions, :frequency
    add_column :subscriptions, :frequency, :string
    
    remove_column :subscriptions, :materialized_until, :datetime
    remove_column :subscriptions, :constraints, :text
    remove_column :subscriptions, :repeat_on, :text
    
    remove_index :subscriptions, [:subscriptionable_type, :subscriptionable_id]
    change_table :subscriptions do |t|
      t.remove_references :subscriptionable, :polymorphic => true
    end
    
  end
end
