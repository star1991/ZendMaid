class TasksController < ApplicationController
  layout 'application-admin'
  before_filter :authenticate_user!

  def index
    if  params[:task_filter] == 'completed'
      @tasks = current_user.tasks.completed
    elsif params[:task_filter] == 'overdue'
      @tasks = current_user.tasks.order('due_date DESC').overdue
    elsif params[:task_filter] == 'upcoming'
      @tasks = current_user.tasks.upcoming                          
    else
      @tasks = current_user.tasks.order('due_date DESC')
    end

    @tasks = @tasks.paginate(:page => params[:page], :per_page => params[:per_page])
  end

  def new
    @task = current_user.tasks.build(:due_date => params[:date])
  end
  
  def create
    @task = current_user.tasks.build(params[:task])
    respond_to do |format|
      if @task.save
        format.js { render 'tasks/create' }
      else
        format.js { render 'tasks/new' }
      end
    end
  end
  
  def update
    @task = current_user.tasks.find_by_id(params[:id])
    task_params = params[:task] || {}
    params[:completed] == '1' ? task_params.merge!({ completed_on: Date.today }) : task_params.merge!({ completed_on: nil }) 
    respond_to do |format|
      if @task.update_attributes(task_params)
        format.js { render 'tasks/show' }
      else
        format.js { render 'tasks/edit' }
      end
    end
  end
  
  def show
    @task = current_user.tasks.find(params[:id])
    respond_to do |format|
      format.js { render 'tasks/show' }
    end
  end
  
  def edit
    @task = current_user.tasks.find(params[:id])
    respond_to do |format|
      format.js { render 'tasks/edit' }
    end
  end
  
  def destroy
    @task = current_user.tasks.find(params[:id])
    @task.destroy
    
    respond_to do |format|
      format.js { render 'tasks/delete'}
    end
  end


  def get_tasks
    events = []
    current_user.tasks.each do |task|
      taskHash = {:id => task.id, :title => task.task, :completed => task.completed?, :recurring => task.task_recurrence_id.present?, 
                  :start => "#{task.due_date.iso8601}", :allDay => true, :task => true } 
      if task.completed? 
        taskHash[:backgroundColor] = '#ced7e0'
        taskHash[:editable] = false
        taskHash[:textColor] = '#212f40'
      else
        taskHash[:backgroundColor] = '#FFC2C2'
        taskHash[:editable] = true
        taskHash[:textColor] = '#212f40'
      end

      events << taskHash
    end
    render :json => events
  end

  
  def preview_panel
    @task = current_user.tasks.find(params[:id])

    respond_to do |format|
      format.js { render 'tasks/preview_panel' }
    end
  end

  def create_task_panel
    @task = Task.new(due_date: Date.parse(params[:day]))
    respond_to do |format|
      format.js { render 'tasks/create_task_panel' }
    end
  end

  def update_task_from_calendar
    @task = current_user.tasks.find(params[:id])
    respond_to do |format|
      if @task.update_attributes( due_date: (@task.due_date + params[:delta_day].to_i) )
        format.json { render :json => { :success => true } }
      else
        format.json { render :json => { :success => true } }
      end
    end
  end
end
