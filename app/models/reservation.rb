# == Schema Information
#
# Table name: reservations
#
#  id          :integer          not null, primary key
#  start_time  :datetime
#  end_time    :datetime
#  type_flag   :string(255)
#  description :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  status      :string(255)
#

class Reservation < ActiveRecord::Base
  attr_accessible :description, :start_time, :end_time, :type_flag

  validates :start_time, 	presence: true
  validates :end_time,		presence: true
  validates_inclusion_of :type_flag, :in => ["Reservation", "NotAvailable"]

  after_save :cancel_reservations_in_unavailable_time

  scope :only_of_date, ->(day) { where('start_time BETWEEN ? AND ?', day.beginning_of_day, day.end_of_day) }
  scope :only_of_type, ->(type) { where('type_flag = ?', type) }


  # Checks for conflicts with other reservations.
  def has_conflicts?
	  Reservation.where('id <> ? AND ((start_time <= ? AND end_time >= ?) OR (start_time <= ? AND end_time >= ?))', self.id, self.start_time, self.start_time, self.end_time, self.end_time).any?
  end

  # Cycles through reservations with conflict and cancels them
  def cancel_reservations_in_unavailable_time
  	if self.type_flag == "NotAvailable"
  		Reservation.conflicts( self ).each { |o| o.cancel }	
  	end
	end

	# Retrieves conflicted reservations given a reservation passed as argument
	def Reservation::conflicts(reservation)
		Reservation.where('id <> ? AND ((start_time <= ? AND end_time >= ?) OR (start_time <= ? AND end_time >= ?))', reservation.id, reservation.start_time, reservation.start_time, reservation.end_time, reservation.end_time)
	end

	# Cancels reservations by changing status to 'Canceled'
	def cancel
		self.status = 'Canceled'
		self.save
	end

	private

end
