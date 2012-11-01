require 'openssl'
require 'base64'
require 'json'

class String
  # Quick method for signing strings with a key.
  def sign(private_key)
    digest = OpenSSL::Digest::SHA256.new
    private_key.sign(digest, self)
  end

  def clean_base64_encode
    Base64.urlsafe_encode64(self).gsub('=', '')
  end
end

class GoogleJWT
  attr_accessor :claim_set, :header, :private_key
  def initialize(claim_set, private_key, password, header = nil)
    # Symbolize the keys.
    self.claim_set = claim_set.inject({}){|item,(k,v)| item[k.to_sym] = v; item}

    # Remove unknown/invalid keys.
    self.claim_set = self.claim_set.delete_if {|k,v| ![:iss, :scope, :aud, :exp, :iat, :prn].include?(k)}

    # Make sure we have all the required keys.
    [:iss, :scope, :aud].each {|r| raise RuntimeError "Missing required claim key: #{r}" unless self.claim_set[r]}

    # Set defaults for create/expire time.
    self.claim_set[:exp] ||= Time.now.to_i + 3600
    self.claim_set[:iat] ||= Time.now.to_i

    # Make sure the header is clean and has required items.
    self.header ||= {:alg => "RS256", :typ => "JWT"}
    self.header = self.header.inject({}){|item,(k,v)| item[k.to_sym] = v; item}
    self.header = self.header.delete_if {|k,v| ![:alg, :typ].include?(k)}
    [:alg, :typ].each {|r| raise RuntimeError "Missing required header key: #{r}" unless self.header[r]}

    # Make sure we were passed the private key and password.
    raise RuntimeError "Missing required private key parameter." unless private_key
    raise RuntimeError "Missing required password parameter." unless password

    # Set the private key.
    self.private_key = key_from_pkcs12(private_key, password)
  end

  def jwt
    header = self.header.to_json.clean_base64_encode
    claim_set = self.claim_set.to_json.clean_base64_encode
    signature = "#{header}.#{claim_set}".sign(self.private_key).clean_base64_encode
    "#{header}.#{claim_set}.#{signature}"
  end

private
  def key_from_pkcs12(key, password)
    OpenSSL::PKey::RSA.new(OpenSSL::PKCS12.new(key, password).key)
  end
end
