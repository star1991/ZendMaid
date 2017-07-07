CustomersImportJob  = Struct.new(:file_id, :user_id, :params ) do
  
  def perform
    num_saved, num_error, failed_customers = Customer.import(file_id, user_id, params)
    # call a mailer and send email
    ImportReportMailer.customers_import_report(num_saved, num_error, failed_customers).deliver
  end
end