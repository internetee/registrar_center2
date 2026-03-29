# frozen_string_literal: true

require 'csv'

class BulkActionsController < BaseController
  def contact_replace
    # cl_name = params[:type] == 'admin' ? 'AdminContactReplace' : 'TechContactReplace'
    # conn = ActiveSupport::Inflector.constantize("ApiConnector::BulkActions::#{cl_name}")
    #                                .new(**auth_info)

    conn = ApiConnector::BulkActions::TechContactReplace.new(**auth_info)
    result = conn.call_action(payload: replace_contact_payload)
    handle_response(result); return if performed?

    create_replace_message(@response)
    reset_bulk_change_cache
    redirect_to domains_path
  end

  def admin_contact_replace
    conn = ApiConnector::BulkActions::AdminContactReplace.new(**auth_info)
    result = conn.call_action(payload: replace_contact_payload)
    handle_response(result); return if performed?

    create_replace_message(@response)
    reset_bulk_change_cache
    redirect_to domains_path
  end

  def nameserver_change
    # ВРЕМЕННО: отправляем сырой CSV файл на новый эндпойнт для тестирования
    if bulk_actions_params[:batch_file].present?
      csv_content = Base64.decode64(bulk_actions_params[:batch_file])
      conn = ApiConnector::Domains::CsvNameserverBulk.new(**auth_info)
      result = conn.call_action(csv_content: csv_content)
      handle_response(result); return if performed?
      
      # Если дошли до этой точки, значит запрос прошел успешно
      # Показываем ответ от сервиса или стандартное сообщение
      if @response && @response.respond_to?(:message)
        flash.notice = @response.message
      else
        flash.notice = @message || "Nameserver bulk operation completed successfully"
      end
    else
      # Оригинальная логика для случаев без CSV
      conn = ApiConnector::BulkActions::NameserverChange.new(**auth_info)
      result = conn.call_action(payload: replace_nameserver_payload)
      handle_response(result); return if performed?

      create_nameserver_change_message(@response)
    end
    
    reset_bulk_change_cache
    redirect_to domains_path
  end

  def domain_renew
    conn = ApiConnector::BulkActions::DomainRenew.new(**auth_info)
    result = conn.call_action(payload: domain_renew_payload)

    handle_response(result); return if performed?

    reset_bulk_change_cache
    redirect_to domains_path
  end

  private

  def bulk_actions_params
    params.require(:bulk_change)
          .permit(:current_contact_id, :new_contact_id, :nameserver_id,
                  :domains, :renew_period, :new_hostname, :old_hostname,
                  :ipv4, :ipv6, :batch_file)
  end

  def replace_contact_payload
    {
      current_contact_id: bulk_actions_params[:current_contact_id],
      new_contact_id: bulk_actions_params[:new_contact_id],
    }
  end

  def replace_nameserver_payload
    {
      id: bulk_actions_params[:old_hostname],
      new_hostname: bulk_actions_params[:new_hostname],
      ipv4: bulk_actions_params[:ipv4].split("\n"),
      ipv6: bulk_actions_params[:ipv6].split("\n"),
      # ВРЕМЕННО ЗАКОММЕНТИРОВАНО ДЛЯ ТЕСТИРОВАНИЯ ПРЯМОЙ ОТПРАВКИ CSV
      # domains: parse_csv(bulk_actions_params[:batch_file]),
      domains: [], # Временная заглушка
    }
  end

  # ВРЕМЕННО ЗАКОММЕНТИРОВАНО ДЛЯ ТЕСТИРОВАНИЯ ПРЯМОЙ ОТПРАВКИ CSV
  # def parse_csv(params)
  #   return [] if params.blank?

  #   csv = CSV.parse(Base64.decode64(params), headers: true)
  #   domains = []
  #   csv.each do |row|
  #     domains << row['Domain']
  #   end
  #   domains
  # end

  def domain_renew_payload
    {
      domains: bulk_actions_params[:domains].split(','),
      renew_period: bulk_actions_params[:renew_period],
    }
  end

  def create_replace_message(response)
    message = @message
    message += ". #{t('bulk_actions.affected_domains')}: #{response.affected_domains.size}."
    message += " #{t('bulk_actions.skipped_domains')}: #{response.skipped_domains.size}"
    flash.notice = message
  end

  def create_nameserver_change_message(response)
    action_text = bulk_actions_params[:old_hostname].blank? ? t('bulk_actions.added') : t('bulk_actions.replaced')
    notices = ["#{action_text}. #{t('bulk_actions.affected_domains')}: " \
    "#{response.affected_domains.join(', ')}"]

    unless response.skipped_domains.empty?
      notices << "#{t('bulk_actions.skipped_domains')}: #{response.skipped_domains.join(', ')}"
    end
    flash.notice = notices.join(', ')
  end
end
