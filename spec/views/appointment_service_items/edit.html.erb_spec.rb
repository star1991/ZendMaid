require 'spec_helper'

describe "appointment_service_items/edit" do
  before(:each) do
    @appointment_service_item = assign(:appointment_service_item, stub_model(AppointmentServiceItem,
      :appointment_id => 1,
      :appointment_field_id => 1,
      :amount => 1
    ))
  end

  it "renders the edit appointment_service_item form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => appointment_service_items_path(@appointment_service_item), :method => "post" do
      assert_select "input#appointment_service_item_appointment_id", :name => "appointment_service_item[appointment_id]"
      assert_select "input#appointment_service_item_appointment_field_id", :name => "appointment_service_item[appointment_field_id]"
      assert_select "input#appointment_service_item_amount", :name => "appointment_service_item[amount]"
    end
  end
end
