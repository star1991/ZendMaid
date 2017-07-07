class ImportReportMailer < ActionMailer::Base
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::NumberHelper

  default :from => "no-reply@zenmaid.com"

  def customers_import_report(num_saved, num_error, failed_customers)  
    @saved_customer = num_saved
    @not_saved_customer = num_error
    @failed_customers = failed_customers

    mail(:to => ["amar@zenmaid.com", "arun@zenmaid.com"], :subject => "Customer import report")  
  end
end
