# == Schema Information
#
# Table name: establishments
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  address    :string(255)
#  address_2  :string(255)
#  city       :string(255)
#  state      :string(255)
#  country    :string(255)
#  zip_code   :string(255)
#  lat        :string(255)
#  long       :string(255)
#  phone      :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Establishment < ActiveRecord::Base
  attr_accessible :address, :address_2, :city, :country, :lat, :long, :name, :phone, :state, :zip_code
  has_many :positions
end
