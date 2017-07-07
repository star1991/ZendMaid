module PhoneNumberHelper
  def formatted_phone_helper(format, phone_number)
    if format == :international
      '+' + phone_number[0] + '-' + phone_number[1..3] + '-' + phone_number[4..6] + '-' + phone_number[7..-1]
    elsif format == :domestic
      phone_number[0..2] + '-' + phone_number[3..5] + '-' + phone_number[6..-1]
    end
  end
  
  def formatted_phone_number(phone_number)
    if phone_number.blank?
      phone_number
    elsif phone_number.size == 10
      formatted_phone_helper :domestic, phone_number
    elsif phone_number.size == 11
      formatted_phone_helper :international, phone_number
    else
      phone_number
    end
  end
  
  def strip_nondigits_from_phone_number(phone_number)
    if not phone_number.blank?
      phone_number.gsub(/\D/, '')
    end
  end

  
  def phone_number_types
    ["Home", "Cell", "Cell (Don't Text)", "Work", "Fax", "Spouse", "Other"]
  end
end
