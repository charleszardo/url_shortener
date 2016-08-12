class Visit < ActiveRecord::Base
  validates :visitor, :shortened_url, :presence => true

  belongs_to :visitor, :class_name => "User"

  belongs_to :shortened_url

  def self.record_visit!(user, shortened_url)
    Visit.create(:visitor_id => user.id, :shortened_url_id => shortened_url.id)
  end
end
