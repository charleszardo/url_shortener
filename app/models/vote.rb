class Vote < ActiveRecord::Base
  validates :upvote, :shortened_url_id, :user_id, :presence => true
  validate :user_cannot_vote_own_url
  validate :limit_one_vote_per_url_per_user

  belongs_to :user

  belongs_to :shortened_url

  def self.create_or_update_by(shortened_url, user, upvote)
    vote = Vote.where(shortened_url_id: shortened_url.id, user_id: user.id).first
    if vote
      vote.upvote = upvote
      vote.save
    else
      Vote.create!(shortened_url_id: shortened_url.id, user_id: user.id, upvote: upvote)
    end
  end

  def user_cannot_vote_own_url
    if self.shortened_url.submitter_id == self.user_id
      errors[:base] << "you cannot vote for your own url"
    end
  end

  def limit_one_vote_per_url_per_user
    vote = Vote.where(user_id: self.user_id, shortened_url_id: self.shortened_url_id).first
    if vote && vote.upvote == self.upvote
      errors[:base] << "you can only vote once per url"
    end
  end
end
