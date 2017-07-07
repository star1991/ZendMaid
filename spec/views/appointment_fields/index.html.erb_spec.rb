require 'spec_helper'

describe "appointment_fields/index" do
  before(:each) do
    assign(:appointment_fields, [
      stub_model(AppointmentField,
        :user_id => 1,
        :field_name => "Field Name",
        :input_type => "Input Type",
        :price => "9.99",
        :max_field_value => 2,
        :min_field_value => 3
      ),
      stub_model(AppointmentField,
        :user_id => 1,
        :field_name => "Field Name",
        :input_type => "Input Type",
        :price => "9.99",
        :max_field_value => 2,
        :min_field_value => 3
      )
    ])
  end

  it "renders a list of appointment_fields" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => "Field Name".to_s, :count => 2
    assert_select "tr>td", :text => "Input Type".to_s, :count => 2
    assert_select "tr>td", :text => "9.99".to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
  end
end
