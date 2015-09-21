class Api::ThingsController < ApplicationController
  respond_to :json
  # operation document_formats: :json

  def show
    respond Thing::Show
  end

  def create
    # raise request.inspect
    puts "@@@@@ #{params.inspect}"
    # op = Thing::Create.(params)

    # render json: op.to_json, location: "/op", status: :created

    _params = params
    _params[:thing] = params
    respond Thing::Create, _params #, namespace: :api #, location: "/op/"
  end

  # TODO: Implement :namespace.
  def respond(operation_class, params=self.params, respond_options = {}, &block)
    res, op = operation!(operation_class, params) { operation_class.run(params) }
    respond_with :api, op, respond_options
  end
end