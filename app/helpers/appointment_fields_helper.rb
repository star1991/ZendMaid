module AppointmentFieldsHelper
  
  def simple_form_hash(appointment_field, options = {})
    simple_form_hash = {}
    simple_form_hash[:as] = appointment_field.input_type.try(:to_sym)
    simple_form_hash[:label] = appointment_field.field_name
    
    if options[:compact]
      simple_form_hash[:wrapper_html] = { :class => "compact-horizontal-wide" }
    end
    
    if not options[:no_estimation]
      simple_form_hash[:input_html] = {:data => {:id => appointment_field.id, :price => appointment_field.price}, :class => "quantity-to-estimate"}
    else
      simple_form_hash[:input_html] = {}
    end
    
    if simple_form_hash[:as] == :radio_buttons || simple_form_hash[:as] == :select
      simple_form_hash[:collection] = appointment_field.value_names.values
      simple_form_hash[:input_html][:autocomplete] = :off
      #Makes radio buttons appear in a line
      #simple_form_hash[:item_wrapper_class] = 'inline'
    elsif simple_form_hash[:as] == :boolean
      simple_form_hash[:checked_value] = appointment_field.value_names[1]
      simple_form_hash[:unchecked_value] = appointment_field.value_names[0]
      simple_form_hash[:label] = false
      simple_form_hash[:inline_label] = appointment_field.field_name
      simple_form_hash[:input_html][:autocomplete] = :off
    end

    simple_form_hash
  end
    
  def collection_values(appointment_field)
    collection_vals = Array(appointment_field.min_field_value..appointment_field.max_field_value).map { |i| i.to_s }
    collection_vals[-1] += '+'
      
    collection_vals
  end
  
  def custom_field_input_types
    [['Checkbox', 'boolean'], ['Dropdown', 'select'], ['Text', 'string']]
  end
  
end
