class EstablishmentsController < ApplicationController

  def show
    @establishment = Establishment.find(params[:id])
    @positions = @establishment.positions
  end
end
