require "test_helper"
require "rails/test_help"

class ApiThingsTest < MiniTest::Spec
  include Rack::Test::Methods

  def app
    Rails.application
  end

  it do
    thing = Thing::Create.(thing: {name: "Rails"}).model
    get "/api/things/#{thing.id}", "CONTENT_TYPE" => "application/json"
    last_response.body.must_equal %{{"id":#{thing.id},"name":"Rails","links":[{"rel":"self","href":"/things/#{thing.id}"}],"authors":[],"comments":[]}}
  end

  it "post" do
    data = {name: "Lotus"}
    # request.env["HTTP_ACCEPT"] = "application/json"
    post "/api/things/", data.to_json, "CONTENT_TYPE" => "application/json", "HTTP_ACCEPT"=>"application/json"

    last_response.headers["Location"].must_equal "http://example.org/api/things/1"
    assert last_response.created?
    last_response.body.must_equal %{{"name":"Lotus","users":[],"id":1,"links":[{"rel":"self","href":"/api/things/1"}]}}

    # assert_equal "http://example.org/redirected", last_request.url
    # assert last_response.ok?
  end
end