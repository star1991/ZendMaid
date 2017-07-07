# == Schema Information
#
# Table name: credit_cards
#
#  id                 :integer          not null, primary key
#  customer_id        :integer
#  masked_card_number :string(255)
#  expiry_month       :integer
#  expiry_year        :integer
#  token              :text
#  card_type          :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class CreditCard < ActiveRecord::Base
  include ApplicationHelper

  attr_accessible :card_type, :customer_id, :cvc, :expiry_month, :expiry_year, :masked_card_number, :token, :card_number, 
  	:mark_appointment_as_paid, :expiry_date, :charge

  attr_accessor :card_number, :charge, :mark_appointment_as_paid, :cvc, :api_error

  belongs_to :customer
  has_one :user, :through => :customer

  before_validation :format_charge_for_validation

  validates :charge, :format => { :with => /^\d+??(?:\.\d{0,2})?$/, :message => "must be a valid US Dollar Amount (e.g., $1.00 or $1)"}, :numericality => {:greater_than_or_equal_to => 0, :less_than => 1000000}, :allow_blank => true
  validates_presence_of :card_number, :if => :new_record?
  validates_presence_of :expiry_date
  validates_presence_of :cvc, :if => :new_record?

  # KLUDGEY, but error should fire anyways if card isn't set properly
  validates_presence_of :token, :unless => :new_record?

  validates_presence_of :card_type
  validates_presence_of :masked_card_number
  validates_presence_of :charge, :if => Proc.new { |cc| !cc.new_record? }

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

  # TODO: Allow multi-currency support (not just USD)
  def process_charge(payment_gateway, charge)
    begin
      if self.charge.present?
        response = Stripe::Charge.create({
          :amount => (self.charge.to_f * 100).round,
          :currency => "usd",
          :card => self.token,
          :customer => self.customer.stripe_customer_id,
          :description => "Charge from ZenMaid on #{Time.zone.now.strftime("%m/%d/%Y")}"
          }, payment_gateway.stripe_api_key)
      end
      return true
    rescue => e
      self.api_error = e.message
      return false
    end 
  end

  def format_charge_for_validation
    if self.charge.present? && !is_numeric?(self.charge)
      self.charge = self.charge.gsub(/[^\d\.]/, '')
    end
  end

  # Creates card and attaches it to new customer (or adds it to current customer if )
  def register_card(payment_gateway, customer)
    begin
      # Create the token
      response = Stripe::Token.create({
        :card => {
          :number => self.card_number,
          :exp_month => self.expiry_month,
          :exp_year => self.expiry_year,
          :cvc => self.cvc
      }}, payment_gateway.stripe_api_key)

      self.token = response[:card][:id]
      self.card_type = response[:card][:brand]
      logger.debug response

      # Add the card to a customer (or create the customer, if necessary)
      if customer.stripe_customer_id.present?
        stripe_customer = Stripe::Customer.retrieve(customer.stripe_customer_id, payment_gateway.stripe_api_key)
        stripe_customer.sources.create({:source => response.id}, payment_gateway.stripe_api_key)
      else
        stripe_customer = Stripe::Customer.create({
          :description => customer.full_name,
          :source => response.id
          }, payment_gateway.stripe_api_key)
          customer.update_column(:stripe_customer_id, stripe_customer.id)
      end

      logger.debug stripe_customer
    rescue => e
      self.api_error = e.message
    end
  end

end
