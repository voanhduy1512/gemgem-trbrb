class HomeController < ApplicationController
  def index
    present Thing::Index
  end
end
