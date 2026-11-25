OpenIDConnect.logger = Rails.logger
OpenIDConnect.debug!

OpenIDConnect.http_config do |config|
  config.proxy = Rails.configuration.customization.dig(:oidc, :proxy)
end

OmniAuth.config.logger = Rails.logger
# Block GET requests to avoid exposing self to CVE-2015-9284
OmniAuth.config.allowed_request_methods = [:post]

OmniAuth.config.failure_raise_out_environments = []

signing_keys = Rails.configuration.customization.dig(:oidc, :keys).to_json
issuer = Rails.configuration.customization.dig(:oidc, :issuer)
host = Rails.configuration.customization.dig(:oidc, :host)
port = Rails.configuration.customization.dig(:oidc, :port)
authorization_endpoint = Rails.configuration.customization.dig(:oidc, :authorization_endpoint)
token_endpoint = Rails.configuration.customization.dig(:oidc, :token_endpoint)
jwks_uri = Rails.configuration.customization.dig(:oidc, :jwks_uri)
identifier = Rails.configuration.customization.dig(:oidc, :identifier)
secret = Rails.configuration.customization.dig(:oidc, :secret)
redirect_uri = Rails.configuration.customization.dig(:oidc, :redirect_uri)
scheme = Rails.configuration.customization.dig(:oidc, :scheme)
scope = Rails.configuration.customization.dig(:oidc, :scope)
discovery = Rails.configuration.customization.dig(:oidc, :discovery)

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :openid_connect, {
    name: :oidc,
    scope: scope,
    state: SecureRandom.hex(10),
    client_signing_alg: :RS256,
    client_jwk_signing_key: signing_keys,
    send_scope_to_token_endpoint: false,
    send_nonce: true,
    issuer: issuer,
    discovery: discovery,

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
