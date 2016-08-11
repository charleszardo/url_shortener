class ShortenedUrl < ActiveRecord::Base
  validates :short_url, :long_url, :user_id :presence => true
  validates :short_url, :uniqueness => true

  belongs_to :submitter, :class_name => "User", :foreign_key => :user_id, :primary_key => :id

  def self.random_code
      loop do
        code = SecureRandom::urlsafe_base64(16)
        return code unless self.exists?(short_url: code)
      end
  end

  def self.create_for_user_and_long_url!(user, long_url)
    ShortenedUrl.create!(user_id: user.id, long_url: long_url, short_url: self.random_code)
  end
end
