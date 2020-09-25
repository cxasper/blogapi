class TokenGenerateService
  def self.generate
    SecureRandom.hex
  end
end
