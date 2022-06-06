class InvoicesController < BaseController
  before_action :set_pagy_params, only: :index

  def index
    conn = ApiConnector::Invoices::All.new(**auth_info)
    result = conn.call_action(q: search_params,
                              limit: session[:page_size],
                              offset: @offset,
                              details: true,
                              simple: true)
    handle_response(result); return if performed?

    @invoices = @response.invoices
    @statuses = ApplicationHelper::INVOICE_STATUS
    @pagy = Pagy.new(count: @response.count, items: session[:page_size], page: @page)
  end

  def show
    conn = ApiConnector::Invoices::Reader.new(**auth_info)
    result = conn.call_action(id: params[:id])
    handle_response(result); return if performed?

    @invoice = @response.invoice
    respond_to do |format|
      format.html
      format.pdf { format_pdf }
    end
  end

  def download
    conn = ApiConnector::Invoices::Downloader.new(**auth_info)
    result = conn.call_action(id: params[:id])
    handle_response(result); return if performed?

    send_data(@response, type: 'application/pdf',
                         disposition: 'attachment',
                         filename: @message.match(/filename=(\"?)(.+)\1/)[2])
  end

  def send_to_recipient
    conn = ApiConnector::Invoices::Sender.new(**auth_info)
    result = conn.call_action(payload: invoice_payload)
    handle_response(result); return if performed?

    flash.notice = @message
    redirect_to invoice_path(@response.invoice[:id])
  end

  def cancel
    conn = ApiConnector::Invoices::Canceller.new(**auth_info)
    result = conn.call_action(payload: invoice_payload)
    handle_response(result); return if performed?

    flash.notice = @message
    redirect_to invoice_path(@response.invoice[:id])
  end

  def add_credit
    conn = ApiConnector::Invoices::Creditor.new(**auth_info)
    result = conn.call_action(payload: deposit_payload)
    handle_response(result); return if performed?

    flash.notice = t('invoices.index.please_pay')
    redirect_to invoice_path(@response.invoice[:id])
  end

  private

  def invoice_params
    params.require(:invoice).permit(:id, :recipient, :amount, :description)
  end

  def invoice_payload
    {
      id: invoice_params[:id],
      recipient: invoice_params[:recipient],
    }
  end

  def deposit_payload
    {
      amount: invoice_params[:amount],
      description: invoice_params[:description],
    }
  end

  def format_pdf
    pdf = InvoicePdfPresenter.new(invoice: @invoice, view: view_context).to_pdf
    send_data pdf, filename: "Invoice-#{@invoice[:number]}.pdf"
  end
end