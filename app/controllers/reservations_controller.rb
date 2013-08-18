class ReservationsController < ApplicationController
  def index
  	@reservations = Reservation.only_of_day(Date.today).not_canceled.with_default_ordering
    @occupied = Reservation.only_of_day(Date.today).not_canceled.with_default_ordering.occupied
  end

  def show
    @reservation = Reservation.find(params[:id])
  end
end
