class ShortenedUrl < ActiveRecord::Base
  validates :short_url, :presence => true
  validates :short_url, :uniqueness => true
  validates :long_url, :presence => true
  validates :user_id, :presence => true

  def self.random_code
      loop do
        code = SecureRandom::urlsafe_base64
        return code if !self.exists?(:short_url => code)
      end
  end

  def self.create_for_user_and_long_url!(user, long_url)
    ShortenedUrl.create!(user_id: user.id, long_url: long_url, short_url: self.random_code)
  end
end
