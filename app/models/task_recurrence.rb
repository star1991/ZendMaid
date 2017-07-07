# == Schema Information
#
# Table name: task_recurrences
#
#  id         :integer          not null, primary key
#  schedule   :text
#  user_id    :integer
#  task       :text
#  note       :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class TaskRecurrence < ActiveRecord::Base
  attr_accessible :parent_id, :populated_until, :schedule, :user_id
  attr_accessor :recurrence

  serialize :schedule, Hash

  has_many :tasks, :dependent => :nullify

  def recurrence
    @recurrence ||= IceCube::Schedule.from_hash(self.schedule)
  end

  before_create :initialize_from_prototype
  after_create :populate_tasks

  # this method initializes the task_recurrence from the prototype task
  # the prototype task will create a task recurrence when necessary during a create or update operation on the task
  def initialize_from_prototype
    prototype_task = self.tasks.first

    self.note = prototype_task.note
    self.task = prototype_task.task

    self.recurrence = IceCube::Schedule.new(start = prototype_task.due_date)

    self.recurrence.add_recurrence_rule RecurringSelect.dirty_hash_to_rule(prototype_task.recurrence_rule)

    # Possibly unnecessary, since this is set in the populate tasks
    self.schedule = self.recurrence.to_hash
  end

  # this method populates tasks from the start date to the populated until time (default - 6 months)
  def populate_tasks(time_forward = 3.months)
    
    inserts = []
    places = []
    timestamp = Time.now.strftime('%Y-%m-%d %H:%M:%S')

    # Make sure not to populate the same event twice at boundaries
    due_dates = self.recurrence.occurrences(Date.today + time_forward)
    if due_dates.size > 0 && due_dates[0].to_date == self.recurrence.start_time.to_date
      due_dates.delete_at(0)
    end

    due_dates.each do |due_date|
      places.push "(?,?,?,?,?,?,?)"
      inserts.push(*[self.id, self.user_id, self.task, self.note, due_date.strftime('%Y-%m-%d'), timestamp, timestamp])
    end   

    if places.length > 0
      sql_arr = ["INSERT INTO tasks (task_recurrence_id, user_id, task, note, due_date, created_at, updated_at) VALUES #{places.join(", ")}"] + inserts
      sql = ActiveRecord::Base.send(:sanitize_sql_array, sql_arr)
      ActiveRecord::Base.connection.execute(sql)
    end 

    if due_dates.size > 0
      self.recurrence.start_time = due_dates[-1]
      self.schedule = self.recurrence.to_hash
      self.save
    end
  end

  # This method deletes all incomplete tasks for this recurrence and then destroys the task_recurrence object
  # (note that this also nullifies the task_recurrence_id foreign key column on all completed task association records)
  def self_destruct
    self.tasks.where("completed_on is NULL").delete_all
    self.destroy
  end 
end
