class Vote < ActiveRecord::Base
  validates :upvote, :shortened_url_id, :user_id, :presence => true

  belongs_to :user

  belongs_to :shortened_url
end
