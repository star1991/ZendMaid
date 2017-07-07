require 'spec_helper'

describe "appointment_service_items/index" do
  before(:each) do
    assign(:appointment_service_items, [
      stub_model(AppointmentServiceItem,
        :appointment_id => 1,
        :appointment_field_id => 2,
        :amount => 3
      ),
      stub_model(AppointmentServiceItem,
        :appointment_id => 1,
        :appointment_field_id => 2,
        :amount => 3
      )
    ])
  end

  it "renders a list of appointment_service_items" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
  end
end
