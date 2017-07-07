class AddReminderSentOnColumns < ActiveRecord::Migration
  def up
    add_column :appointments, :reminder_sent_on, :datetime
    add_column :assignments, :work_order_sent_on, :datetime
  end

  def down
    remove_column :appointments, :reminder_sent_on, :datetime
    remove_column :assignments, :work_order_sent_on, :datetime
  end
end
