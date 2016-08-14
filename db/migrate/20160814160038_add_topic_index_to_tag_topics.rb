class AddTopicIndexToTagTopics < ActiveRecord::Migration
  def change
    add_index :tag_topics, :topic
  end
end
