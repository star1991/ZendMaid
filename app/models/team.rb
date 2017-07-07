# == Schema Information
#
# Table name: teams
#
#  id             :integer          not null, primary key
#  user_id        :integer
#  name           :string(255)
#  calendar_color :string(255)      default("#026b9c")
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class Team < ActiveRecord::Base
  attr_accessible :name, :user_id, :calendar_color, :teams_employees_attributes
  
  has_many :teams_employees, :dependent => :destroy
  has_many :employees, :through => :teams_employees
  
  has_many :appointments
  belongs_to :user
  
  validates_presence_of :name, :user_id
  validate :at_least_one_employee_assigned
  validate :invalid_characters
  accepts_nested_attributes_for :teams_employees, :reject_if => :all_blank, :allow_destroy => true
  
  def build_all_missing_teams_employees(user)
    (user.employees.active.map(&:id) - self.teams_employees.map(&:employee_id)).each do |id|
      self.teams_employees.build(:employee_id => id)
    end   
  end

  def at_least_one_employee_assigned
    if self.teams_employees.select { |t_e| !t_e.marked_for_destruction? }.size == 0
      errors.add(:name, 'must have at least one cleaner assigned to it')
    end
  end

  def invalid_characters
    if self.name.index('&').present?
      errors.add(:name, 'cannot contain the following characters: &')
    end
  end

end
