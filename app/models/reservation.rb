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
#  conflict_id :integer
#

class Reservation < ActiveRecord::Base
  attr_accessible :description, :start_time, :end_time, :type_flag

  validates :start_time, 	presence: true
  validates :end_time,		presence: true
  validates_inclusion_of :type_flag, :in => ["Reserved", "Unavailable"]

  scope :only_of_date, ->(day) { where('start_time BETWEEN ? AND ?', day.beginning_of_day, day.end_of_day) }
  scope :only_of_type, ->(type) { where('type_flag = ?', type) }


  # Checks for conflicts with other reservations.
  def conflicts?
	  Reservation.where('id <> ? AND ((start_time <= ? AND end_time >= ?) OR (start_time <= ? AND end_time >= ?))', self.id, self.start_time, self.start_time, self.end_time, self.end_time).count > 0
  end


  # Flags reservations with conflicting times for future notification.
  def flag_conflicted
		if self.type_flag = "Unavailable"
			if self.conflicts?
				conflicts = Reservation.where('id <> ? AND ((start_time <= ? AND end_time >= ?) OR (start_time <= ? AND end_time >= ?))', self.id, self.start_time, self.start_time, self.end_time, self.end_time)
				conflicts.each do |conf|
					set_conflict_id(conf, self.id)
				end
			end
		end
  end

	private

	  # Flags conflict.
	  def set_conflict_id(reservation_to_be_flageed, id)
	  	reservation_to_be_flageed.conflict_id = id
			reservation_to_be_flageed.save
	  end

end
