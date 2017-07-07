QualityDrivenSoftwareExportJob  = Struct.new(:from_date, :to_date, :current_user ) do
  
  def perform
    from = from_date.present? ? Time.zone.parse(from_date).beginning_of_day : (Time.zone.now - 1.week).beginning_of_day
    to =  to_date.present? ? Time.zone.parse(to_date).end_of_day : Time.zone.now.end_of_day

    # select appointments from date range and export to csv
    appointments = current_user.appointments.actual.includes(:subscription, :status, {:customer => [:emails, :phone_numbers]}, :employees).where('statuses.show_in_work_orders = ?', true).where(:start_time => from..to)
    csv_file = Appointment.export_to_csv(appointments)

    # call a mailer and send email
    QualityDrivenSoftwareExportMailer.quality_driven_software_export(csv_file, current_user, from, to).deliver
  end
end