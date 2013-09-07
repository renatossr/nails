# == Schema Information
#
# Table name: positions
#
#  id               :integer          not null, primary key
#  name             :string(255)
#  function         :string(255)
#  establishment_id :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class Position < ActiveRecord::Base
  attr_accessible :establishment_id, :function, :name
  belongs_to :establishment
  has_many :reservations
end
