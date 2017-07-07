# == Schema Information
#
# Table name: employees
#
#  id                     :integer          not null, primary key
#  first_name             :string(255)
#  last_name              :string(255)
#  email                  :string(255)
#  phone_number           :string(255)
#  user_id                :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  notes                  :text
#  calendar_color         :string(255)      default("#026b9c")
#  encrypted_password     :string(128)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0)
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  allow_sign_in          :boolean          default(FALSE)
#  show_in_grid           :boolean          default(TRUE)
#  pay_type               :string(255)
#  pay_rate               :decimal(8, 2)
#  active                 :boolean          default(TRUE)
#  inactivated_on         :datetime
#  owner                  :boolean          default(FALSE)
#  assignable             :boolean          default(TRUE)
#  admin                  :boolean          default(FALSE)
#  allow_enter_time       :boolean          default(TRUE)
#

class Employee < ActiveRecord::Base
  include PhoneNumberHelper
  
  attr_accessible :email, :first_name, :last_name, :phone_number, :user_id, :address_attributes, :employee_items_attributes, :notes, :calendar_color, 
    :team_id, :password, :password_confirmation, :remember_me, :allow_sign_in, :show_in_grid, :pay_rate, :pay_type, :active, :inactivated_on, :admin,
    :allow_enter_time

  belongs_to :user
  
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable

  has_many :predefined_obligations, :as => :subscriptionable, :class_name => "Subscription", :dependent => :destroy

  has_many :assignments, :dependent => :destroy 
  has_many :assigned_appointments, :through => :assignments, :source => :appointment
  #has_many :assigned_appointments, :through => :assignments, :source => :appointment, :conditions => {"assignments.regular" => false}
  
  #has_many :regular_appointments, :through => :assignments, :conditions => {"assignments.regular" => true}
  has_many :assigned_subscriptions, :through => :regular_appointments, :source => :subscription
  
  has_many :employee_items, :as => :customizable, :class_name => "CustomItem", :dependent => :delete_all
  has_many :payroll_entries
  
  has_one :address, :as => :addressable, :dependent => :destroy
  
  has_many :teams_employees, :dependent => :destroy
  has_many :teams, :through => :teams_employees

  validate :pay_rate_range, :if => Proc.new { self.pay_type == "Hourly" || self.pay_type == "Fixed Flat Rate" || self.pay_type == "Revenue Share" }

  accepts_nested_attributes_for :address, :reject_if => :all_blank
  accepts_nested_attributes_for :employee_items, :allow_destroy => true
  
  before_validation do |employee|
    employee.phone_number = strip_nondigits_from_phone_number phone_number
  end
  
  before_save do |employee|
    employee.email = email.downcase
  end
  
  validates :first_name, :presence => true
  validates :phone_number, :length => {:minimum => 10, :maximum => 11, :message => " must be a valid US phone number with area code"}, :allow_blank => true
  validates :email, :format=> { :with => /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i },
                    :uniqueness => { :case_sensitive => false, :message => " has already been taken" }, :allow_blank => true
  validates_presence_of :email, :if => :allow_sign_in?
  validates :user_id, :presence => true
  validates_confirmation_of :password, :if => :password_required?
  validates_length_of :password, :within => 6..128, :if => :password_required?

  # TODO: Implement before_destroy callback letting know to update totals on parent payroll if draft

  scope :active, where(:active => true)
  
  def full_name
    [first_name, last_name].join(' ')
  end
  
  # Do this because numericality validation for some reason considers the value before typecast (decimal field strips out all non-digits automatically)
  def pay_rate_range
    if self.pay_rate.blank?
      errors.add(:pay_rate, "can't be blank")
    elsif self.pay_rate <= 0
      errors.add(:pay_rate, "must be greater than 0")
    elsif self.pay_rate >= 1000000
      errors.add(:pay_rate, "must be less than 1000000")
    end
  end
  
  def password_required?
    (allow_sign_in? && encrypted_password.blank?) || (!password.blank? || !password_confirmation.blank?)
  end

  def password_fields_valid?
    self.errors[:password].blank? && self.errors[:password_confirmation].blank?
  end
  
  def active_for_authentication?
    super && self.active? && self.allow_sign_in?
  end
  
  def inactive_message
    if !self.active? || !self.allow_sign_in?
      "Your employer has not granted login access to this account. Please contact them to resolve this issue"
    else
      super
    end
  end
 
end
