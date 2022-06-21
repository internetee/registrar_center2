class InvoicePdfPresenter
  attr_reader :invoice, :view

  def initialize(invoice:, view:)
    @invoice = invoice
    @view = view
  end

  def to_pdf
    pdf_html = ActionController::Base.new
                                     .render_to_string(template: 'invoices/pdf',
                                                       locals: { invoice: @invoice,
                                                                 view: @view },
                                                       layout: 'pdf')
    WickedPdf.new.pdf_from_string(pdf_html, page_size: 'A4',
                                            orientation: 'Portrait',
                                            lowquality: true,
                                            zoom: 1,
                                            dpi: 75)
  end
end
