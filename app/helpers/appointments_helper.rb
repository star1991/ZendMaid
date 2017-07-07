module AppointmentsHelper


  def appointment_times(parameters)

    if parameters[:exact] == false
      [
        ['Morning (9 AM - 11 AM)', '9:00 AM'],
        ['Midday (11 AM - 1 PM)', '11:00 AM'],
        ['Early Afternoon (1 PM - 3 PM)', '1:00 PM'],
        ['Late Afternoon (3 PM - 5PM)', '3:00 PM']
      ]
    else
      start_time = parameters[:start_time] ? parameters[:start_time] : 0
      end_time = parameters[:end_time] ? parameters[:end_time] : 24.hours
      increment = parameters[:increment] ? parameters[:increment] : 15.minutes
      Array.new(1 + (end_time - start_time)/increment) do |i|
        (Time.now.midnight + (i*increment) + start_time).strftime("%l:%M %p")
      end
    end
  end

  def formatted_time(start_time, parameters={})
    if parameters[:exact]
      start_time.strftime('%l:%M %p')
    else

      h = start_time.hour
      case
      when h >= 9 && h < 11
        'Morning (9 AM - 11 AM)'
      when h >= 11 && h < 13
        'Midday (11 AM - 1 PM)'
      when h >= 13 && h < 15
        'Early Afternoon (1 PM - 3 PM)'
      when h >= 15 && h < 17
        'Late Afternoon (3 PM - 5PM)'
      else
        start_time.strftime('%l:%M %p')
      end
    end
  end

  def appointment_time_to_string(start_time, end_time)
    "#{formatted_time(start_time, :exact => true)} - #{formatted_time(end_time, :exact => true)}"
  end

  def start_time_label
    if current_user.blank?
      "Start Time"
    else
      "Start Time"
    end
  end

  def start_time_date_input_html_hash(appointment)
    if appointment.start_time.present?
      {:value => appointment.start_time.strftime("%m/%d/%Y")}
    else
      {}
    end
  end

  def cleaners(appointment)
    team = appointment.assignments.map do |team_name|
      team_name.employee.full_name
    end
    if !team.empty?
      "Assigned to #{team.join ', '}"
    else
      'Not Assigned Yet'
    end
  end
end
