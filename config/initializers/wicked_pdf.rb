# Configure WickedPdf to use system wkhtmltopdf in CI
if Rails.env.test? && File.exist?('/usr/bin/wkhtmltopdf')
  WickedPdf.config = {
    exe_path: '/usr/bin/wkhtmltopdf'
  }
end