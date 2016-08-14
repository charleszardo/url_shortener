class TagTopic < ActiveRecord::Base
  validates :topic, :presence => true

  has_many :taggings

  has_many :submitted_urls, :through => :taggings, :source => :shortened_url

  def self.most_popular_tags
    TagTopic
      .select("tag_topics.*")
      .joins("LEFT OUTER JOIN taggings ON taggings.tag_topic_id = tag_topics.id")
      .group("tag_topics.topic")
      .order("taggings.shortened_url_id DESC")
      .limit(5)
  end
end
