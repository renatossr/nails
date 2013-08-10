class ReservationsController < ApplicationController
  def index
  	@reservations = Reservation.group("strftime('%H:%M', start_time)")
  	#@reservations_by_hour = @reservations.group("strftime('%H:%M', start_time)")
  end
end
