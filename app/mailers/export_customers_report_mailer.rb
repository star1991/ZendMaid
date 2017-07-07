class ExportCustomersReportMailer < ActionMailer::Base
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::NumberHelper

  default :from => "no-reply@zenmaid.com"

  def customers_export_report(csv_file, user)
    attachments["export.csv"] = csv_file
    mail(to: ['arun@zenmaid.com', 'amar@zenmaid.com'], subject: "Customer export for #{user.id}, #{user.user_profile.company_name}")
  end
end
