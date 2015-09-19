require "test_helper"
require "rails/test_help"

class ApiThingsTest < MiniTest::Spec
  include Rack::Test::Methods

  def app
    Rails.application
  end

  it do
    thing = Thing::Create.(thing: {name: "Rails"}).model
    get "/things/#{thing.id}", format: :json
    last_response.body.must_equal %{{"id":#{thing.id},"name":"Rails","links":[{"rel":"self","href":"/things/1"}],"authors":[],"comments":[]}}
  end
end