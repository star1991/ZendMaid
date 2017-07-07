require 'spec_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

describe AppointmentFieldsController do

  # This should return the minimal set of attributes required to create a valid
  # AppointmentField. As you add validations to AppointmentField, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {}
  end

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # AppointmentFieldsController. Be sure to keep this updated too.
  def valid_session
    {}
  end

  describe "GET index" do
    it "assigns all appointment_fields as @appointment_fields" do
      appointment_field = AppointmentField.create! valid_attributes
      get :index, {}, valid_session
      assigns(:appointment_fields).should eq([appointment_field])
    end
  end

  describe "GET show" do
    it "assigns the requested appointment_field as @appointment_field" do
      appointment_field = AppointmentField.create! valid_attributes
      get :show, {:id => appointment_field.to_param}, valid_session
      assigns(:appointment_field).should eq(appointment_field)
    end
  end

  describe "GET new" do
    it "assigns a new appointment_field as @appointment_field" do
      get :new, {}, valid_session
      assigns(:appointment_field).should be_a_new(AppointmentField)
    end
  end

  describe "GET edit" do
    it "assigns the requested appointment_field as @appointment_field" do
      appointment_field = AppointmentField.create! valid_attributes
      get :edit, {:id => appointment_field.to_param}, valid_session
      assigns(:appointment_field).should eq(appointment_field)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new AppointmentField" do
        expect {
          post :create, {:appointment_field => valid_attributes}, valid_session
        }.to change(AppointmentField, :count).by(1)
      end

      it "assigns a newly created appointment_field as @appointment_field" do
        post :create, {:appointment_field => valid_attributes}, valid_session
        assigns(:appointment_field).should be_a(AppointmentField)
        assigns(:appointment_field).should be_persisted
      end

      it "redirects to the created appointment_field" do
        post :create, {:appointment_field => valid_attributes}, valid_session
        response.should redirect_to(AppointmentField.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved appointment_field as @appointment_field" do
        # Trigger the behavior that occurs when invalid params are submitted
        AppointmentField.any_instance.stub(:save).and_return(false)
        post :create, {:appointment_field => {}}, valid_session
        assigns(:appointment_field).should be_a_new(AppointmentField)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        AppointmentField.any_instance.stub(:save).and_return(false)
        post :create, {:appointment_field => {}}, valid_session
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested appointment_field" do
        appointment_field = AppointmentField.create! valid_attributes
        # Assuming there are no other appointment_fields in the database, this
        # specifies that the AppointmentField created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        AppointmentField.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, {:id => appointment_field.to_param, :appointment_field => {'these' => 'params'}}, valid_session
      end

      it "assigns the requested appointment_field as @appointment_field" do
        appointment_field = AppointmentField.create! valid_attributes
        put :update, {:id => appointment_field.to_param, :appointment_field => valid_attributes}, valid_session
        assigns(:appointment_field).should eq(appointment_field)
      end

      it "redirects to the appointment_field" do
        appointment_field = AppointmentField.create! valid_attributes
        put :update, {:id => appointment_field.to_param, :appointment_field => valid_attributes}, valid_session
        response.should redirect_to(appointment_field)
      end
    end

    describe "with invalid params" do
      it "assigns the appointment_field as @appointment_field" do
        appointment_field = AppointmentField.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        AppointmentField.any_instance.stub(:save).and_return(false)
        put :update, {:id => appointment_field.to_param, :appointment_field => {}}, valid_session
        assigns(:appointment_field).should eq(appointment_field)
      end

      it "re-renders the 'edit' template" do
        appointment_field = AppointmentField.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        AppointmentField.any_instance.stub(:save).and_return(false)
        put :update, {:id => appointment_field.to_param, :appointment_field => {}}, valid_session
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested appointment_field" do
      appointment_field = AppointmentField.create! valid_attributes
      expect {
        delete :destroy, {:id => appointment_field.to_param}, valid_session
      }.to change(AppointmentField, :count).by(-1)
    end

    it "redirects to the appointment_fields list" do
      appointment_field = AppointmentField.create! valid_attributes
      delete :destroy, {:id => appointment_field.to_param}, valid_session
      response.should redirect_to(appointment_fields_url)
    end
  end

end
