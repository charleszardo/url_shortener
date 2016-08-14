class AddCustomColumnToShortenedUrl < ActiveRecord::Migration
  def change
    add_column :shortened_urls, :custom, :boolean, :default => false
  end
end
