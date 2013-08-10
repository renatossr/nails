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
  validate :cannot_have_conflicts, on: :create

  after_save :cancel_reservations_in_my_range, :if => :is_unavailable_and_has_conflicts?

  scope :only_of_day, 				->(day) { where('start_time BETWEEN ? AND ?', day.beginning_of_day, day.end_of_day) }
  scope :only_of_period, 			->(start_day, end_day) { where('start_time BETWEEN ? AND ?', start_day.beginning_of_day, end_day.end_of_day) }
  scope :only_of_type, 				->(type) { where('type_flag = ?', type) }
  scope :conflicts_with, 			->(reservation) { Reservation.where('id <> ? AND ((start_time <= ? AND end_time >= ?) OR (start_time <= ? AND end_time >= ?))', reservation.id, reservation.start_time, reservation.start_time, reservation.end_time, reservation.end_time) }

  # Validation method for conflicts
  def cannot_have_conflicts
  	errors.add(:base, "Conflicts with another reservation") if self.has_conflicts?
  end

  # Check flag for NotAvailable
  def is_unavailable?
  	self.type_flag == "NotAvailable"
  end

  # Checks for conflicts
  def has_conflicts?
  	self.conflicts.any?
  end

  # Check for unavailability and conflicts
  def is_unavailable_and_has_conflicts?
  	self.is_unavailable? && self.has_conflicts?
  end

  # Retrieve conflicting reservations
  def conflicts
	  Reservation.conflicts_with(self)
  end

  # Cycle through reservations with conflict and cancels them
  def cancel_reservations_in_my_range
  	self.conflicts.each { |o| o.cancel }	
	end

	# Cancels reservations by changing status to 'Canceled'
	def cancel
		self.status = 'Canceled'
		self.save
	end

end
