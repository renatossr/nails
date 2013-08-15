class ReservationsController < ApplicationController
  def index
  	@reservations = Reservation.only_of_day(Date.today).status_different_than("Canceled").with_default_ordering
  end

  def show
    @reservation = Reservation.find(params[:id])
  end
end
