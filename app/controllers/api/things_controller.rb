class Api::ThingsController < ApplicationController
  respond_to :json

  def show
    raise request.inspect
    respond Thing::Show
  end

  def create
    # raise request.inspect
    respond Thing::Create
  end
end