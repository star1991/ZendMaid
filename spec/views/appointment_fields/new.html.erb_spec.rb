require 'spec_helper'

describe "appointment_fields/new" do
  before(:each) do
    assign(:appointment_field, stub_model(AppointmentField,
      :user_id => 1,
      :field_name => "MyString",
      :input_type => "MyString",
      :price => "9.99",
      :max_field_value => 1,
      :min_field_value => 1
    ).as_new_record)
  end

  it "renders new appointment_field form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => appointment_fields_path, :method => "post" do
      assert_select "input#appointment_field_user_id", :name => "appointment_field[user_id]"
      assert_select "input#appointment_field_field_name", :name => "appointment_field[field_name]"
      assert_select "input#appointment_field_input_type", :name => "appointment_field[input_type]"
      assert_select "input#appointment_field_price", :name => "appointment_field[price]"
      assert_select "input#appointment_field_max_field_value", :name => "appointment_field[max_field_value]"
      assert_select "input#appointment_field_min_field_value", :name => "appointment_field[min_field_value]"
    end
  end
end
