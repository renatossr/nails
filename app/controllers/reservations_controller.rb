class ReservationsController < ApplicationController
  def index
  	@reservations = Reservation.only_of_period(
      Date.today-5.days,
      Date.today+5.days
    ).with_default_ordering.grouped_by_half_hours
  	#@reservations_by_hour = @reservations.group("strftime('%H:%M', start_time)")
  end
end
