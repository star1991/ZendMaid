class AddMarketingSourceRecordToUsers < ActiveRecord::Migration
  def up
    CustomField.reset_column_information
    User.reset_column_information

    User.all.each do |user|
      ms_custom_field = CustomField.new
      ms_custom_field.input_type = 'select'
      ms_custom_field.field_type = 'marketing'
      ms_custom_field.field_name = "Marketing Source"
      ms_custom_field.user_id = user.id
      ms_custom_field.save!
    end

  end

  def down
    CustomField.reset_column_information
    CustomField.where(:field_name => "Marketing Source").destroy_all
  end
end
