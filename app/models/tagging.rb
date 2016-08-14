class Tagging < ActiveRecord::Base\
  validates :shortened_url_id, :tag_topic_id, :presence => true

  belongs_to :shortened_url

  belongs_to :tag_topic
end
