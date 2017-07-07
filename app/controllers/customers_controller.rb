class CustomersController < ApplicationController
  
  before_filter :customer_owner
  
  layout 'application-admin'
  
  
  # GET /customers
  # GET /customers.json
  def index
    customers = Customer.filtered_customers(current_user, params)
    @num_customers = customers.count
    @customers = customers.paginate(:per_page => 50, :page => params[:page])    

    respond_to do |format|
      if current_user.qb_last_sync.present? and !current_user.qb_syncing? and Time.zone.now - current_user.qb_last_sync < 1.day
        flash[:notice] = "Your customers have been successfully synced from QuickBooks!"
      end
      format.html # index.html.erb
      format.json { render json: @customers }
    end
  end

  # GET /customers/:id/recent_activity
  def recent_activity
    @customer = Customer.find_by_id(params[:id])
    
    respond_to do |format|
      format.js { render 'customers/log_entries'}
    end
  end

  # GET /customers/1
  # GET /customers/1.json
  def show
    @customer = Customer.find(params[:id])
    
    @attached_notes = @customer.attached_notes.paginate(:per_page => 5, :page => params[:page])
    
    @new_attached_note = AttachedNote.new
    @new_attached_note.noteable_type = "Customer"
    @new_attached_note.noteable_id = @customer.id

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @customer }
    end
  end

  # GET /customers/new
  # GET /customers/new.json
  def new
    @customer = Customer.new

    
    @instant_booking = InstantBooking.find_by_id(params[:instant_booking_id])
    if @instant_booking.present?
      @customer.initialize_from_booking(@instant_booking)
      @service_addresses = @customer.addresses.select { |address| address.billing == false }
      @billing_address = @customer.addresses.select { |address| address.billing == true } 
    else
      @service_addresses = @customer.addresses.build
      @billing_address = @customer.addresses.build(:billing => true)
    end
    
    current_user.customer_fields.each do |customer_field|
      @customer.customer_items.build(:custom_field_id => customer_field.id, :value_name => customer_field.default)
    end

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @customer }
    end
  end

  # GET /customers/1/edit
  def edit
    @customer = Customer.find(params[:id])
    if @customer.service_addresses.size == 0
      @customer.service_addresses.build
    end
    
    @service_addresses = @customer.service_addresses
    @billing_address = @customer.billing_address || @customer.addresses.build(:billing => true)
  end

  # POST /customers
  # POST /customers.json
  def create
    @customer = Customer.new(params[:customer])
    @customer.user = current_user
    
    if @customer.marketing_source == "Add New"
      CustomField.add_marketing_source(params[:customer][:new_marketing_source], current_user)
      @customer.marketing_source = params[:customer][:new_marketing_source]
    end

    logger.debug params[:create]
    respond_to do |format|
      if @customer.save
        
        format.html do
          if params[:commit] == 'create-appointment'
            redirect_to appointments_path(:customer_id => @customer.id, :start_time => params[:start_time], :end_time => params[:end_time], :instant_booking_id => params[:instant_booking_id]), notice: 'Customer was successfully created.'  
          else
            redirect_to @customer, notice: 'Customer was successfully created.'
          end
        end
        
        format.json { render json: @customer, status: :created, location: @customer }
      else
        @service_addresses = @customer.addresses.select { |address| address.billing == false }
        @billing_address = @customer.addresses.select { |address| address.billing == true } 
        @billing_address = @billing_address.size > 0 ? @billing_address : @customer.addresses.build(:billing => true)
        
        @instant_booking = InstantBooking.find_by_id(params[:instant_booking_id])
        
        if @customer.errors[:base].present?
          @possible_duplicates = @customer.user.customers.where(:id => @customer.errors[:base].first)
        end

        flash.now[:error] = "Please review the errors below"
        format.html { render action: "new" }
        format.json { render json: @customer.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /customers/1
  # PUT /customers/1.json
  def update
    @customer = Customer.find(params[:id])

    if params[:customer][:marketing_source] == "Add New"
      CustomField.add_marketing_source(params[:customer][:new_marketing_source], current_user)
      params[:customer][:marketing_source] = params[:customer][:new_marketing_source]
    end

    respond_to do |format|
      if @customer.update_attributes(params[:customer])
        format.html { redirect_to @customer, notice: 'Customer information was successfully updated.' }
        format.json { head :no_content }
      else
        #Avoid hitting the database so that validation errors display properly
        @billing_address = @customer.addresses.select { |address| address.billing == true } 
        @billing_address = @billing_address.size > 0 ? @billing_address : @customer.addresses.build(:billing => true)
        
        @service_addresses = @customer.addresses.select { |address| address.billing == false }
        
        flash.now[:error] = "Please review the errors below"
        format.html { render action: "edit" }
        format.json { render json: @customer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /customers/1
  # DELETE /customers/1.json
  def destroy
    @customer = Customer.find(params[:id])
    @customer.destroy

    respond_to do |format|
      format.html { redirect_to customers_path, :notice => "Contact has been successfully deleted!" }
      format.json { head :no_content }
    end
  end

  #deletes all customers which were imported in the last day
  def undo_recent_imported_customers
    # all imported customer last day 
    @customer = Customer.imported.created_between(DateTime.now - 1.week, DateTime.now)

    if @customer.present?
      @customer.destroy_all       
      redirect_to customers_path, :notice => "Recent imported customers have been successfully deleted!" 
    else
      redirect_to import_customers_page_path,:notice=>"No recently imported customers exist"
    end
  end

  # GET customers/:id/manage_credit_cards.js
  def manage_credit_cards
    @customer = current_user.customers.find(params[:id])

    if params[:appointment_id].present?
      @appointment = current_user.appointments.find(params[:appointment_id])
    end

    @credit_card = CreditCard.new(:charge => @appointment.try(:price))
  end

  # GET customer_names_and_ids
  def customer_names_and_ids
       
    names_and_ids = [{:name => "New customer", :id => nil}]
    
    current_user.active_customers.order("customers.first_name ASC").each do |customer|
      names_and_ids << {:name => customer.full_name, :id => customer.id}
    end
    
    
    respond_to do |format|
      format.json { render :text => names_and_ids.to_json}
    end
  end
  
  # POST customers/import
  def import
    irf = ImportRequestFile.new(file: params[:file])
    if irf.save
       Delayed::Job.enqueue ::CustomersImportJob.new(irf.id, current_user.id, {:active => true, :allow_duplicate => true})
      redirect_to customers_path, :notice => "Your import request has been enequed successfully"
    else
          
      redirect_to import_customers_page_path
      flash[:error] ="Please select a valid csv file"
    end
    
  end
  
  def mailchimp_lists
    @success , @mailchimp_lists = MailchimpSubscriber.lists(current_user.id)

    respond_to do |format|
      format.js { render 'customers/mailchimp_lists'}
    end
  end

    
  def import_attached_notes
    num_saved, num_error = Customer.import_attached_notes(params[:file], current_user.id)
    redirect_to customers_path, :notice => "#{num_saved} notes were successfully saved. #{num_error} notes were unable to be saved."
  end
  
  def import_appointments
    num_saved, num_error = Customer.import_appointments(params[:file], current_user.id)
    redirect_to customers_path, :notice => "#{num_saved} appointments were successfully saved. #{num_error} appointments were unable to be saved."    
  end
  
  def inactivate
    @customer = current_user.customers.find(params[:id])
    
    @customer.subscriptions.where(:active => true).each do |subscription|
      subscription.disable(Time.zone.now.beginning_of_day)
      subscription.save
    end
    
    @customer.active = false
    if @customer.save
      redirect_to @customer, :notice => "Customer was successfully inactivated"
    end
  end
  
  def reactivate
    @customer = current_user.customers.find(params[:id])
    
    @customer.active = true
    if @customer.save
      redirect_to @customer, :notice => "Customer was successfully reactivated"
    end
  end


  def quickbooks_sync
    if current_user.qb_company_id.present? && !current_user.qb_syncing?

       current_user.qb_syncing = true
       current_user.save

       Delayed::Job.enqueue QuickbooksSyncJob.new(current_user, current_employee, params[:quickbook_sync])
     
       flash[:notice] = "Your contacts are syncing now! We'll email you when they're done."
       true
     else
       flash[:error] = "Your contacts are already syncing and will be  finished shortly! We'll email you as soon as they're done."
       false
     end
    
    redirect_to customers_path
  end

  
  def sync_contacts
    unless current_user.mailchimp_syncing?
      if params['sync']['list_name'] == 'new_list'
        if params['sync']['new_list'].present?
          success, response= MailchimpSubscriber.create_new_list(current_user, params['sync']['new_list'])
          # sync contacts if new list created successfully
          if success
            build_and_sync_contacts(params['sync']['sync_for'], response['name'])
          else
            flash[:error] = "There was a problem occurred connecting to mailchimp, please try again in a minute."      
          end
        else
          flash[:error] = "Please input a valid name for your new list."
        end
      else
        build_and_sync_contacts(params['sync']['sync_for'], params['sync']['list_name'])
      end
    else
      flash[:error] = "Your contacts are already syncing"
    end
    redirect_to customers_path
  end

  protected
  
  def customer_owner
    if current_user.blank? || (params[:id].present? && current_user != Customer.find_by_id(params[:id]).user)
      redirect_to user_root_path, notice: "Please sign into the account which owns this customer record to edit it"
    elsif !current_user.active?
      flash[:error] = "Your account has been deactivated, please email us at support@zenmaid.com to resolve this issue."
      redirect_to user_root_path
    end
  end
  

  private 

  def build_and_sync_contacts(sync_for, name)
 
    current_user.mailchimp_syncing = true
    current_user.save

    # eneque the subscribe a list of emails
    success = Delayed::Job.enqueue ::MailchimpSubscriberJob.new(current_user, name, sync_for.downcase, current_employee)

    if success
      flash[:notice] = "Your contacts are syncing now! We'll email you when they're done."
    else
      flash[:error] = "Oops! There was a problem connecting with MailChimp. Please try again in a minute."
    end
  end
end
