require "spec_helper"

describe AppointmentServiceItemsController do
  describe "routing" do

    it "routes to #index" do
      get("/appointment_service_items").should route_to("appointment_service_items#index")
    end

    it "routes to #new" do
      get("/appointment_service_items/new").should route_to("appointment_service_items#new")
    end

    it "routes to #show" do
      get("/appointment_service_items/1").should route_to("appointment_service_items#show", :id => "1")
    end

    it "routes to #edit" do
      get("/appointment_service_items/1/edit").should route_to("appointment_service_items#edit", :id => "1")
    end

    it "routes to #create" do
      post("/appointment_service_items").should route_to("appointment_service_items#create")
    end

    it "routes to #update" do
      put("/appointment_service_items/1").should route_to("appointment_service_items#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/appointment_service_items/1").should route_to("appointment_service_items#destroy", :id => "1")
    end

  end
end
