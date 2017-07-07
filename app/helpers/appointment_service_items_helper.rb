module AppointmentServiceItemsHelper
  
  def parsed_service_item_amount(service_item)
    if service_item.appointment_field.input_type != 'boolean'
      service_item.value_name
    else
      service_item.amount == 1 ? 'Yes': 'No'
    end
  end
   
end
