class QualityDrivenSoftwareExportMailer < ActionMailer::Base
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::NumberHelper

  default :from => "no-reply@zenmaid.com"

  def quality_driven_software_export(csv_file, user, from, to)
    attachments["export.csv"] = csv_file
    mail(to: ['arun@zenmaid.com', 'amar@zenmaid.com'], subject: "QDS export for #{user.id}, #{user.user_profile.company_name} for dates #{from.strftime('%m/%d/%Y')} – #{to.strftime('%m/%d/%Y')}")
  end
end
