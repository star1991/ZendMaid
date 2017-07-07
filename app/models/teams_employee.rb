# == Schema Information
#
# Table name: teams_employees
#
#  id          :integer          not null, primary key
#  team_id     :integer
#  employee_id :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class TeamsEmployee < ActiveRecord::Base
  attr_accessible :employee_id, :team_id
  
  belongs_to :team
  belongs_to :employee
  
end
