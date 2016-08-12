class ShortenedUrl < ActiveRecord::Base
  validates :short_url, :long_url, :user_id, :presence => true
  validates :short_url, :uniqueness => true

  belongs_to :submitter, :class_name => "User", :foreign_key => :user_id, :primary_key => :id

  has_many :visits,
    :class_name => "Visit",
    :foreign_key => :shortened_url_id,
    :primary_key => :id

  has_many(
    :visitors,
    # -> { distinct },
    through: :visits,
    source: :visitor
  )

  def self.random_code
      loop do
        code = SecureRandom::urlsafe_base64(16)
        return code unless ShortenedUrl.exists?(short_url: code)
      end
  end

  def self.create_for_user_and_long_url!(user, long_url)
    ShortenedUrl.create!(user_id: user.id, long_url: long_url, short_url: ShortenedUrl.random_code)
  end

  def num_clicks
    visits.count
  end

  def num_uniques
    visits
      .select("user_id")
      .distinct
      .count
  end

  def num_recent_uniques
    visits
      .select("user_id")
      .where("created_at > ?", 10.minutes.ago)
      .distinct
      .count
  end
end
