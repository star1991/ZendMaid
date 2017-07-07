module SubscriptionsHelper
  
  def frequency_values
    [
      ['Days', 1],
      ['Weeks', 2],
      ['Months', 3],
      ['Years', 4]
    ]
  end
  
  def recurrence_in_words(subscription, upper_case = false)
    single_words = ["none", "daily", "weekly", "monthly", "yearly"]
    plural_words = ["none", "days", "weeks", "months", "years"]
    

    if subscription.interval > 1
      "every #{subscription.interval} #{plural_words[subscription.frequency]}"
    else
      single_words[subscription.frequency]
    end
  end
  
  def day_description(subscription, appointment_prototype)
    case subscription.frequency
    when 2
      " on #{appointment_prototype.start_time.strftime('%A')}s"
    when 3
      " on the #{((appointment_prototype.start_time.day / 7) + 1).ordinalize} #{appointment_prototype.start_time.strftime('%A')}"
    else
    end
  end
  
  def recurrence_description(subscription, appointment_prototype)
    if subscription.repeat
      "#{recurrence_in_words(subscription)} #{day_description(subscription, appointment_prototype)} from #{appointment_prototype.start_time.strftime('%-I:%M %p')} - #{appointment_prototype.end_time.strftime('%-I:%M %p')}"
    else
      "#{appointment_prototype.start_time.strftime('%-m/%d/%Y, %-I:%M %p')} - #{appointment_prototype.end_time.strftime('%-I:%M %p')}"
    end
  end
  
  
end
