class CustomersExportJob  < Struct.new(:additional, :filter, :current_filter, :current_user)
  
  def perform
    if filter == 'filtered-customers'
      customers = Customer.filtered_customers(current_user, JSON.parse(current_filter.gsub('=>', ':')).with_indifferent_access)
    elsif filter == 'active-customers'
      customers = current_user.active_customers
    else
      customers = current_user.customers
    end

    csv_file = Customer.export_to_csv(customers.includes(:emails, :phone_numbers, :customer_items, :addresses), additional)
    ExportCustomersReportMailer.customers_export_report(csv_file, current_user).deliver
  end
end