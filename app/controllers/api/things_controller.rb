class Api::ThingsController < ApplicationController
  respond_to :json

  def show
    respond Thing::Api::Show
  end

  def create
    # puts "@@@@@ #{params.inspect}"
    # op = Thing::Create.(params)

    # render json: op.to_json, location: "/op", status: :created
    respond Thing::Api::Create, namespace: [:api] #, location: "/op/"
  end
end