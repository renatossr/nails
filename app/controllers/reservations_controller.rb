class ReservationsController < ApplicationController
  def index
  	@reservations = Reservation.only_of_day(Date.today).not_canceled.with_default_ordering
    @occupied = Reservation.not_canceled.with_default_ordering.merged
    respond_to do |format|
      format.html
      format.json
    end
  end

  def show
    @reservation = Reservation.find(params[:id])
    respond_to do |format|
      format.html
      format.json
    end
  end

  def get_day
    date = params[:date]
    @reservations = Reservation.only_of_day(Date.parse(date)).not_canceled.with_default_ordering
    respond_to do |format|
      format.json      
    end
  end

  def new
    @reservation = Reservation.new
  end

  def create
    @reservation = Reservation.new(params[:reservation])
    @reservation.kind = 'Reservation' # Not final implementation
    if @reservation.save
      render json: @reservation
    else
      render json: { errors: @reservation.errors.full_messages }, status: :unprocessable_entity
    end
  end
end
