require 'csv'
module StepsControllers
  class BulkChangeController < BaseController # rubocop:disable Metrics/ClassLength
    include Wicked::Wizard

    before_action :find_bulk_change_attributes
    before_action :validate_params, :validate_csv, only: :update
    before_action :check_step_allowance, only: :show
    after_action :save_bulk_change_cache, only: :update

    FORM_STEP_REQUIRED_PARAMS = {
      select_type: {},
      input_data: { 'tech-contact-change': %i[current_contact_id new_contact_id],
                    'admin-contact-change': %i[current_contact_id new_contact_id],
                    'nameserver-change': [:new_hostname],
                    'registrar-change': [],
                    'domain-renew': %i[expire_date period] },
      make_changes: {},
    }.freeze

    REQUIRED_CSV_FILE_HEADER = {
      'nameserver-change': ['Domain'],
      'registrar-change': ['Domain', 'Transfer code'],
    }.freeze

    steps(*FORM_STEP_REQUIRED_PARAMS.keys) # :select_type, :input_data, :make_changes

    # rubocop:disable Metrics/MethodLength
    def show
      case @attrs[:type]
      when 'registrar-change', 'nameserver-change'
        @file_uploaded = @attrs[:batch_file_name].present?
        if @file_uploaded
          csv = CSV.parse(Base64.decode64(@attrs[:batch_file_encoded]), headers: true)
          @size = csv.size
        end
      when 'domain-renew'
        @domains = @attrs[:domains] || []
        items = @domains.count.positive? ? @domains.count : 1
        @pagy = Pagy.new(count: @domains.count, items: items, page: 1)
      end
      render_wizard
    end
    # rubocop:enable Metrics/MethodLength

    def update
      reset_bulk_change_cache if first_step_submitted?
      maybe_add_batch_file_attrs
      if maybe_find_domains_for_renew
        redirect_to_next(step)
      else
        redirect_to_next(next_step)
      end
    end

    def cancel
      reset_bulk_change_cache
      redirect_to new_domain_bulk_change_path
    end

    # def finish_wizard_path
    #   reset_bulk_change_cache
    #   domains_path
    # end

    private

    def validate_params
      respond_with_error(:missing_param, :type) and return if @attrs[:type].blank?

      required_attrs = FORM_STEP_REQUIRED_PARAMS[step][@attrs[:type].to_sym] || []
      invalid_attrs = required_attrs.map { |a| a if @attrs[a].blank? }.compact
      respond_with_error(:missing_param, invalid_attrs.first) unless invalid_attrs.empty?
    end

    def validate_csv
      expected_header = REQUIRED_CSV_FILE_HEADER[@attrs[:type].to_sym]
      valid_header = check_csv_header(expected_header, @attrs[:batch_file])
      respond_with_error(:invalid_csv) unless valid_header
    end

    def find_bulk_change_attributes
      @attrs = bulk_change_attrs&.symbolize_keys
    end

    # rubocop:disable Metrics/MethodLength
    def respond_with_error(msg, param = nil)
      msg = t(".#{msg}", param: t(".#{param}"))
      respond_to do |format|
        format.html do
          flash[:alert] = msg
          render_wizard
        end
        format.turbo_stream do
          flash.now[:alert] = msg
          render turbo_stream: turbo_stream.update('flash', partial: 'common/flash')
        end
      end
    end
    # rubocop:enable Metrics/MethodLength

    def bulk_change_params
      params.require(:bulk_change)
            .permit(:type, :batch_file, :form_steps, :domain_filter,
                    :current_contact_id, :new_contact_id, :old_hostname,
                    :new_hostname, :ipv4, :ipv6, :expire_date, :period,
                    selected_domains: [])
            .merge(form_steps: steps[0..steps.index(next_step)])
    end

    def bulk_change_attrs
      attrs = Rails.cache.read(session.id)
      return attrs unless params[:bulk_change]

      attrs.merge(bulk_change_params)
    end

    def check_step_allowance
      redirect_to domains_path and return unless @attrs && step_allowed?
      # redirect_to domains_path and return unless step_allowed?
    end

    def step_allowed?
      return true if step == steps.first
      return false unless @attrs[:form_steps]

      @attrs[:form_steps].include? step
    end

    def first_step_submitted?
      params[:bulk_change]&.dig(:form_steps) == 'select_type'
    end

    def maybe_add_batch_file_attrs
      return if @attrs[:batch_file].blank?

      @attrs[:batch_file_name] = @attrs[:batch_file].original_filename
      @attrs[:batch_file_encoded] = Base64.encode64(@attrs[:batch_file].read)
    end

    def maybe_find_domains_for_renew
      return false if bulk_change_params[:domain_filter].blank?

      conn = ApiConnector::Domains::All.new(**auth_info)
      result = conn.call_action(q: { valid_to_lteq: @attrs[:expire_date] },
                                limit: nil, offset: nil,
                                details: true, simple: true)
      handle_response(result); return false if performed?

      @attrs[:domains] = @response.domains
      @attrs[:selected_domains] = @response.domains.pluck(:name)
      true
    end

    def check_csv_header(expected_header, csv_file)
      return true if csv_file.blank?

      header = CSV.open(csv_file, 'r', &:first)
      valid_csv = expected_header == header & expected_header
      Rails.logger.info "Invalid Header: #{header} Expected Header: #{expected_header}" unless valid_csv
      valid_csv
    end

    # def sniff_csv_delimiter(csv_file)
    #   return true if csv_file.blank?

    #   first_line = File.open(csv_file).first
    #   return true unless first_line

    #   snif = {}
    #   snif[VALID_CSV_DELIMITER] = first_line.count(VALID_CSV_DELIMITER)
    #   snif = snif.sort { |a, b| b[1] <=> a[1] }
    #   snif.size.positive?
    # end
  end
end
