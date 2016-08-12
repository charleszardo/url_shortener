class ChangeColumnNames < ActiveRecord::Migration
  def change
    rename_column :shortened_urls, :user_id, :submitter_id
    rename_column :visits, :user_id, :visitor_id
  end
end
