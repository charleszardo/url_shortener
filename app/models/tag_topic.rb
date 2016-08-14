class TagTopic < ActiveRecord::Base
  validates :topic, :presence => true

  has_many :taggings

  has_many :submitted_urls, :through => :taggings, :source => :shortened_url
end
