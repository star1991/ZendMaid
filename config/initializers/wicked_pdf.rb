if Rails.env.development?
  WickedPdf.config = { :exe_path => 'C:\Program Files (x86)\wkhtmltopdf\wkhtmltopdf.exe' }
elsif Rails.env.production?
  WickedPdf.config = { :exe_path => "#{Rails.root}/bin/wkhtmltopdf" }
end