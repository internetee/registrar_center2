# frozen_string_literal: true

class ContactsController < BaseController # rubocop:disable Metrics/ClassLength
  before_action :set_pagy_params, only: %i[index show]

  # Get all the contacts
  def index
    conn = ApiConnector::Contacts::All.new(**auth_info)
    result = conn.call_action(q: search_params,
                              limit: pdf_or_csv_request? ? nil : session[:page_size],
                              details: true,
                              offset: pdf_or_csv_request? ? nil : @offset)
    handle_response(result); return if performed?

    set_instance_variables
    respond_to_formats
  end

  def search
    conn = ApiConnector::Contacts::Finder.new(**auth_info)
    result = conn.call_action(q: params[:query], id: params[:id])

    if result.success
      render json: result.body[:data], status: :ok
    else
      respond_with_log_out(result.body[:message])
    end
  end

  # Show the contact info
  def show
    fetch_contact
    return if performed?

    @domains = @contact[:domains]
    @contact_types = ApplicationHelper::CONTACT_TYPE.merge(registrant: 'Registrant')
    @pagy = Pagy.new(count: @contact[:domains_count], items: session[:page_size], page: @page)
  end

  def delete
    conn = ApiConnector::Contacts::Reader.new(**auth_info)
    result = conn.call_action(id: params[:contact_code], simple: true)
    handle_response(result); return if performed?

    @contact = @response.contact
  end

  def destroy
    conn = ApiConnector::Contacts::Deleter.new(**auth_info)
    result = conn.call_action(payload: contact_payload)
    handle_response(result); return if performed?

    flash.notice = @message
    redirect_to contacts_path
  end

  def new
    authorize! :create, 'Epp::Contact'
  end

  def create
    handle_contact_action(ApiConnector::Contacts::Creator)
  end

  def edit
    conn = ApiConnector::Contacts::Reader.new(**auth_info)
    result = conn.call_action(id: params[:contact_code])
    handle_response(result); return if performed?

    @contact = @response.contact
  end

  def update
    handle_contact_action(ApiConnector::Contacts::Updater)
  end

  def verify
    conn = ApiConnector::Contacts::Verifier.new(**auth_info)
    result = conn.call_action(id: params[:contact_code])
    handle_response(result); return if performed?

    flash.notice = @message
    redirect_to contact_path(contact_code: @response.contact[:code])
  end

  def download_poi
    conn = ApiConnector::Contacts::PoiDownloader.new(**auth_info)
    result = conn.call_action(id: params[:contact_code])
    handle_response(result); return if performed?

    send_data(@response, type: 'application/pdf',
                         disposition: 'attachment',
                         filename: @message.match(/filename=(\"?)(.+)\1/)[2])
  end

  private

  def contact_params
    params.require(:contact).permit(:code, :ident_country_code, :ident_type,
                                    :ident, :name, :email, :phone, :country_code,
                                    :city, :street, :state, :zip, :legal_document)
  end

  def set_instance_variables
    @ident_types = [['Vali', '']] + @response.ident_types
    @statuses = @response.statuses
    @contacts = @response.contacts
    @pagy = Pagy.new(count: @response.count, items: session[:page_size], page: @page)
  end

  def respond_to_formats
    respond_to do |format|
      format.html
      format.csv { format_csv }
      format.pdf { format_pdf }
    end
  end

  def handle_contact_action(conn_class)
    conn = conn_class.new(**auth_info)
    result = conn.call_action(payload: contact_payload)
    handle_response(result); return if performed?

    flash.notice = @message
    redirect_to contact_path(contact_code: @response.contact[:code])
  end

  def fetch_contact
    conn = ApiConnector::Contacts::Reader.new(**auth_info)
    result = conn.call_action(
      id: params[:contact_code],
      per_page: session[:page_size],
      page: @page,
      domain_filter: params[:contact_types],
      q: search_params
    )
    handle_response(result)
    @contact = @response&.contact
  end

  def contact_payload
    {
      id: contact_params[:code],
      name: contact_params[:name],
      email: contact_params[:email],
      phone: contact_params[:phone],
      ident: contact_ident_payload,
      addr: contact_address_payload,
      legal_document: transform_file_params(contact_params[:legal_document]),
    }
  end

  def contact_ident_payload
    {
      ident: contact_params[:ident],
      ident_type: contact_params[:ident_type],
      ident_country_code: contact_params[:ident_country_code],
    }
  end

  def contact_address_payload
    return unless current_user.address_processing

    {
      country_code: contact_params[:country_code],
      city: contact_params[:city],
      street: contact_params[:street],
      zip: contact_params[:zip],
      state: contact_params[:state],
    }
  end

  def format_csv
    raw_csv = ContactListCsvPresenter.new(objects: @contacts,
                                          view: view_context).to_s
    send_data raw_csv, filename: "#{filename}.csv", type: "#{Mime[:csv]}; charset=utf-8"
  end

  def format_pdf
    pdf_html = ActionController::Base.new.render_to_string(template: 'contacts/list_pdf',
                                                           locals: { contacts: @contacts,
                                                                     view: view_context },
                                                           layout: 'pdf')
    pdf = WickedPdf.new.pdf_from_string(pdf_html, page_size: 'A4', orientation: 'Landscape',
                                                  header: { right: '[page] of [topage]' },
                                                  lowquality: true,
                                                  zoom: 1,
                                                  dpi: 75)
    send_data pdf, filename: "#{filename}.pdf"
  end

  def filename
    "Contacts_#{l(Time.zone.now, format: :filename)}"
  end
end
