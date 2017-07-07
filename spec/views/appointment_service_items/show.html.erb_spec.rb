require 'spec_helper'

describe "appointment_service_items/show" do
  before(:each) do
    @appointment_service_item = assign(:appointment_service_item, stub_model(AppointmentServiceItem,
      :appointment_id => 1,
      :appointment_field_id => 2,
      :amount => 3
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    rendered.should match(/2/)
    rendered.should match(/3/)
  end
end
