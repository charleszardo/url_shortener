class ShortenedUrl < ActiveRecord::Base
  validates :short_url, :presence => true
  validates :short_url, :uniqueness => true
  validates :long_url, :presence => true
  validates :user_id, :presence => true
end
