class ReservationsController < ApplicationController
  def index
  	@reservations = Reservation.only_of_day(Date.today).not_canceled.with_default_ordering
    @occupied = Reservation.only_of_day(Date.today).not_canceled.with_default_ordering.occupied
  end

  def show
    @reservation = Reservation.find(params[:id])
  end

  def get_day
    date = Date.parse(params[:date])
    @occupied = Reservation.only_of_day(date).not_canceled.with_default_ordering
  end

  def new
    @reservation = Reservation.new
  end

  def create
    @reservation = Reservation.new(params[:reservation])
    @reservation.kind = 'Reservation' # Not final implementation
    if @reservation.save
      render 'index'
    else
      render 'new'
    end
  end
end
