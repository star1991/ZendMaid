MailchimpSubscriberJob = Struct.new(:user, :name, :sync_for, :employee) do
  def perform
    auth = user.auth
    batch = prepare_contacts_list(sync_for, user)

    MailchimpSubscriber.subscribe_batch(user, name, batch)
    user.mailchimp_syncing = false
    user.mailchimp_last_sync = DateTime.now
    user.save

    AppointmentsMailer.mailchimp_finished_syncing(employee.email).deliver
  end

  def prepare_contacts_list(sync_for, user)
    batch = []
    customers = Customer.filtered_customers(user, {:filter => sync_for})

    # iterate and create hash for all emails
    customers.each do |cus|
      email = cus.automatable_emails.try(:first).try(:address)
      unless email.blank?
        batch << {
          "email" => {
            "email" => email
          },
          "merge_vars" => {
            "FNAME" => cus.first_name,
            "LNAME" => cus.last_name
          },
          "email_type" => "html"
        }
      end
    end

    batch
  end
end