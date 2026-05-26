# app/controllers/concerns/authentication.rb
module Authentication
  extend ActiveSupport::Concern

  included do
    helper_method :current_user, :logged_in?
  end

  def current_user
    @current_user ||= OpenStruct.new(auth_info) if auth_info
  end

  def logged_in?
    current_user != nil
  end

  def sign_out
    clear_auth_cache
    session[:uuid] = nil
  end

  def sign_in(uuid)
    session[:uuid] = uuid
    cookies.delete(:request_ip)
  end

  def store_auth_info(token:, request_ip:, data:)
    uuid = SecureRandom.uuid
    data = construct_auth_info(token, request_ip, data)
    encrypted_data = Encryptor.encrypt(data.to_json)
    Rails.cache.write(uuid, encrypted_data, expires_in: 18.hours)

    uuid
  end

  private

  def auth_info
    cached_data = Rails.cache.fetch(session[:uuid]) || ''
    decrypted_data = Encryptor.decrypt(cached_data)
    return unless decrypted_data

    JSON.parse(decrypted_data).symbolize_keys
  rescue JSON::ParserError => e
    logger.info(e)
    nil
  end

  def construct_auth_info(token, request_ip, data)
    {
      username: data[:username],
      registrar_name: data[:registrar_name],
      role: data[:roles].first,
      legaldoc_mandatory: data[:legaldoc_mandatory],
      address_processing: data[:address_processing],
      token: token,
      request_ip: request_ip,
      abilities: data[:abilities]
    }
  end

  # Auth session payload (uuid) and bulk-change wizard state (session.id) only.
  # Leaves stats (distribution_data, growth_rate_data) and Voog footer (voog_footer/links/*) intact.
  def clear_auth_cache
    auth_uuid = session[:uuid]
    Rails.cache.delete(auth_uuid) if auth_uuid.present?
    Rails.cache.delete(session.id)
  end
end
