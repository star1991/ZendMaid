class AppointmentFieldsController < ApplicationController
  # GET /appointment_fields
  # GET /appointment_fields.json
  def index
    @appointment_fields = AppointmentField.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @appointment_fields }
    end
  end

  # GET /appointment_fields/1
  # GET /appointment_fields/1.json
  def show
    @appointment_field = AppointmentField.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @appointment_field }
    end
  end

  # GET /appointment_fields/new
  # GET /appointment_fields/new.json
  def new
    @appointment_field = AppointmentField.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @appointment_field }
    end
  end

  # GET /appointment_fields/1/edit
  def edit
    @appointment_field = AppointmentField.find(params[:id])
  end

  # POST /appointment_fields
  # POST /appointment_fields.json
  def create
    @appointment_field = AppointmentField.new(params[:appointment_field])

    respond_to do |format|
      if @appointment_field.save
        format.html { redirect_to @appointment_field, notice: 'Appointment field was successfully created.' }
        format.json { render json: @appointment_field, status: :created, location: @appointment_field }
      else
        format.html { render action: "new" }
        format.json { render json: @appointment_field.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /appointment_fields/1
  # PUT /appointment_fields/1.json
  def update
    @appointment_field = AppointmentField.find(params[:id])

    respond_to do |format|
      if @appointment_field.update_attributes(params[:appointment_field])
        format.html { redirect_to @appointment_field, notice: 'Appointment field was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @appointment_field.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /appointment_fields/1
  # DELETE /appointment_fields/1.json
  def destroy
    @appointment_field = AppointmentField.find(params[:id])
    @appointment_field.destroy

    respond_to do |format|
      format.html { redirect_to appointment_fields_path }
      format.json { head :no_content }
    end
  end
end
