require "spec_helper"

describe AppointmentFieldsController do
  describe "routing" do

    it "routes to #index" do
      get("/appointment_fields").should route_to("appointment_fields#index")
    end

    it "routes to #new" do
      get("/appointment_fields/new").should route_to("appointment_fields#new")
    end

    it "routes to #show" do
      get("/appointment_fields/1").should route_to("appointment_fields#show", :id => "1")
    end

    it "routes to #edit" do
      get("/appointment_fields/1/edit").should route_to("appointment_fields#edit", :id => "1")
    end

    it "routes to #create" do
      post("/appointment_fields").should route_to("appointment_fields#create")
    end

    it "routes to #update" do
      put("/appointment_fields/1").should route_to("appointment_fields#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/appointment_fields/1").should route_to("appointment_fields#destroy", :id => "1")
    end

  end
end
