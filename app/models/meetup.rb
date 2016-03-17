class Meetup < ActiveRecord::Base
  has_many :users_meetups
  has_many :users, through: :users_meetups
  belongs_to :creator, :class_name => 'User', :foreign_key => 'user_id'
  validates :name, presence: true
  validates :description, length: { maximum: 500 }, presence: true
  validates :location, presence: true
  validates :name, uniqueness: true
end
