class CustomFieldsController < ApplicationController

  before_filter :authenticate_user!

  def edit
    @custom_field = current_user.custom_fields.find(params[:id])
    respond_to do |format|
      format.js
    end
  end

  def update
    @custom_field = current_user.custom_fields.find(params[:id])

    respond_to do |format|
      if @custom_field.update_attributes(params[:custom_field])
      	format.js { render 'update' }
      else
      	format.js { render 'edit' }
      end
    end
  end

  def destroy
    @custom_field = current_user.custom_fields.find(params[:id])
    @custom_field.destroy

    respond_to do |format|
      format.js
    end
  end

  def new
    @custom_field = CustomField.new(:field_type => params[:field_type])
    @custom_field.order = current_user.custom_fields.maximum("order") + 1

    respond_to do |format|
      format.js
    end	
  end

  def create
    @custom_field = current_user.custom_fields.build(params[:custom_field])
    respond_to do |format|
      if @custom_field.save
        format.js { render 'create' }
      else
        format.js { render 'new' }
      end
    end
  end


end
