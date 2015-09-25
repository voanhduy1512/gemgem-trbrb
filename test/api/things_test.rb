require "test_helper"
require "rails/test_help"

class ApiThingsTest < MiniTest::Spec
  include Rack::Test::Methods

  def app
    Rails.application
  end

  def post(uri, data)
    super(uri, data, "CONTENT_TYPE" => "application/json", "HTTP_ACCEPT"=>"application/json")
  end

  def get(uri)
    super(uri, nil, "CONTENT_TYPE" => "application/json", "HTTP_ACCEPT"=>"application/json")
  end

  it do
    id = Thing::Create.(thing: {name: "Rails"}).model.id
    get "/api/things/#{id}"
    last_response.body.must_equal %{{"name":"Rails","authors":[],"id":#{id},"comments":[],"_links":{"self":{"href":"/api/things/#{id}"}}}}
  end

  it "post" do
    post "/api/things/", {name: "Lotus"}.to_json
    id = Thing.last.id

    last_response.headers["Location"].must_equal "http://example.org/api/things/#{id}"
    assert last_response.created?
    last_response.body.must_equal %{{\"name\":\"Lotus\",\"authors\":[],\"id\":#{id},\"_links\":{\"self\":{\"href\":\"/api/things/#{id}\"}}}}
  end

  it "post allows adding authors" do
    data = {name: "Lotus", authors: [{email: "fred@trb.org"}]}
    post "/api/things/", data.to_json

    id = Thing.last.id
    author_id = Thing.last.users.first.id

    last_response.headers["Location"].must_equal "http://example.org/api/things/#{id}"
    assert last_response.created?
    last_response.body.must_equal %{{"name":"Lotus","authors":[{"email":"fred@trb.org","id":#{author_id},"_links":{"self":{"href":"/api/users/#{author_id}"}}}],"id":#{id},"_links":{"self":{"href":"/api/things/#{id}"}}}}
  end
end