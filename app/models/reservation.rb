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
  
  # --------------------------- Constants ----------------------------------
  RESERVATION_PIXEL_SIZE = 25
  DAY_LABEL_PIXEL_SIZE = 110


  attr_accessible :description, :start_time, :end_time, :kind, :status


  # --------------------------- Validations ----------------------------------
  validates :start_time, 	presence: true
  validates :end_time,		presence: true
  validates_inclusion_of :kind, :in => proc { Reservation.kinds_of_reservation }
  validate :cannot_have_conflicts, :if => :is_reservation?


  # --------------------------- Callbacks ----------------------------------
  before_save :cancel_reservations_in_my_range, :if => :is_unavailable_and_has_conflicts?


  # --------------------------- Scopes ----------------------------------
  scope :only_of_day,             ->(day) { where('start_time BETWEEN ? AND ?', day.beginning_of_day, day.end_of_day) }
  scope :only_of_period,          ->(start_day, end_day) { where('start_time BETWEEN ? AND ?', start_day.beginning_of_day, end_day.end_of_day) }
  scope :only_of_kind,            ->(kind) { where('kind = ?', kind) }
  scope :status_different_than,   ->(status) { where("status <> ? OR status = ''", status) }
  scope :not_canceled,            ->() { self.status_different_than('Canceled') }
  scope :conflicts_with,          ->(reservation) { Reservation.where('(start_time > ? AND start_time < ?) OR (end_time > ? AND end_time < ?)', reservation.start_time, reservation.end_time, reservation.start_time, reservation.end_time) }


  # --------------------------- Methods ----------------------------------

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
	  Reservation.conflicts_with(self).only_of_kind('Reservation').not_canceled
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

  # Retrieves the ragnge of seconds in a reservation
  def period_in_seconds
    (start_time.to_i..end_time.to_i)
  end

  # Determines de duration in seconds
  def duration
    self.end_time - self.start_time
  end

  class << self

    # Returns the available kinds of reservation
    def kinds_of_reservation
      ["Reservation","NotAvailable"]
    end

    # Groups the reservations by interval - One reservation fills all the intervals between start and end time.
    def grouped_by_interval( range )
      grouped = Hash.new {|h,k| h[k] = [] }
      all.each { |r| r.period_in_seconds.step( range ) { |i| grouped[i/(range)] << r } }
      grouped
    end

    # Merge event times
    def merged
      merged = []
      all.each do |r|
        # Push reservation into array every time that the start_time of record is larger than reservation's start_time
        if merged.empty? || ( r.start_time.to_i > merged.last.end_time.to_i )
          merged << Reservation.new
          merged.last.start_time = r.start_time # Reservation start_time only set at the beginning of each group
          merged.last.kind = r.kind
        end
        merged.last.end_time = r.end_time if (r.end_time.to_i > merged.last.end_time.to_i) # Reservation end_time set at the beginning of each group or if end_time of record is larger than reservation's end_time
      end
      merged
    end

    # Returns the default ordering
    def with_default_ordering
      order(:start_time)
    end

    # Calculates starting position of graphical representation in the browser
    def web_horizontal_position (r)
      s = r.start_time
      DAY_LABEL_PIXEL_SIZE + ( (s - (s.beginning_of_day+7.hours) ) / (0.5.hours) ) * RESERVATION_PIXEL_SIZE
    end

    # Calculates size of graphical representation in the browser
    def web_size (r)
      d = r.duration
      RESERVATION_PIXEL_SIZE * d / (0.5.hours)
    end

  end

end
