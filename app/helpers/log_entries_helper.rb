module LogEntriesHelper
  
  def log_entry_icon(log_entry)
    case log_entry.log_type
    when "Creation"
      "icon-bolt"
    when "Status"
      "icon-book"
    when "Reschedule"
      "icon-calendar"
    else
      "icon-warning-sign"
    end
  end
end
