class ChangeUseAsPrototypeDefaultToFalse < ActiveRecord::Migration
  def up
    change_column :appointments, :use_as_prototype, :boolean, :default => false
    
    Subscription.reset_column_information
    Subscription.all.each do |s|
      existing_prototype = s.appointments.order('appointments.start_time DESC').try(:first)
      
      if existing_prototype.present?
        s.appointments.update_all(:use_as_prototype => false)
        
        if s.repeat
          new_prototype = existing_prototype.dup_with_repeatable_associations
          new_prototype.use_as_prototype = true
          new_prototype.save
        end
      end
    end
  end

  def down
    change_column :appointments, :use_as_prototype, :boolean, :default => true
  end
end
