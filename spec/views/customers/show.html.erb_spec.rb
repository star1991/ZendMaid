require 'spec_helper'

describe "customers/show" do
  before(:each) do
    @customer = assign(:customer, stub_model(Customer,
      :firstname => "Firstname",
      :lastname => "Lastname",
      :email => "Email",
      :phone => "Phone"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Firstname/)
    rendered.should match(/Lastname/)
    rendered.should match(/Email/)
    rendered.should match(/Phone/)
  end
end
