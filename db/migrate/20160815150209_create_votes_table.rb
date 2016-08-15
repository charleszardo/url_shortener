class CreateVotesTable < ActiveRecord::Migration
  def change
    create_table :votes do |t|
      t.boolean :upvote, :null => false
      t.integer :user_id, :null => false
      t.integer :shortened_url_id, :null => false

      t.timestamps
    end

    add_index :votes, :user_id
    add_index :votes, :shortened_url_id
  end
end
