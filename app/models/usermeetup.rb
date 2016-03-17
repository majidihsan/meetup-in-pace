class UsersMeetup < ActiveRecord::Base
  belongs_to :meetup
  belongs_to :user
  validates_associated :user
  validates_associated :meetup
end
