class BaseController < ApplicationController
  before_action :check_auth_info

  def check_auth_info
    return if auth_info_present?

    flash[:alert] = I18n.t(:session_expired)
    redirect_to login_url
  end

  def set_pagy_params
    if params[:per_page]&.to_i&.positive?
      session[:page_size] = params[:per_page].to_i
    else
      session[:page_size] ||= Pagy::DEFAULT[:items]
    end
    @page = params[:page] || 1
    @offset = session[:page_size] * (@page.to_i - 1)
  end

  private

  def auth_info_present?
    return false unless auth_info.is_a?(Hash)

    auth_info[:username]&.present? && auth_info[:token]&.present?
  end

  def search_params
    return unless params[:search]

    params[:search].merge!(s: params[:s]) if params[:s].present?
    modify_search_params(params[:search])
  end

  def modify_search_params(params)
    params.to_unsafe_h.each_with_object({}) do |(k, v), a|
      if k == 'invoice_status' && v.present?
        v.split('|').each do |vv|
          a[vv] = 1
        end
        next
      end

      a[k] = k.include?('_contains_array') && v.is_a?(Array) ? v.compact_blank.join(',') : v
    end.compact_blank
  end

  def transform_file_params(params)
    return if params.blank?

    { body: Base64.encode64(params.read),
      type: params.original_filename.split('.').last.downcase }
  end

  def pdf_or_csv_request?
    request.format.pdf? || request.format.csv?
  end
end
