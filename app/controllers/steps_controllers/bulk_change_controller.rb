require 'csv'
module StepsControllers
  class BulkChangeController < BaseController
    include Wicked::Wizard

    before_action :find_bulk_change_attributes
    before_action :validate_params, only: :update
    before_action :check_step_allowance, only: :show
    after_action :save_bulk_change_cache, only: :update

    CSV_COL_SEPARATOR = ';'.freeze

    TYPES = [
      [I18n.t('.choose'), ''],
      [I18n.t('steps_controllers.bulk_change.tech_contact_change'), 'tech-contact-change'],
      [I18n.t('steps_controllers.bulk_change.admin_contact_change'), 'admin-contact-change'],
      [I18n.t('steps_controllers.bulk_change.nameserver_change'), 'nameserver-change'],
      [I18n.t('steps_controllers.bulk_change.registrar_change'), 'registrar-change'],
      [I18n.t('steps_controllers.bulk_change.domain_renew'), 'domain-renew'],
    ].freeze

    FORM_STEP_REQUIRED_PARAMS = {
      select_type: {},
      input_data: { 'tech-contact-change': %i[current_contact_id new_contact_id],
                    'admin-contact-change': %i[current_contact_id new_contact_id],
                    'nameserver-change': [:new_hostname],
                    'registrar-change': [:batch_file],
                    'domain-renew': %i[expire_date period] },
      make_changes: {},
    }.freeze

    steps *FORM_STEP_REQUIRED_PARAMS.keys # :select_type, :input_data, :make_changes

    def show
      case @attrs[:type]
      when 'registrar-change', 'nameserver-change'
        @file_uploaded = @attrs[:batch_file_name].present?
        if @file_uploaded
          csv = CSV.parse(Base64.decode64(@attrs[:batch_file_encoded]), headers: true,
                                                                        col_sep: CSV_COL_SEPARATOR)
          @size = csv.size
        end
      when 'domain-renew'
        @domains = @attrs[:domains] || []
        items = @domains.count.positive? ? @domains.count : 1
        @pagy = Pagy.new(count: @domains.count, items: items, page: 1)
      end
      render_wizard
    end

    def update
      reset_bulk_change_cache if first_step_submitted?
      maybe_add_batch_file_attrs
      if maybe_find_domains_for_renew
        redirect_to_next(step)
      else
        redirect_to_next(next_step)
      end
    end

    private

    def validate_params
      respond_with_error(:type) and return unless @attrs[:type].present?

      required_attrs = FORM_STEP_REQUIRED_PARAMS[step][@attrs[:type].to_sym] || []
      invalid_attrs = required_attrs.map { |a| a unless @attrs[a].present? }.compact
      respond_with_error(invalid_attrs.first) unless invalid_attrs.empty?
    end

    def find_bulk_change_attributes
      @attrs = bulk_change_attrs&.symbolize_keys
    end

    def respond_with_error(param = nil)
      msg = t('.missing_param', param: t(".#{param}"))
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

    def finish_wizard_path
      reset_bulk_change_cache
      domains_path
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
      return unless @attrs[:batch_file].present?

      @attrs[:batch_file_name] = @attrs[:batch_file].original_filename
      @attrs[:batch_file_encoded] = Base64.encode64(@attrs[:batch_file].read)
    end

    def maybe_find_domains_for_renew
      return false unless bulk_change_params[:domain_filter].present?

      conn = ApiConnector::Domains::All.new(**auth_info)
      result = conn.call_action(q: { valid_to_lteq: @attrs[:expire_date] },
                                limit: nil,
                                offset: nil,
                                details: true,
                                simple: true)
      handle_response(result); return false if performed?

      @attrs[:domains] = @response.domains
      @attrs[:selected_domains] = @response.domains.pluck(:name)
      true
    end
  end
end