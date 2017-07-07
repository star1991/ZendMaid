# == Schema Information
#
# Table name: tasks
#
#  id                 :integer          not null, primary key
#  user_id            :integer
#  task               :text
#  note               :text
#  due_date           :date
#  completed_on       :date
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  task_recurrence_id :integer
#

class Task < ActiveRecord::Base
  attr_accessible :completed_on, :due_date, :note, :task, :user_id, :recurrence_rule, :set_to_repeat
  attr_accessor :recurrence_rule, :set_to_repeat

  belongs_to :user
  belongs_to :task_recurrence

  validates_presence_of :user, :task, :due_date

  scope :past_tasks, where('due_date < ?', Date.today)
  scope :completed, where('completed_on is not NULL').order('completed_on DESC')
  scope :upcoming, where('due_date >= ? AND completed_on is NULL', Date.today).order('due_date ASC')
  scope :overdue, where('due_date < ? AND completed_on is NULL', Date.today)


  self.per_page = 10

  def completed?
    completed_on.present?
  end

  after_create :create_recurrence, :if => Proc.new { |task| task.recurrence_rule.present? }
  after_destroy :destroy_recurrence, :if => Proc.new { |task| task.task_recurrence.present? }
  
  before_validation do |task|
    if task.recurrence_rule == "null" || task.set_to_repeat != "true"
      task.recurrence_rule = nil
    end
  end

  def create_recurrence
    new_recurrence = self.user.task_recurrences.build
    new_recurrence.tasks << self
    new_recurrence.save!
  end

  def show_recurrence_information?
    self.completed_on.blank? && self.task_recurrence.present?
  end

  def destroy_recurrence
    self.task_recurrence.self_destruct
  end
end
