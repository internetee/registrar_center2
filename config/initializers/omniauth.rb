OpenIDConnect.logger = Rails.logger
OpenIDConnect.debug!

OpenIDConnect.http_config do |config|
  config.proxy = Rails.configuration.customization.dig(:tara, :proxy)
end

OmniAuth.config.logger = Rails.logger
# Block GET requests to avoid exposing self to CVE-2015-9284
OmniAuth.config.allowed_request_methods = [:post]

signing_keys = Rails.configuration.customization.dig(:tara, :keys).to_json
issuer = Rails.configuration.customization.dig(:tara, :issuer)
host = Rails.configuration.customization.dig(:tara, :host)
port = Rails.configuration.customization.dig(:tara, :port)
authorization_endpoint = Rails.configuration.customization.dig(:tara, :authorization_endpoint)
token_endpoint = Rails.configuration.customization.dig(:tara, :token_endpoint)
jwks_uri = Rails.configuration.customization.dig(:tara, :jwks_uri)
identifier = Rails.configuration.customization.dig(:tara, :identifier)
secret = Rails.configuration.customization.dig(:tara, :secret)
redirect_uri = Rails.configuration.customization.dig(:tara, :redirect_uri)
scheme = Rails.configuration.customization.dig(:tara, :scheme)
scope = Rails.configuration.customization.dig(:tara, :scope)

Rails.application.config.middleware.use OmniAuth::Builder do
  provider 'tara', {
    name: 'tara',
    scope: scope,
    state: SecureRandom.hex(10),
    client_signing_alg: :RS256,
    client_jwk_signing_key: signing_keys,
    send_scope_to_token_endpoint: false,
    send_nonce: true,
    issuer: issuer,
    discovery: true,

    client_options: {
      scheme: scheme,
      host: host,
      port: port,
      authorization_endpoint: authorization_endpoint,
      token_endpoint: token_endpoint,
      userinfo_endpoint: nil, # Not implemented
      jwks_uri: jwks_uri,
      identifier: identifier,
      secret: secret,
      redirect_uri: redirect_uri,
    },
  }
end
