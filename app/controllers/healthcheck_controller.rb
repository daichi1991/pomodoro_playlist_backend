class HealthcheckController < ApplicationController
  def index
    render json: { status: 'OK' }
  end
end
