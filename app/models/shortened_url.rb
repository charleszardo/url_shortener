class ShortenedUrl < ActiveRecord::Base
  validates :short_url, :long_url, :submitter, :presence => true
  validates :short_url, :uniqueness => true, :length => { :maximum => 255, :message => "Must be less than 255 characters"}
  validates :long_url, :length => { :maximum => 255, :message => "Must be less than 255 characters"}
  validate :no_more_than_five_urls_within_a_minute_from_single_user
  validate :limit_five_urls_per_user, :custom_url_must_be_made_by_premium_user, :unless => :premium_user?

  belongs_to :submitter, :class_name => "User"

  has_many(
    :visits,
    :class_name => "Visit",
    :foreign_key => :shortened_url_id,
    :primary_key => :id
  )

  has_many(
    :visitors,
    -> { distinct },
    :through => :visits,
    :source => :visitor
  )

  has_many :taggings

  has_many :tag_topics, :through => :taggings, :source => :tag_topic

  has_many :votes

  def self.random_code
      loop do
        code = SecureRandom::urlsafe_base64(16)
        return code unless ShortenedUrl.exists?(short_url: code)
      end
  end

  def self.random_dict_code
    dict = {}
    File.open("#{Rails.public_path}/dictionary.txt") do |f|
      f.each_line do |line|
        dict[line.chomp] = true;
      end
    end

    loop do
      code = dict.keys.sample(2).join("_")
      return code unless ShortenedUrl.exists?(short_url: code)
    end
  end

  def self.create_for_user_and_long_url!(user, long_url)
    ShortenedUrl.create!(submitter_id: user.id, long_url: long_url, short_url: ShortenedUrl.random_dict_code)
  end

  def self.create_custom_url_for_user_and_long_url!(user, long_url, custom_url)
    ShortenedUrl.create!(submitter_id: user.id, long_url: long_url, short_url: custom_url, custom: true)
  end

  def self.unique_shortened_url?(url)
    ShortenedUrl.find_by(short_url: url).nil?
  end

  def self.prune
    ShortenedUrl
      .select("visits.*")
      .joins("LEFT OUTER JOIN visits ON visits.shortened_url_id = shortened_urls.id")
      .where("visits.created_at IS NOT null")
      .order("visits.created_at")
      .group("shortened_urls.id")
  end

  def self.top
    top_urls = ShortenedUrl
      .select("shortened_urls.*, COUNT(votes.id) AS vote_count")
      .joins("LEFT OUTER JOIN votes ON votes.shortened_url_id = shortened_urls.id")
      .group("shortened_urls.id")
      .order("vote_count DESC")
      .limit("3")

      top_urls.map do |url|
        { url_obj: url, vote_count: url.vote_count}
      end
  end

  def self.hot
    hot_urls = ShortenedUrl
      .select("shortened_urls.*, COUNT(votes.id) AS vote_count")
      .joins("LEFT OUTER JOIN votes ON votes.shortened_url_id = shortened_urls.id")
      .where("votes.created_at > ?", 30.minutes.ago)
      .group("shortened_urls.id")
      .order("vote_count DESC")
      .limit("3")

      hot_urls.map do |url|
        { url_obj: url, vote_count: url.vote_count}
      end
  end

  def num_clicks
    visits.count
  end

  def num_uniques
    visitors.count
  end

  def num_recent_uniques
    visits
      .select("user_id")
      .where("created_at > ?", 10.minutes.ago)
      .distinct
      .count
  end

  private
  def no_more_than_five_urls_within_a_minute_from_single_user
    count = ShortenedUrl
      .select("*")
      .where("created_at > ?", 1.minutes.ago)
      .where("submitter_id = ?", submitter_id)
      .count

    if count >= 5
      errors[:base] << "can't submit more than five urls within one minute"
    end
  end

  def custom_url_must_be_made_by_premium_user
    if self.custom
      errors[:base] << "non-premium users cannot make custom shortened urls"
    end
  end

  def limit_five_urls_per_user
    count = ShortenedUrl
      .select("*")
      .where("submitter_id = ?", submitter_id)
      .count

    if count >= 5
      errors[:base] << "non-premium users can only submit five urls"
    end
  end

  def premium_user?
    submitter.premium
  end
end
