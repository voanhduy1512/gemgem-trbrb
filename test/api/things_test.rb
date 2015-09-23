require "test_helper"
require "rails/test_help"

class ApiThingsTest < MiniTest::Spec
  include Rack::Test::Methods

  def app
    Rails.application
  end

  it do
    id = Thing::Create.(thing: {name: "Rails"}).model.id
    get "/api/things/#{id}", "", "CONTENT_TYPE" => "application/json", "HTTP_ACCEPT"=>"application/json"
    last_response.body.must_equal %{{\"name\":\"Rails\",\"authors\":[],\"id\":#{id},\"links\":[{\"rel\":\"self\",\"href\":\"/api/things/#{id}\"}],\"comments\":[]}}
  end

  it "post" do
    data = {name: "Lotus"}
    # request.env["HTTP_ACCEPT"] = "application/json"
    post "/api/things/", data.to_json, "CONTENT_TYPE" => "application/json", "HTTP_ACCEPT"=>"application/json"
    id = Thing.last.id

    last_response.headers["Location"].must_equal "http://example.org/api/things/#{id}"
    assert last_response.created?
    last_response.body.must_equal %{{"name":"Lotus","authors":[],"id":#{id},"links":[{"rel":"self","href":"/api/things/#{id}"}]}}

    # assert_equal "http://example.org/redirected", last_request.url
    # assert last_response.ok?
  end

  it "post allows adding authors" do
    data = {name: "Lotus", authors: [{email: "fred@trb.org"}]}
    post "/api/things/", data.to_json, "CONTENT_TYPE" => "application/json", "HTTP_ACCEPT"=>"application/json"
    id = Thing.last.id

    last_response.headers["Location"].must_equal "http://example.org/api/things/#{id}"
    assert last_response.created?
    last_response.body.must_equal %{{"name":"Lotus","authors":[{"email"}],"id":#{id},"links":[{"rel":"self","href":"/api/things/#{id}"}]}}
  end
end