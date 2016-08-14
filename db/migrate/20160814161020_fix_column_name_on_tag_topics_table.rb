class FixColumnNameOnTagTopicsTable < ActiveRecord::Migration
  def change
    rename_column :taggings, :submitted_url_id, :shortened_url_id
  end
end
