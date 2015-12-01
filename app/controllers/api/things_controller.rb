class Api::ThingsController < ApplicationController
  respond_to :json

  def index
    respond Thing::Api::Index, is_document: false
  end

  def show
    respond Thing::Api::Show
  end

  def create
    # puts "@@@@@ #{params.inspect}"
    # op = Thing::Create.(params)

    # render json: op.to_json, location: "/op", status: :created
    respond Thing::Api::Create, namespace: [:api] #, location: "/op/"
  end

  def update
    if request.authorization
      email, password = ActionController::HttpAuthentication::Basic.user_name_and_password(request)

      Session::SignIn.run(session: { email: email, password: password }) do |op|
        # look how we do _not_ use any global variables for authentication!!!!!!! *win*
        params[:current_user] = op.model
      end
    end

    respond Thing::Api::Update, namespace: [:api], is_document: true
  end
end