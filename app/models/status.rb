# == Schema Information
#
# Table name: statuses
#
#  id                  :integer          not null, primary key
#  name                :string(255)
#  user_id             :integer
#  order               :integer
#  calendar_color      :string(255)      default("#026b9c")
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  show_by_default     :boolean          default(TRUE)
#  use_for_conflicts   :boolean          default(TRUE)
#  show_in_work_orders :boolean          default(TRUE)
#  use_for_payroll     :boolean          default(TRUE)
#  use_for_invoice     :boolean
#

class Status < ActiveRecord::Base
  attr_accessible :name, :user_id, :order, :calendar_color, :show_by_default, :show_in_work_orders, :use_for_conflicts, :use_for_payroll, :use_for_invoice
  
  default_scope :order => "statuses.order ASC"
  validates_presence_of :name
  
  belongs_to :user
  has_many :appointments
end
