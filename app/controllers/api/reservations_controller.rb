module Api
  class ReservationsController < ApplicationController

  respond_to :json

  def index
    @reservations = Reservation.all
    respond_with @reservations
  end

  def show
    @reservation = Reservation.find(params[:id])
    respond_with @reservation
  end

  def get_day
    date = params[:date]
    @reservations = Reservation.only_of_day(Date.parse(date)).not_canceled.with_default_ordering
    respond_with @reservations
  end

  def create
    @reservation = Reservation.new(params[:reservation])
    if @reservation.save
      respond_with @reservation
    else
      render json: @reservation.errors.full_messages, status: :unprocessable_entity
    end
  end
end
end