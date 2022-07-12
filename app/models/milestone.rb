# == Schema Information
#
# Table name: milestones
#
#  id            :bigint           not null, primary key
#  metric        :string
#  threshold     :decimal(, )
#  created_by_id :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class Milestone < ApplicationRecord
  belongs_to :created_by, class_name: 'User', foreign_key: 'created_by_id', optional: true
  has_and_belongs_to_many :users

  validates_presence_of :threshold, :metric
  
end
