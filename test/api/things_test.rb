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
  def patch(uri, data)
    super(uri, data, "CONTENT_TYPE" => "application/json", "HTTP_ACCEPT"=>"application/json")
  end

  def get(uri)
    super(uri, nil, "CONTENT_TYPE" => "application/json", "HTTP_ACCEPT"=>"application/json")
  end

  describe "GET" do
    it do
      id = Thing::Create.(thing: {name: "Rails"}).model.id
      get "/api/things/#{id}"
      last_response.body.must_equal %{{"name":"Rails","_embedded":{"comments":[]},"_links":{"self":{"href":"/api/things/#{id}"}}}}
    end

    it "shows authors" do
      id = Thing::Create.(thing: {name: "Rails", users: [{email: "fred@trb.to"}]}).model.id
      get "/api/things/#{id}"
      last_response.body.must_equal %{{"name":"Rails","_embedded":{"comments":[]},"_links":{"self":{"href":"/api/things/#{id}"}}}}
    end
  end

  describe "POST" do
    it "post" do
      post "/api/things/", {name: "Lotus"}.to_json
      id = Thing.last.id

      last_response.headers["Location"].must_equal "http://example.org/api/things/#{id}"
      assert last_response.created?
      last_response.body.must_equal %{{"name":"Lotus","_links":{"self":{"href":"/api/things/#{id}"}}}}
    end

    it "post allows adding authors" do
      data = {name: "Lotus", authors: [{email: "fred@trb.org"}]}
      post "/api/things/", data.to_json

      id = Thing.last.id
      author_id = Thing.last.users.first.id

      last_response.headers["Location"].must_equal "http://example.org/api/things/#{id}"
      assert last_response.created?
      last_response.body.must_equal %{{"name":"Lotus","_embedded":{"authors":[{"email":"fred@trb.org","_links":{"self":{"href":"/api/users/#{author_id}"}}}]},"_links":{"self":{"href":"/api/things/#{id}"}}}}
    end
  end

  describe "PATCH" do
    it do
      thing = Thing::Create.(thing: {name: "Lotus", users: [{"email"=> "jacob@trb.org"}]}).model
      id = thing.id
      author_id = thing.users.first.id

      data = {authors: [{id: "#{author_id}", remove: "1"}], is_author: "0"}
      patch "/api/things/#{id}/", data.to_json

      get "/api/things/#{id}"
      last_response.body.must_equal %{{"name":"Lotus","_embedded":{"comments":[]},"_links":{"self":{"href":"/api/things/#{id}"}}}}
    end
  end

  describe "GET /things?with_comments=1" do
    it do
      jacobs_thing = Thing::Create.(thing: {name: "Lotus", users: [{"email"=> "jacob@trb.to"}]}).model
      dhhs_thing   = Thing::Create.(thing: {name: "Rails", users: [{"email"=> "dhh@trb.to"}]}).model
      robs_thing   = Thing::Create.(thing: {name: "TRB", users:   [{"email"=> "rob@trb.to"}]}).model

      get "/api/things"
       pp JSON[last_response.body]
      JSON[last_response.body].must_equal ({
        "_embedded"=>
          {"things"=>
            [{"name"=>"TRB",
              # "id"=>3,
              "_embedded"=>
               {"authors"=>
                 [{"email"=>"rob@trb.to",
                   # "id"=>3,
                   "_links"=>{"self"=>{"href"=>"/api/users/#{robs_thing.users[0].id}"}}}]},
              "_links"=>{"self"=>{"href"=>"/api/things/#{robs_thing.id}"}}},
             {"name"=>"Rails",
              # "id"=>2,
              "_embedded"=>
               {"authors"=>
                 [{"email"=>"dhh@trb.to",
                   # "id"=>2,
                   "_links"=>{"self"=>{"href"=>"/api/users/#{dhhs_thing.users[0].id}"}}}]},
              "_links"=>{"self"=>{"href"=>"/api/things/#{dhhs_thing.id}"}}},
             {"name"=>"Lotus",
              # "id"=>1,
              "_embedded"=>
               {"authors"=>
                 [{"email"=>"jacob@trb.to",
                   # "id"=>1,
                   "_links"=>{"self"=>{"href"=>"/api/users/#{jacobs_thing.users[0].id}"}}}]},
              "_links"=>{"self"=>{"href"=>"/api/things/#{jacobs_thing.id}"}}}]},
         "_links"=>{"self"=>{"href"=>"/things"}}})
    end
  end
end

# FIXME: representer(include: [:users, :comments]) to exclude image_meta_data etc.