class AddBalanceToCustomer < ActiveRecord::Migration
  def up
    add_column :customers, :balance, :decimal, :precision => 10, :scale => 2, :default => 0.00
    add_column :customers, :revenue, :decimal, :precision => 10, :scale => 2, :default => 0.00

    Customer.reset_column_information
    Appointment.reset_column_information

    Customer.find_each do |customer|
      customer.appointments.actual.joins(:status).where("statuses.use_for_invoice = ?", true).where("appointments.start_time < ?", Time.zone.now.end_of_day).each do |appointment|
        if appointment.price.present?
          if !appointment.paid?
            customer.balance += appointment.price
          end

          customer.revenue += appointment.price
        end
      end

      customer.save!
    end
  end

  def down
    remove_column :customers, :balance
    remove_column :customers, :revenue
  end
end
