require 'spec_helper'

describe "appointment_fields/show" do
  before(:each) do
    @appointment_field = assign(:appointment_field, stub_model(AppointmentField,
      :user_id => 1,
      :field_name => "Field Name",
      :input_type => "Input Type",
      :price => "9.99",
      :max_field_value => 2,
      :min_field_value => 3
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    rendered.should match(/Field Name/)
    rendered.should match(/Input Type/)
    rendered.should match(/9.99/)
    rendered.should match(/2/)
    rendered.should match(/3/)
  end
end
