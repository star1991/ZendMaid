# == Schema Information
#
# Table name: leads
#
#  id                    :integer          not null, primary key
#  name                  :string(255)
#  email                 :string(255)
#  phone_number          :string(255)
#  company_name          :string(255)
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  stripe_customer_token :string(255)
#  plan_id               :string(255)
#

class Lead < ActiveRecord::Base
  include PhoneNumberHelper
  
  attr_accessible :email, :name, :phone_number, :company_name, :plan_id, :card_number, :expiry_date, :cvc

  attr_accessor :card_number, :charge, :mark_appointment_as_paid, :cvc, :api_error, :expiry_month, :expiry_year
 
  validates_presence_of :name, :company_name
  validates_presence_of :email
  validates_presence_of :card_number
  validates_presence_of :expiry_date
  validates_presence_of :cvc
  validates_presence_of :stripe_customer_token

  before_save do |lead|
    lead.email = email.downcase
  end

  before_validation :create_plan

  # Errors added outside of validation callbacks are wiped when the model is saved. Do this to keep errors around
  validate :add_api_error_to_base

  def expiry_date
    if @expiry_date.present?
       @expiry_date
    else 
      self.expiry_month.present? ? "#{expiry_month}/#{expiry_year}" : ""
    end
  end

  def expiry_date=(input)
    @expiry_date = input
    split_date = @expiry_date.split("/")

    self.expiry_month = split_date[0]
    self.expiry_year = split_date[1]

  end

  # TODO: Can only handle one error for now, couldn't figure out how to initialize a virtual attribute as an array
  def add_api_error_to_base
    if self.api_error.present?
      errors[:base] << self.api_error
    end
  end

  def create_plan
    begin
      if self.name.present? && self.email.present? && self.company_name.present?
        customer = Stripe::Customer.create(
          :email => self.email, 
          :description => "#{self.name} LAUNCH", 
          :card => {
            :number => self.card_number,
            :exp_month => self.expiry_month,
            :exp_year => self.expiry_year,
            :cvc => self.cvc
            }, 
          :plan => self.plan_id
        )
        self.stripe_customer_token = customer.id
      end

    rescue => e
      self.api_error = e.message
      return false
    end 
  end

end
