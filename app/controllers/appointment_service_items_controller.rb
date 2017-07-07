class AppointmentServiceItemsController < ApplicationController
  # GET /appointment_service_items
  # GET /appointment_service_items.json
  def index
    @appointment_service_items = AppointmentServiceItem.all
	
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @appointment_service_items }
    end
  end

  # GET /appointment_service_items/1
  # GET /appointment_service_items/1.json
  def show
    @appointment_service_item = AppointmentServiceItem.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @appointment_service_item }
    end
  end

  # GET /appointment_service_items/new
  # GET /appointment_service_items/new.json
  def new
    @appointment_service_item = AppointmentServiceItem.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @appointment_service_item }
    end
  end

  # GET /appointment_service_items/1/edit
  def edit
    @appointment_service_item = AppointmentServiceItem.find(params[:id])
  end

  # POST /appointment_service_items
  # POST /appointment_service_items.json
  def create
    @appointment_service_item = AppointmentServiceItem.new(params[:appointment_service_item])

    respond_to do |format|
      if @appointment_service_item.save
        format.html { redirect_to @appointment_service_item, notice: 'Appointment service item was successfully created.' }
        format.json { render json: @appointment_service_item, status: :created, location: @appointment_service_item }
      else
        format.html { render action: "new" }
        format.json { render json: @appointment_service_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /appointment_service_items/1
  # PUT /appointment_service_items/1.json
  def update
    @appointment_service_item = AppointmentServiceItem.find(params[:id])

    respond_to do |format|
      if @appointment_service_item.update_attributes(params[:appointment_service_item])
        format.html { redirect_to @appointment_service_item, notice: 'Appointment service item was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @appointment_service_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /appointment_service_items/1
  # DELETE /appointment_service_items/1.json
  def destroy
    @appointment_service_item = AppointmentServiceItem.find(params[:id])
    @appointment_service_item.destroy

    respond_to do |format|
      format.html { redirect_to appointment_service_items_path }
      format.json { head :no_content }
    end
  end
end
