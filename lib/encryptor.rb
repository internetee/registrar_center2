# lib/encryptor.rb
class Encryptor
  class << self
    def encrypt(value)
      encryptor.encrypt_and_sign(value)
    end

    def decrypt(value)
      encryptor.decrypt_and_verify(value)
    rescue ActiveSupport::MessageVerifier::InvalidSignature, ActiveSupport::MessageEncryptor::InvalidMessage
      nil
    end

    private

    def encryptor
      @encryptor ||= begin
        secret_key_base = Rails.application.secret_key_base
        key = ActiveSupport::KeyGenerator.new(secret_key_base).generate_key('', 32)
        ActiveSupport::MessageEncryptor.new(key)
      end
    end
  end
end
