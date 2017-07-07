# /app/controllers/appointments_controller.rb
class AppointmentsController < ApplicationController
  include PhoneNumberHelper

  layout :resolve_layout

  before_filter :appointment_owner

  def new
    @user = current_user

    if params[:customer_id].present?
      @customer = @user.customers.find_by_id(params[:customer_id])
      @subscription = @customer.subscriptions.build
      @appointment = @subscription.appointments.build(:start_time => params[:start_time], :end_time => params[:end_time])

      @instant_booking = InstantBooking.find_by_id(params[:instant_booking_id])
      @appointment.initialize_from_booking(@instant_booking)

      @subscription.start_date = @appointment.start_time_date

      if @customer.service_addresses.size == 1
        @appointment.address = @customer.service_addresses.first.dup
      else
        @appointment.build_address
      end

      @appointment.build_all_missing_custom_associations(@user)
      current_user.appointment_fields.each do |appointment_field|
        @appointment.appointment_items.build(:custom_field_id => appointment_field.id, :value_name => appointment_field.default)
      end

      pass_team_ids
      pass_address_info

      respond_to do |format|
        format.html { render 'new' }
        format.json { head :no_content }
        format.js { render 'appointments/js/new'}
      end
    else
      redirect_to new_customer_path(:to_appointment => true)
    end
  end

  def create
    @user = current_user

    @customer = @user.customers.find_by_id(params[:customer_id])

    #TODO: See if this causes race condition
    @subscription = @customer.subscriptions.build(params[:subscription])
    @appointment = @subscription.appointments.last

    @instant_booking = InstantBooking.find_by_id(params[:instant_booking_id])


    respond_to do |format|
      if @customer.save

        if @instant_booking.present?
          @instant_booking.update_attributes(:appointment_id => @appointment.id, :pending => false)
        end

        flash[:notice] = "Appointment was successfully created!"

        format.html { redirect_to edit_appointment_path(@appointment, :prompt_confirmation => true) }
        format.json { render json: @appointment, status: :created, location: @appointment }

        format.js do

          @appointment.build_all_missing_assignments(@user)
          params[:refresh] = true
          
          prep_email_template_data
          prep_text_template_data

          if @subscription.make_record_customer == "1"
            @customer.update_column(:lead, false)
          end

          if @customer.automatable_emails.size > 0
            @confirmation_email = @untimed_email_templates["Appointment Confirmation"].first
          end

          render 'appointments/js/preview_panel', :format => :js
        end

      else

        check_for_conflicts
        pass_team_ids
        pass_address_info

        @appointment.build_all_missing_custom_associations(@user)

        flash.now[:error] = "Oops! Please correct the errors below"
        format.html { render action: "new" }
        format.json { render json: @appointment.errors, status: :unprocessable_entity }
        format.js {render 'appointments/js/new', :format => :js}
      end
    end
  end

  def update_assignments
    @appointment = Appointment.find_by_id(params[:id])
    @appointment.assign_attributes(params[:appointment])

    respond_to do |format|
      if not @appointment.save
        check_for_conflicts
        format.js { render 'appointments/js/display_assignments_conflicts_modal' }
      else

        if params[:appointment][:assign_to] == "future"
          appointments_to_update = @appointment.subscription.appointments.where(["appointments.start_time > ? OR appointments.use_as_prototype = ?", @appointment.start_time, true])

          appointments_to_update.each do |appt|
            appt.assignments.destroy_all
            appt.allow_conflicts = true

            @appointment.assignments.each do |assignt|
              new_assignt = assignt.dup
              new_assignt.appointment_id = appt.id
              appt.assignments << new_assignt
            end
            appt.team_id = @appointment.team_id
            appt.save
          end
        end

        @customer = @appointment.subscription.subscriptionable
        @user = current_user

        @appointment.build_all_missing_assignments(@user)
        
        prep_email_template_data
        prep_text_template_data
        
        format.js { render 'appointments/js/update_assignments' }

      end
    end
  end

  def destroy
    @appointment = Appointment.find(params[:id])

    # Make sure that subscription is consistent
    @appointment.update_constraints = true
    @appointment.destroy

    respond_to do |format|
      format.html { redirect_to appointments_path, :notice => "Appointment was successfully deleted!" }
      format.json { head :no_content }
    end
  end

  def show
    @appointment = Appointment.find_by_id(params[:id])
    @user = @appointment.user
  end

  # calendar view
  def index
      @user = current_user
      
      if params[:customer_id].present?
        gon.customer_id = params[:customer_id]
        gon.start_time = params[:start_time]
        gon.end_time = params[:end_time]
        gon.instant_booking_id = params[:instant_booking_id]
      end

      pass_team_ids
  end

  # retrieve the appts for fullcalendar
  # GET /get_appts
  def get_appts
    @user = current_user
    @appointments = @user.appointments.actual.includes(:status, :address, :assignments, {:subscription => :subscriptionable}, :employees, :team)
    # filter by the datetime object via params from fullcalendar
    filter_show = ActiveSupport::JSON.decode(params[:filter_show])
    appointments_in_range = @appointments.where("appointments.start_time >= :start_time AND appointments.start_time <= :end_time", {:start_time => Time.at(params['start'].to_i), :end_time => Time.at(params['end'].to_i)} )
    events = []
    appointments_in_range.each do |appointment|
      if appointment_is_allowed?(appointment, filter_show)
        customer = appointment.subscription.subscriptionable
        eventHash = {:id => appointment.id, :title => calendar_title(appointment, customer), :start => "#{appointment.start_time.iso8601}", :end => "#{appointment.end_time.iso8601}", :allDay => false, :recurring => appointment.subscription.repeat }

        eventHash[:backgroundColor] = event_background_color(appointment, params[:event_color])
        eventHash[:borderColor] = eventHash[:backgroundColor]

        events << eventHash
        # optional day view
        #events << {:id => event.id, :title => @customer_name, :url => "/appointments/"+event.id.to_s+"/edit", :description => "Description here", :start => "#{event.start_time.iso8601}", :end => "#{event.end_time.iso8601}", :allDay => true}
      end
    end
    render :json => events
  end


  # retrieve appointments for calendar grid view
  def get_appts_grid
    @user = current_user
    @appointments = @user.appointments.actual.includes(:status, :address, :assignments, {:subscription => :subscriptionable}, :employees, :team)
    filter_show = ActiveSupport::JSON.decode(params[:filter_show])

    appointments_in_range = @appointments.where("appointments.start_time >= :start_time AND appointments.start_time <= :end_time", {:start_time => Time.at(params['start'].to_i), :end_time => Time.at(params['end'].to_i)} )

    # Initialize events by employee hash
    events = {}

    if params['source'] == 'employees'
      current_user.employees.active.each do |employee|
        if filter_show["employees"][employee.full_name]
          events[employee.id] = []
        end
      end
    elsif params['source'] == 'team'
      current_user.teams.each do |team|
        if filter_show["team"][team.name]
          events[team.id] = []
        end
      end
    end

    events[0] = []

    appointments_in_range.each do |appointment|
      if filter_show["status"][appointment.status.name]
        customer = appointment.subscription.subscriptionable
        eventHash = {:id => appointment.id, :title => calendar_title(appointment, customer), :start => "#{appointment.start_time.iso8601}", :end => "#{appointment.end_time.iso8601}", :allDay => false, :recurring => appointment.subscription.repeat }

        if params['source'] == 'employees'

          if appointment.assignments.size == 0
            eventHash[:backgroundColor] = @user.unassigned_color
            eventHash[:borderColor] = eventHash[:backgroundColor]
            events[0] << eventHash
          else
            appointment.employees.each do |employee|
              if events.has_key?(employee.id)
                eventCopy = eventHash.clone
                eventCopy[:backgroundColor] = employee.calendar_color
                eventCopy[:borderColor] = eventHash[:backgroundColor]
                events[employee.id] << eventCopy
              end
            end
          end

        elsif params['source'] == 'team'

          if appointment.team.blank?
            eventHash[:backgroundColor] = @user.no_team_color
            events[0] << eventHash
          else
            if events.has_key?(appointment.team.id)
              eventHash[:backgroundColor] = appointment.team.calendar_color
              events[appointment.team.id] << eventHash
            end
          end

        end
      end
    end

    render :text => events.to_json
  end


  def edit
    if params[:prompt_confirmation].present?
      gon.appointment_id = params[:id]
    end


    @appointment = Appointment.find_by_id(params[:id])
    @subscription = @appointment.subscription
    @customer = @appointment.customer

    @user = current_user

    @appointment.build_all_missing_custom_associations(@user)

    pass_team_ids
  end

  def edit_prototype
    @appointment = Appointment.find_by_id(params[:id])
    @subscription = @appointment.subscription
    @customer = @appointment.customer
    
    @user = current_user
    
    @appointment.build_all_missing_custom_associations(@user)

    pass_team_ids    
  end

  def update_prototype
    @subscription = Appointment.find_by_id(params[:id]).subscription
    @subscription.assign_attributes(params[:subscription])
    @appointment = @subscription.appointments.select {|appointment| appointment.id == params[:id].to_i}[0]
    
    @user = current_user
    @customer = @appointment.customer
    
    if @appointment.valid?
    
      pivot_appointment = Appointment.find_by_id(params["appointment-id"])
      @new_subscription = @subscription.dup
   
      @subscription.reload
      @subscription.disable(pivot_appointment.start_time - 1.day)
      @subscription.save! 
        
      # Note: subscription will create prototype appointment from this seed in its before_create callback
      seed_appointment = @appointment.dup_with_repeatable_associations
      seed_appointment.start_time = pivot_appointment.start_time
      seed_appointment.end_time = pivot_appointment.end_time
    
      @new_subscription.appointments << seed_appointment
      @new_subscription.save
      
      redirect_to edit_subscription_path(@new_subscription), :notice => "Default appointment information has been successfully changed! A new recurring service has been created to manage this new appointment data and the old service has been disabled."
    else
      pass_team_ids
      @appointment.build_all_missing_custom_associations(@user)
      flash.now[:error] = "Please review the errors below"

      render 'edit_prototype'
    end
    
  end  

  def update
    #Actually submit form for subscription and update appointment as nested association
    @subscription = Appointment.find_by_id(params[:id]).subscription

    @subscription.assign_attributes(params[:subscription])

    @appointment = @subscription.appointments.select {|appointment| appointment.id == params[:id].to_i}[0]

    @user = current_user
    @customer = @appointment.customer


    respond_to do |format|
      if @appointment.save

        format.html { redirect_to edit_appointment_path(@appointment), notice: 'Appointment information was successfully updated.' }
        format.json { head :no_content }
      else
        check_for_conflicts
        pass_team_ids

        @appointment.build_all_missing_custom_associations(@user)

        flash.now[:error] = "Please review the errors below"
        format.html { render action: "edit" }
        format.json { render json: @subscription.errors, status: :unprocessable_entity }
      end
    end
  end


  def update_from_calendar
    @appointment = Appointment.find_by_id(params[:id])

    subscription_applied = false
    if params[:apply_to_subscription] == true || params[:apply_to_subscription] == "true"
      @appointment.subscription.apply_to_subscription = true
      subscription_applied = true
    end

    respond_to do |format|
      if @appointment.update_attributes(params[:appointment])

        if subscription_applied
          # Grab first non-prototype appointment to open preview panel for
          @appointment = @appointment.subscription.appointments.actual.ascending.first
        end

        @customer = @appointment.subscription.subscriptionable
        @user = current_user

        @appointment.build_all_missing_assignments(@user)
        
        prep_email_template_data
        prep_text_template_data

        flash.now[:notice] = "Appointment information was successfully updated!"
        format.html { redirect_to user_root_path }
        format.js { render 'appointments/js/update_from_calendar_success' }
      else
        check_for_conflicts
        flash.now[:error] = "Oops! Something went wrong when saving your changes. Please try again!"
        
        format.html { render action: "edit" }
        format.js { render 'appointments/js/update_from_calendar_error' }
      end
    end
  end

  # /edit_location_and_contact_info/:customer_id
  # This is an example of how not to do RESTful resources
  def edit_location_and_contact_info
    @customer = Customer.find_by_id(params[:customer_id])

    subscription_id = params[:customer][:subscriptions_attributes]["0"][:id].to_i
    @subscription = @customer.subscriptions.select {|s| s.id == subscription_id}[0]

    appointment_id = params[:customer][:subscriptions_attributes]["0"][:appointments_attributes]["0"][:id].to_i
    @appointment = @subscription.appointments.select {|a| a.id == appointment_id }[0]

    respond_to do |format|
      if @customer.update_attributes(params[:customer])
        format.js { render 'appointments/js/location_and_contact_info_success'}
      else
        format.js { render 'appointments/js/location_and_contact_info_error'}
      end
    end
  end

  def edit_time_in_time_out
    @appointment = Appointment.includes({:assignments => :employee}).find(params[:id])
    
    respond_to do |format|
      format.js { render 'appointments/js/display_time_in_time_out_modal' }
    end
  end

  def preview_panel
    @appointment = Appointment.includes(:status, {:subscription => {:subscriptionable => [:emails, :phone_numbers]}}, {:assignments => :employee}, :team, :address).find_by_id(params[:id])

    @customer = @appointment.subscription.subscriptionable

    if not params[:employee_calendar]
      @user = User.includes(:teams, :employees).find_by_id(@customer.user_id)

      prep_email_template_data
      prep_text_template_data

      @appointment.build_all_missing_assignments(@user)
    end

    respond_to do |format|
      format.js { render 'appointments/js/preview_panel'}
    end
  end

  # GET /appointments/grid
  def grid
    @user = current_user
    pass_team_ids
  end

  # GET /appointments/list
  def list
    @user = current_user
    pass_team_ids 
    
    if params[:query].present? && params[:date_range].nil?
      q = params[:query].downcase
      where_string = 'lower(customers.first_name) = ? OR lower(customers.last_name) = ? OR lower(customers.company_name) = ? OR lower(employees.first_name) = ? OR lower(employees.last_name) = ? OR lower(custom_items.value_name) = ? OR lower(addresses.line1) LIKE ? OR lower(service_types.name) = ?'

      @appointments = current_user.appointments.actual.includes(:status, :address, :employees, :customer, :team, :appointment_items, :service_type).where(where_string, q, q, q, q, q, q, "%#{q}%", q).ascending.paginate(:page => params[:page], :per_page => 50)

      # So error doesn't occur on page render      
      params[:date_range] = {}
    else

      if params[:date_range].nil?
        params[:date_range] = { :paid_status => "All Appointments" } 
      end

      @appointments = current_user.appointments.includes(:status, :address, :employees, :customer, :team).actual

      case params[:date_range][:paid_status]
      when "Unpaid Appointments"
        @appointments = @appointments.where(:paid => false)
      when "Paid Appointments"
        @appointments = @appointments.where(:paid => true)
      else
      end

      @from = params[:date_range][:from].present? ? Time.zone.parse(params[:date_range][:from]).beginning_of_day : Time.zone.now.beginning_of_day
      @to =  params[:date_range][:to].present? ? Time.zone.parse(params[:date_range][:to]).end_of_day : (Time.zone.now + 1.week).end_of_day
    
      @appointments = @appointments.actual.where(start_time: @from..@to).ascending.paginate(:page => params[:page], :per_page => 50)
    end
    
    if params[:use_for_invoice] == "true"
      @appointments = @appointments.where("statuses.use_for_invoice = ?", true)
    end

    @appointments_by_date = Hash.new([])
    @appointments.each do |appointment|
      @appointments_by_date[appointment.start_time.strftime('%-m/%-d/%Y')] += [appointment]
    end
  
  end

  def set_status
    current_user.appointments.where(id: params[:ids]).update_all(:status_id => params[:status_id])
    
    respond_to do |format|
      # Trying to make an ajax post request act like a http post request
      # Hacky, but other solution involves making a virtual form and this requires less code
      format.js { render inline: "window.location.reload();" }
    end
  end

  def set_paid
    current_user.appointments.where(id: params[:ids]).update_all(:paid=> params[:paid])
    
    respond_to do |format|
      # Trying to make an ajax post request act like a http post request
      # Hacky, but other solution involves making a virtual form and this requires less code
      format.js { render inline: "window.location.reload();" }
    end
  end

  def delete_all
    current_user.appointments.where(id: params[:ids]).destroy_all
    
    respond_to do |format|
      # Trying to make an ajax post request act like a http post request
      # Hacky, but other solution involves making a virtual form and this requires less code
      format.js { render inline: "window.location.reload();" }
    end    
  end

  # show page quality driven software export
  def quality_driven_software_export
    @from = Time.zone.now - 1.week
    @to = Time.zone.now
  end

  # processing quality driven software export
  def quality_driven_software_export_process
    Delayed::Job.enqueue ::QualityDrivenSoftwareExportJob.new(params[:date_range][:from], params[:date_range][:to], current_user)

    redirect_to quality_driven_software_export_path
    flash[:notice] ="Your quality driven software export has been enqueued successfully."
  end

  protected

  def appointment_owner
    case action_name
    when 'preview_panel'
      if (current_employee.blank? && current_user.blank?)
        redirect_to user_root_path, notice: "Please sign in"
      end
    else
      if current_user.blank? || (params[:id].present? && current_user != Appointment.find_by_id(params[:id]).try(:user))
        redirect_to user_root_path, notice: "Please sign in"
      elsif !current_user.active?
        flash[:error] = "Your account has been deactivated, please email us at support@zenmaid.com to resolve this issue."
        redirect_to user_root_path
      end
    end
  end


  def resolve_layout
    case action_name
    when 'index', 'grid', 'list'
      'application-calendar'
    when 'edit', 'update', 'new', 'create', 'edit_prototype', 'update_prototype', 'quality_driven_software_export'
      'application-admin'
    when 'show'
      check_embedded
    end
  end

  # XXX Copy/paste from intant booking controller
  def pass_gon_parameters
    gon.appointment_fields_map = Hash[@user.appointment_fields.map { |field| [field.id, field.value_names.invert]}]
    gon.pricing_tables = @user.pricing_tables.map {|table| {:appointment_field_ids => table.appointment_field_ids.sort!, :pricing_table => table.pricing_table}}
    gon.service_type_map = Hash[@user.service_types.map {|service_type| [service_type.id, service_type.appointment_fields.map(&:id)]}]
    gon.service_type_base_prices = Hash[@user.service_types.map {|service_type| [service_type.id, service_type.base_price]}]
  end

  def pass_team_ids
    gon.teams = Hash[@user.teams.map { |team| [team.id, team.teams_employees.map(&:employee_id)] }]
    gon.employee_map = Hash[@user.employees.map { |employee| [employee.id, employee.full_name] }]
  end


  def pass_address_info
    gon.service_addresses = Hash[@customer.addresses.map { |address| [address.id, {:street => address.line1, :city => address.city, :state => address.state, :zip => address.postal_code}] }]
  end

  def appointment_is_allowed?(appointment, filter_show)
    status_show = filter_show["status"][appointment.status.name]
    team_show = appointment.team.present? ? filter_show["team"][appointment.team.name] : filter_show["team"]["No Team Assigned"]

    if appointment.assignments.size == 0
      employee_show = filter_show["employees"]["No Cleaners Assigned"]
    else
      employee_show = false
      appointment.employees.each do |employee|
        # show if employee is set to be shown on calendar or employee is inactive (people want to see these in calendar)
        if filter_show["employees"][employee.full_name] || !employee.active?
          employee_show = true
          break
        end
      end
    end

    return (status_show && employee_show && team_show)
  end

  def event_background_color(appointment, event_color)
    case event_color
    when "Employees"
      if appointment.assignments.size == 0
        @user.unassigned_color
      else
        appointment.employees.first.calendar_color
      end
    when "Status"
      if appointment.status.blank?
        @user.no_status_color
      else
        appointment.status.calendar_color
      end
    when "Team"
       if appointment.team.blank?
         @user.no_team_color
       else
         appointment.team.calendar_color
       end
    end
  end

  def check_for_conflicts
    if @appointment.errors[:base].try(:first) == "Conflicts Present"
      @conflicts = @appointment.get_conflicts
    end
  end

  def prep_email_template_data
      email_templates = @user.email_templates.where(:template_resource => "Appointment").group_by(&:template_type)
      @appointment_reminder_email = email_templates["Appointment Reminder"].first
      @appointment_follow_up_email = email_templates["Appointment Follow-Up"].first
      @work_order_email = email_templates["Work Order"].first

      @untimed_email_templates = email_templates.except!('Appointment Reminder', 'Appointment Follow-Up', 'Work Order')
  end
  
  def prep_text_template_data
      text_templates = @user.text_templates.group_by(&:template_type)
      @appointment_reminder_text = text_templates["Appointment Reminder"].first
      @work_order_text = text_templates["Work Order"].first
      
      @untimed_text_templates = text_templates.except!('Appointment Reminder', 'Work Order')
  end

  private

  def calendar_title(appointment, customer)
    address = appointment.address
    "#{customer.full_name}\n#{address.line1}\n#{address.city}, #{address.state} #{address.postal_code}"
  end
end
