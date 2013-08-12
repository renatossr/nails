# == Schema Information
#
# Table name: reservations
#
#  id          :integer          not null, primary key
#  start_time  :datetime
#  end_time    :datetime
#  kind        :string(255)
#  description :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  status      :string(255)
#

class Reservation < ActiveRecord::Base
  attr_accessible :description, :start_time, :end_time, :kind

  validates :start_time, 	presence: true
  validates :end_time,		presence: true
  validates_inclusion_of :kind, :in => proc { Reservation.kinds_of_reservation }
  validate :cannot_have_conflicts, :if => :is_reservation_and_has_conflicts?

  before_save :cancel_reservations_in_my_range, :if => :is_unavailable_and_has_conflicts?

  scope :only_of_day, 				   ->(day) { where('start_time BETWEEN ? AND ?', day.beginning_of_day, day.end_of_day) }
  scope :only_of_period, 			   ->(start_day, end_day) { where('start_time BETWEEN ? AND ?', start_day.beginning_of_day, end_day.end_of_day) }
  scope :only_of_kind, 				   ->(kind) { where('kind = ?', kind) }
  scope :status_different_than,  ->(status) { where('status <> ?', status) }
  scope :conflicts_with, 			   ->(reservation) { Reservation.where('(start_time >= ? AND start_time <= ?) OR (end_time >= ? AND end_time <= ?)', reservation.start_time, reservation.end_time, reservation.start_time, reservation.end_time) }


  # Validation method for conflicts
  def cannot_have_conflicts
  	errors.add(:base, "Conflicts with another reservation") if self.has_conflicts?
  end

  # Check flag for NotAvailable
  def is_unavailable?
  	self.kind == "NotAvailable"
  end

  # Check flag for Reservation
  def is_reservation?
    self.kind == "Reservation"
  end

  # Checks for conflicts
  def has_conflicts?
  	self.conflicts.any?
  end

  # Check for unavailability and conflicts
  def is_unavailable_and_has_conflicts?
  	self.is_unavailable? && self.has_conflicts?
  end

  # Check for unavailability and conflicts
  def is_reservation_and_has_conflicts?
    self.is_reservation? && self.has_conflicts?
  end

  # Retrieve conflicting reservations
  def conflicts
	  Reservation.conflicts_with(self).only_of_kind('Reservation').status_different_than('Canceled')
  end

  # Cycle through reservations with conflict and cancels them
  def cancel_reservations_in_my_range
  	self.conflicts.each { |o| o.cancel }	
	end

	# Cancels reservations by changing status to 'Canceled'
	def cancel
		self.status = 'Canceled'
		self.save(validate: false)
	end

  def period_in_seconds
    (start_time.to_i..end_time.to_i)
  end

  class << self
    def kinds_of_reservation
      ["Reservation","NotAvailable"]
    end

    def grouped_by_half_hours
      all.group_by { |r| r.start_time.to_i/(30.minutes) }
    end

    def grouped_by_interval( range  )
      grouped = Hash.new {|h,k| h[k] = [] }
      all.each { |r| r.period_in_seconds.step( range  ) { |i| grouped[i/(range)] << r } }
      grouped
    end

    def with_default_ordering
      order(:start_time)
    end
  end

end
