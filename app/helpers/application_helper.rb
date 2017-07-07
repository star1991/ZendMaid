module ApplicationHelper
  
  def full_title(page_title, no_full = false)
    base_title = "ZenMaid"
    if page_title.empty?
      base_title
    elsif no_full
      page_title
    else
      "#{base_title} | #{page_title}"
    end
  end 
  
  def yes_no(bool_var)
    bool_var ? "Yes": "No"
  end
  
  def is_numeric?(val)
    true if Float(val) rescue false
  end
  
  def string_to_boolean(val)
    return true if val == true || val =~ (/^(true|t|yes|y|1)$/i)
    return false if val == false || val.blank? || val =~ (/^(false|f|no|n|0)$/i)
    raise ArgumentError.new("invalid value for Boolean: \"#{val}\"")
  end
  
  def liquidize(template, options = {})
    parsed_template = Liquid::Template.parse(template)
    parsed_template.render(options)
  end
  
  def smart_add_url_protocol(url, options = {})
    if !url[/\Ahttp:\/\//] && !url[/\Ahttps:\/\//]
      if options[:secure]
        "https://#{url}"
      else
        "http://#{url}"
      end
    else
      url
    end
  end
  
  def display_pay_rate(resource)
    case resource.pay_type
    when 'Hourly'
      "#{number_to_currency resource.pay_rate}/hr"
    when 'Revenue Share'
      "#{resource.pay_rate}% Revenue Share"
    when 'Fixed Flat Rate'
      "#{number_to_currency resource.pay_rate} Flat Rate"
    when 'Variable Flat Rate'
      "Variable Flat Rate"
    else
      '<strong class="red">No pay rate on record</strong>'.html_safe
    end
  end
  
  def display_service_type(service_type)
    service_type.present? ? "#{service_type.name} Service" : "Residential Service"
  end
 
 def page_entries_info(collection, options = {})
    entry_name = options[:entry_name] || (collection.empty?? 'item' : collection.first.class.name.split('::').last.titleize)
    if collection.total_pages < 2
      case collection.size
      when 0; "No #{entry_name.pluralize} found"
      else; "Displaying all #{entry_name.pluralize}"
      end
    else
      %{Displaying %d - %d of %d #{entry_name.pluralize}} % [
        collection.offset + 1,
        collection.offset + collection.length,
        collection.total_entries
      ]
    end
  end 

  # code graciously copied and pasted from
  # http://mysmallidea.com/articles/2009/5/31/parse-full-names-with-ruby/index.html
  def parse_name(name)
    return false unless name.is_a?(String)
    
    # First, split the name into an array
    parts = name.split
    
    # If any part is "and", then put together the two parts around it
    # For example, "Mr. and Mrs." or "Mickey and Minnie"
    parts.each_with_index do |part, i|
      if ["and", "&"].include?(part) and i > 0
        p3 = parts.delete_at(i+1)
        p2 = parts.at(i)
        p1 = parts.delete_at(i-1)
        parts[i-1] = [p1, p2, p3].join(" ")
      end
    end
    
    # Build a hash of the remaining parts
    hash = {
      :suffix => (s = parts.pop unless parts.last !~ /(\w+\.|[IVXLM]+|[A-Z]+)$/),
      :last_name  => (l = parts.pop),
      :prefix => (p = parts.shift unless parts[0] !~ /^\w+\./),
      :first_name => (f = parts.shift),
      :middle_name => (m = parts.join(" "))
    }
 
    #Reverse name if "," was used in Last, First notation.
    if hash[:first_name] =~ /,$/
      hash[:first_name] = hash[:last_name]
      hash[:last_name] = $` # everything before the match
    end
 
    # If one word is input, default to word being first name
    if hash[:first_name].blank? && hash[:last_name].present?
      hash[:first_name] = hash[:last_name]
      hash[:last_name] = ""
    end

    return hash
  end

  def simple_format_no_tags(text, html_options = {}, options = {})
    text = '' if text.nil?
    text = sanitize(text) unless options[:sanitize] == false
    text = text.to_str
    text.gsub!(/\r\n?/, "\n")                    # \r\n and \r -> \n
    text.gsub!(/\n/, '<br />')
    text.html_safe
  end

  def quickbooks_customer_url(customer)
    "https://qbo.intuit.com/app/customerdetail?nameId=#{customer.qb_customer_id}"
  end

  def current_onboarding_page
    case current_user.onboarding_page
    when 1
      user_info_onboarding_path
    when 2
      customer_templates_onboarding_path
    when 3
      custom_fields_onboarding_path
    when 4
      employee_management_onboarding_path
    when 5
      entrance_survey_path
    else
    end 
  end

end
