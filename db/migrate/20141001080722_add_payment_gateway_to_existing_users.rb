class AddPaymentGatewayToExistingUsers < ActiveRecord::Migration
  def up
    User.reset_column_information

    User.all.each do |user|
      if user.payment_gateway.blank?
        payment_gateway = user.build_payment_gateway
        payment_gateway.save!
      end
    end
  end

  def down
  end
end
