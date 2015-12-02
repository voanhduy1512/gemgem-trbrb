require "test_helper"

class ApiV1CommentsTest < MiniTest::Spec
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

  describe "GET /comments/1" do
    let (:thing) { Thing::Create.(thing: {name: "Rails"}).model }
    let (:comment) do
      Comment::Create.(
        id:      thing.id,
        comment: {
          body: "Love it!", weight: "1", user: { email: "fred@trb.to" } }
      ).model
    end

    it "renders" do
      get "/api/v1/comments/#{comment.id}"

      last_response.body.must_equal(
        {
          body:   "Love it!",
          _embedded: {
            user: {
              email:  "fred@trb.to",
              _links: { self: { href: "/api/v1/users/#{comment.user.id}" } }
            }
            },
          _links: { self: { href: "/api/v1/comments/#{comment.id}" } }
        }.to_json
      )
    end
  end

  describe "POST /api/v1/things/1/comments" do
    let (:thing) { Thing::Create.(thing: {name: "Rails"}).model }
    let (:json)  { { body: "Love it!", weight: "1", user: { email: "fred@trb.to" } }.to_json }

    it do
      post "/api/v1/things/#{thing.id}/comments", json

      comment = thing.comments[0]

      last_response.status.must_equal 201
      last_response.headers["Location"].must_equal "http://example.org/api/v1/comments/#{comment.id}"

      get "/api/v1/comments/#{comment.id}"

      last_response.body.must_equal(
        {

        }
      )
    end
  end
end