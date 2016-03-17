class AddIndexUsersMeetupsUidMid < ActiveRecord::Migration
  def change
    add_index :users_meetups, [:user_id, :meetup_id], unique: true
  end
end
