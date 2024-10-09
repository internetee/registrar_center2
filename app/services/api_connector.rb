# frozen_string_literal: true

class ApiConnector
  require 'faraday'
  require 'faraday/net_http'
  Faraday.default_adapter = :net_http

  attr_reader :auth_token, :request_ip

  def initialize(username:, password: nil, token: nil, **other_options)
    @auth_token = token || generate_token(username: username, password: password)
    @request_ip = other_options[:request_ip]
    @requester = other_options[:requester]
    @user_cert = other_options[:user_cert]
    @user_cert_cn = other_options[:user_cert_cn]
  end

  def self.call(**args)
    new(**args).call_action
  end

  def call_action(**args)
    Rails.logger.debug("Calling action: #{self.class::ACTION} with args: #{args}")
    __send__(self.class::ACTION, **args)
  end

  private

  def request(url:, method:, params: nil, headers: nil)
    Rails.logger.debug("Sending #{method} request to #{url} with params: #{params} and headers: #{headers}")
    request = faraday_request(url: url, headers: headers)
    response = send_request(request, method, url, params)
    success = [200, 201].include?(response.status)
    body = process_response_body(response)

    OpenStruct.new(body: body, success: success, type: response['content-type'])
  rescue Faraday::Error => e
    OpenStruct.new(body: { code: 503, message: e.message, data: {} }, success: false)
  end

  def send_request(request, method, url, params)
    if %w[get].include?(method)
      request.send(method, url, params)
    else
      send_non_get_request(request, method, params)
    end
  end

  def send_non_get_request(request, method, params)
    request.send(method) do |req|
      req.headers['Content-Type'] = 'application/json'
      req.body = params.to_json
    end
  end

  def process_response_body(response)
    Rails.logger.debug("Processing response with content type: #{response['content-type']} and body: #{response.body}")
    case response['content-type']
    when 'application/pdf', 'application/octet-stream'
      { data: response.body, message: response.headers['content-disposition'] }
    when %r{application/json}
      JSON.parse(response.body).with_indifferent_access
    else
      raise Faraday::Error, 'Unsupported content type'
    end
  end

  def generate_token(username:, password:)
    Base64.urlsafe_encode64("#{username}:#{password}")
  end

  def base_url
    "#{ENV['REPP_HOST']}#{ENV['REPP_ENDPOINT']}"
  end

  def faraday_request(url:, headers: {})
    Faraday.new(
      url: url,
      headers: headers.present? ? base_headers.merge!(headers) : base_headers,
      ssl: ca_auth_params
    )
  end

  def ca_auth_params
    return if Rails.env.test?

    client_cert = File.read(ENV['cert_path'])
    client_key = File.read(ENV['key_path'])
    {
      client_cert: OpenSSL::X509::Certificate.new(client_cert),
      client_key: OpenSSL::PKey::RSA.new(client_key),
    }
  end

  def base_headers
    headers = {
      'Authorization' => "Basic #{@auth_token}",
    }
    headers.merge!({ 'Request-IP' => @request_ip }) if @request_ip
    headers.merge!({ 'Requester' => @requester }) if @requester
    headers.merge!({ 'User-Certificate' => @user_cert }) if @user_cert
    headers.merge!({ 'User-Certificate-CN' => @user_cert_cn }) if @user_cert_cn
    headers
  end

  def endpoint_url
    base_url + self.class::ENDPOINT[:endpoint]
  end

  def method
    self.class::ENDPOINT[:method]
  end

  def url_with_id(id)
    "#{endpoint_url}/#{id}"
  end
end
