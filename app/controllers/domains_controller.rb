class DomainsController < BaseController
  before_action :set_pagy_params, only: :index

  def index
    conn = ApiConnector::Domains::All.new(**auth_info)
    result = conn.call_action(q: search_params,
                              limit: pdf_or_csv_request? ? nil : session[:page_size],
                              offset: pdf_or_csv_request? ? nil : @offset,
                              details: true,
                              simple: true)
    handle_response(result); return if performed?

    @statuses = @response.statuses
    @domains = @response.domains
    @pagy = Pagy.new(count: @response.count, items: session[:page_size], page: @page)
    @new_domain = @response.new_domain.first
    respond_to do |format|
      format.html
      format.csv { format_csv }
    end
  end

  def show
    conn = ApiConnector::Domains::Reader.new(**auth_info)
    result = conn.call_action(domain_name: params[:domain_name])
    handle_response(result); return if performed?

    @domain = @response.domain
  end

  def new
    @domain_params = default_params
  end

  def create
    conn = ApiConnector::Domains::Creator.new(**auth_info)
    result = conn.call_action(payload: domain_payload)
    handle_response(result); return if performed?

    flash.notice = @message
    redirect_to domain_path(domain_name: @response.domain[:name])
  end

  def edit
    conn = ApiConnector::Domains::Reader.new(**auth_info)
    result = conn.call_action(domain_name: params[:domain_name])
    handle_response(result); return if performed?

    @domain = @response.domain
    @domain_params = construct_params(@domain)
  end

  def update
    conn = ApiConnector::Domains::Updater.new(**auth_info)
    result = conn.call_action(payload: domain_payload)
    handle_response(result); return if performed?

    flash.notice = @message
    redirect_to domain_path(domain_name: @response.domain[:name])
  end

  def renew
    conn = ApiConnector::Domains::Renewer.new(**auth_info)
    result = conn.call_action(payload: domain_payload)
    handle_response(result); return if performed?

    flash.notice = @message
    redirect_to domain_path(domain_name: @response.domain[:name])
  end

  def new_transfer; end

  def new_renewal; end

  def new_bulk_change
    bulk_change_attrs = Rails.cache.fetch(session.id) { {} }
    redirect_to bulk_change_path(bulk_change_attrs[:form_steps]&.last || :select_type)
  end

  # NB! This method is used for both single and bulk transfers
  def transfer
    conn = ApiConnector::Transfers::Creator.new(**auth_info)
    result = conn.call_action(payload: domain_payload)
    handle_response(result); return if performed?

    create_transfer_message(@response)
    reset_bulk_change_cache
    redirect_to domains_path
  end

  def transfer_info
    conn = ApiConnector::Transfers::Reader.new(**auth_info)
    cmd = conn.read_transfers(domain_name: domain_params[:domain_name])

    if cmd.success
      @messages = cmd.body['data']
    elsif cmd.body['code'] == 2202
      redirect_to controller: 'sessions', action: 'new'
    else
      internal_server_error
    end
  end

  def delete; end

  def destroy
    conn = ApiConnector::Domains::Deleter.new(**auth_info)
    result = conn.call_action(payload: domain_payload)
    handle_response(result); return if performed?

    flash.notice = @message
    redirect_to domains_path
  end

  def add_hold
    conn = ApiConnector::Statuses::Adder.new(**auth_info)
    cmd = conn.add_client_hold(domain_name: domain_params[:domain_name])

    if cmd.success
      @messages = cmd.body['data']
    elsif cmd.body['code'] == 2202
      redirect_to controller: 'sessions', action: 'new'
    else
      internal_server_error
    end
  end

  def remove_hold
    conn = ApiConnector::Statuses::Remover.new(**auth_info)
    cmd = conn.remove_client_hold(domain_name: domain_params[:domain_name])

    if cmd.success
      @messages = cmd.body['data']
    elsif cmd.body['code'] == 2202
      redirect_to controller: 'sessions', action: 'new'
    else
      internal_server_error
    end
  end

  private

  def domain_params
    params.require(:domain)
          .permit(:id, :verified, :auth_code, :name, :reserved_pw, :exp_date,
                  :period_unit, :period, :admin_contact, :tech_contact,
                  :code, :verified, :transfer_code, :legal_document, :batch_file,
                  registrant: [%i[code verified]],
                  contacts_attributes: [%i[code type action]],
                  nameservers_attributes: [%i[id hostname ipv4 ipv6 action]],
                  dnskeys_attributes: [%i[id flags protocol alg public_key action]])
  end

  def default_params
    ret = {}

    ret[:period] = Rails.configuration.customization[:default_domain_period]

    ret[:contacts_attributes] = {}
    Rails.configuration.customization[:default_admin_contacts_count].times do |i|
      ret[:contacts_attributes][i.to_s] = { code: '', type: ApplicationHelper::CONTACT_TYPE[:admin],
                                            name: '' }
    end
    Rails.configuration.customization[:default_tech_contacts_count].times do |i|
      i += Rails.configuration.customization[:default_admin_contacts_count]
      ret[:contacts_attributes][i.to_s] = { code: '', type: ApplicationHelper::CONTACT_TYPE[:tech],
                                            name: '' }
    end

    ret[:nameservers_attributes] = {}
    Rails.configuration.customization[:default_nameservers_count].times do |i|
      ret[:nameservers_attributes][i.to_s] = {}
    end

    ret[:dnskeys_attributes] = { '0' => {} }

    ret.with_indifferent_access
  end

  def construct_params(domain)
    ret = default_params
    ret[:name] = domain[:name]
    ret[:dispute] = domain[:dispute]

    ret[:registrant] = "#{domain[:registrant][:code]} #{domain[:registrant][:name]}"

    domain[:contacts].each_with_index do |c, i|
      ret[:contacts_attributes][i.to_s] = c
    end

    domain[:nameservers].each_with_index do |n, i|
      n[:ipv4] = n[:ipv4].join(', ')
      n[:ipv6] = n[:ipv6].join(', ')
      ret[:nameservers_attributes][i.to_s] = n
    end

    domain[:dnssec_keys].each_with_index do |k, i|
      ret[:dnskeys_attributes][i.to_s] = k
    end

    ret
  end

  def domain_payload
    {
      name: domain_params[:name],
      reserved_pw: domain_params[:reserved_pw],
      transfer_code: domain_params[:transfer_code],
      registrant: domain_params[:registrant],
      period: domain_params[:period],
      contacts: if domain_params[:contacts_attributes].present?
                  domain_params[:contacts_attributes].values.reject { |c| c[:code].blank? }
                end,
      nameservers: if domain_params[:nameservers_attributes].present?
                     domain_params[:nameservers_attributes].values
                                                           .reject { |n| n[:hostname].blank? }
                                                           .map do |ns_attr|
                       {
                         id: ns_attr[:id],
                         hostname: ns_attr[:hostname],
                         ipv4: ns_attr[:ipv4].split(','),
                         ipv6: ns_attr[:ipv6].split(','),
                         action: ns_attr[:action],
                       }
                     end
                   end,
      dns_keys: if domain_params[:dnskeys_attributes].present?
                  domain_params[:dnskeys_attributes].values.reject { |d| d[:public_key].blank? }
                end,
      legal_document: transform_legal_doc_params(domain_params[:legal_document]),
      batch_file: parse_csv(domain_params[:batch_file]),
      exp_date: domain_params[:exp_date],
    }
  end

  def renew_payload
    {
      period: domain_params[:period],
      period_unit: domain_params[:period_unit],
      exp_date: domain_params[:exp_date],
    }
  end

  def parse_csv(params)
    return unless params.present?

    csv = CSV.parse(Base64.decode64(params), headers: true, col_sep: ';')
    transfers = []
    csv.each do |row|
      transfers << { domain_name: row['Domain'], transfer_code: row['Transfer code'] }
    end
    transfers
  end

  def format_csv
    raw_csv = DomainListCsvPresenter.new(domains: @domains,
                                         view: view_context).to_s
    filename = "Domains_#{l(Time.zone.now, format: :filename)}.csv"
    send_data raw_csv, filename: filename, type: "#{Mime[:csv]}; charset=utf-8"
  end

  def create_transfer_message(response)
    if response[:failed].size == 1 && response[:success].empty?
      flash.alert = @response[:failed].first[:errors][:msg]
    else
      failed = response[:failed].pluck(:domain_name).join(', ')
      notice = t('.transferred', count: response[:success].size)
      notice += t('.failed', failed: failed) unless failed.empty?
      flash.notice = notice
    end
  end
end
