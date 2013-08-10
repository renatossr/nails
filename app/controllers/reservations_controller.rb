class ReservationsController < ApplicationController
  def index
  	@reservations = Reservation.only_of_period(
      Date.today-5.days,
      Date.today+5.days
    ).with_default_ordering.grouped_by_half_hours
  end

  def show
    @reservation = Reservation.find(params[:id])
  end
end
