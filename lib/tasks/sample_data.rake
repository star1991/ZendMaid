namespace :db do
  
  desc "Erase and fill database"
  task :populate => :environment do
    include AppointmentsHelper
    
    print 'Starting Population'
    print 'Deleting old user (if present)'
    # Delete previous test user, if present
    prev_test_user = User.find_by_email("sample_user@sample.com")
    prev_test_user.try(:destroy)
    
    service_types = ['Residential', 'Commercial', 'Janitorial', 'Inspection']
    field_types = ['boolean', 'select', 'string']
    statuses = ['Active', 'Stand-By', 'Cancelled', 'Completed']
    
    def fake_phone_number
      (rand(900) + 100).to_s + "-" + (rand(900) + 100).to_s + "-"+ (rand(9000) + 1000).to_s
    end
    
    def random_time
      random_time = 2.weeks.ago + rand * ((Time.now + 2.weeks).to_f - 2.weeks.ago.to_f)
      random_start_time = Time.parse(appointment_times(:exact => true, :start_time => 9.hours, :end_time => 17.hours).sample)
      random_time.change(:hour => random_start_time.hour, :min => random_start_time.min)
    end
    
    print 'Creating sample user'
    #User, user profile, and user  data
    test_user = User.new(:email => 'sample_user@sample.com', :full_name => "#{Faker::Name.first_name} #{Faker::Name.last_name}", :phone_number => fake_phone_number, :company_name => Faker::Company.name, :password => 'zenmaidpass', :password_confirmation => 'zenmaidpass')
    test_user.preferences[:instant_booking] = true
    test_user.preferences[:service_items_as_checkbox] = true
    test_user.completed_onboarding = true
    test_user.free_trial_end = Time.zone.now + 2.weeks
    test_user.save
    
    # Create the employee account which can sign in
    test_user.build_owner_employee
    test_user.save
    
    print 'Initializing sample user account configuration'
    test_user.reload
    i = test_user.build_instant_booking_profile
    i.save
    
    test_user.reload
    u = test_user.build_user_profile(:company_name => test_user.company_name, :company_phone_number => test_user.phone_number, :company_email => test_user.email)
    u.save

    test_user.reload
    g = test_user.build_payment_gateway
    g.save
    
    test_user.reload
    service_types.shuffle.each do |service_type_name|
      s = test_user.service_types.build(:name => service_type_name, :base_price => rand(100))
      s.save
    end
    
    test_user.reload
    statuses.each do |status_name|
      s = test_user.statuses.build(:name => status_name)
      s.save
    end
    
    print 'Sample user account configuration complete'
    # Now add some appointment fields not associated to a service type
    (rand(4) + 2).times do |i|
      a = test_user.appointment_fields.build(:field_name => Faker::Lorem.words(1)[0].titleize, :input_type => "string", :order => rand(20), :price => rand(100), :min_field_value => rand(1), :max_field_value => rand(20)+1,
        :show_in_table => rand(5) > 3 ? true : false, :show_in_preview => rand(5) > 3 ? true : false)

      a.save!
    end
    # Now add some custom customer fields
    (rand(4) + 2).times do |i|
      a = test_user.customer_fields.build(:field_name => Faker::Lorem.words(1)[0].titleize, :input_type => "string", :order => rand(20), :min_field_value => rand(1), :max_field_value => rand(20)+1)
      a.save!
    end
    
    (rand(4) + 2).times do |i|
      a = test_user.employee_fields.build(:field_name => Faker::Lorem.words(1)[0].titleize, :input_type => "string", :order => rand(20), :min_field_value => rand(1), :max_field_value => rand(20)+1)
      a.save!
    end    
    
    (rand(4) + 8).times do |i|
      a = test_user.instant_booking_fields.build(:field_name => Faker::Lorem.words(1)[0].titleize, :input_type => "string", :order => rand(20), :min_field_value => rand(1), :max_field_value => rand(20)+1, 
        :price => rand(100), :service_type_id => test_user.service_type_ids.sample)
      a.save!
    end  
    
    #  Now add some instructions
    (rand(10) + 2).times do |i|
      a = test_user.instructions.build(:order => rand(20), :field_name => Faker::Lorem.words(1)[0].titleize)
      a.save!
    end

    print 'Sample user custom fields built'
    
    test_user.reload
    9.times do |i|
      c = test_user.employees.build(:first_name => Faker::Name.first_name, :last_name => Faker::Name.last_name, :email => Faker::Internet.email, :phone_number => fake_phone_number)
      test_user.employee_fields.each do |employee_field|
        value = employee_field.value_names.present? ? employee_field.value_names.values.sample : Faker::Lorem.words(1)[0].titleize
        c.employee_items.build(:custom_field_id => employee_field.id, :value_name => value)
      end
      
      c.save!

    end

    print 'Sample user employees built'

    b = test_user.email_templates.build(:template_resource => "Appointment", :template_type => "Work Order", :title => "Temp", :body => "Temp")
    b.save!
    b = test_user.email_templates.build(:template_resource => "Appointment", :template_type => "Appointment Confirmation", :title => "Temp", :body => "Temp")
    b.save!
   
    b = test_user.email_templates.build(:template_resource => "Appointment", :template_type => "Appointment Reminder", :title => "Temp", :body => "Temp")
    b.save!
   
    b = test_user.email_templates.build(:template_resource => "Appointment", :template_type => "Appointment Follow-Up", :title => "Temp", :body => "Temp")
    b.save!

    b = test_user.email_templates.build(:template_resource => "Customer", :template_type => "Come Back", :title => "Temp", :body => "Temp")
    b.save!

    b = test_user.text_templates.build(:template_type => "Appointment Reminder", :body => "Temp")
    b.save!
    b = test_user.text_templates.build(:template_type => "Work Order", :body => "Temp")
    b.save!


    test_user.reload
    100.times do |i|
      c = test_user.customers.build(:first_name => Faker::Name.first_name, :last_name => Faker::Name.last_name, :company_name => Faker::Company.name)
      c.allow_duplicate = true
      c.emails.build(:address => Faker::Internet.email) 
      c.phone_numbers.build(:phone_number => fake_phone_number)
      c.attached_notes.build(:body => Faker::Lorem.paragraph(5))
      
      test_user.customer_fields.each do |customer_field|
        value = customer_field.value_names.present? ? customer_field.value_names.values.sample : Faker::Lorem.words(1)[0].titleize
        c.customer_items.build(:custom_field_id => customer_field.id, :value_name => value)
      end
      
      c.save!
    end

    print 'Sample user customers built'

    test_user.reload
    100.times do |i|
      s =  test_user.customers.sample.subscriptions.build(:frequency => rand(2) + 2, :interval => rand(4) + 1)
      
      start_time = random_time
      end_time = start_time + (rand(4) + 1).hours
      
      a = s.appointments.build(:start_time => start_time, :end_time => end_time, :price => rand(400), :service_type_id => test_user.service_types.sample.id, :status_id => test_user.statuses.sample.id)
      
      a.requests = Faker::Lorem.paragraph(5)
      a.notes = Faker::Lorem.paragraph(5)
      
      test_user.appointment_fields.each do |appointment_field|
        value = appointment_field.value_names.present? ? appointment_field.value_names.values.sample : Faker::Lorem.words(1)[0].titleize
        a.appointment_items.build(:custom_field_id => appointment_field.id, :value_name => value)
      end
      
      rand(7).times do |j|
        instruction = test_user.instructions.sample
        value = rand(1) ? nil : Faker::Lorem.words(1)[0].titleize
        a.appointment_service_items.build(:instruction_id => instruction.id, :field_name => instruction.field_name, :value_name => value)
      end
      
      a.build_address(:line1 => Faker::Address.street_address, :city => Faker::Address.city, :state => Faker::Address.us_state_abbr, :postal_code => Faker::Address.zip_code)
      
      s.save!
    end
    
    print 'Sample user appointments built'
  end
end