class User < ApplicationRecord
  has_many :posts

  validates :name, presence: :true
  validates :email, presence: :true
  validates :auth_token, presence: :true

  after_initialize :generate_auth_token

  def generate_auth_token
    unless auth_token.present?
      self.auth_token = TokenGenerateService.generate
    end
  end
end
