require 'test_helper'

class ThingsControllerTest < IntegrationTest
  let (:thing) do
    thing = Thing::Create.(thing: {name: "Rails"}).model

    Comment::Create.(comment: {body: "Excellent", weight: "0", user: {email: "zavan@trb.org"}}, id: thing.id)
    Comment::Create.(comment: {body: "!Well.", weight: "1", user: {email: "jonny@trb.org"}}, id: thing.id)
    Comment::Create.(comment: {body: "Cool stuff!", weight: "0", user: {email: "chris@trb.org"}}, id: thing.id)
    Comment::Create.(comment: {body: "Improving.", weight: "1", user: {email: "hilz@trb.org"}}, id: thing.id)

    thing
  end

  # FIXME: make that via thing(users: []).
  let (:thing_with_fred) do
    thing = Thing::Create.(thing: {name: "Rails", users: [{"email" => "fred@trb.org"}]}).model

    Comment::Create.(comment: {body: "Excellent", weight: "0", user: {email: "zavan@trb.org"}}, id: thing.id)
    Comment::Create.(comment: {body: "!Well.", weight: "1", user: {email: "jonny@trb.org"}}, id: thing.id)
    Comment::Create.(comment: {body: "Cool stuff!", weight: "0", user: {email: "chris@trb.org"}}, id: thing.id)
    Comment::Create.(comment: {body: "Improving.", weight: "1", user: {email: "hilz@trb.org"}}, id: thing.id)

    thing
  end

  # controller tests are what i normally do manually, per "concept"
  # see above: workflow for login, create thing, update thing, check markup, that's it.


  describe "#edit" do
    # not signed-in.
    it "doesn't work with not signed-in" do
      thing = Thing::Create[thing: {"name" => "Rails", "users" => [{"email" => "joe@trb.org"}]}].model

      visit "/things/#{thing.id}/edit"
      page.current_path.must_equal "/"
    end

    it do
      sign_in!()
      # thing = Thing::Create[thing: {"name" => "Rails", "users" => [{"email" => "fred@trb.org"}]}].model

      visit "/things/#{thing_with_fred.id}/edit"

      page.must_have_css "form #thing_name.readonly[value='Rails']"
      # existing email is readonly.
      page.must_have_css "#thing_users_attributes_0_email.readonly[value='fred@trb.org']"
      # remove button for existing.
      page.must_have_css "#thing_users_attributes_0_remove"
      # empty email for new.
      page.must_have_css "#thing_users_attributes_1_email"
      # no remove for new.
      page.wont_have_css "#thing_users_attributes_1_remove"
    end

    # TODO: test signed in, but different user.
  end

  describe "#update" do
    it do
      sign_in!()

      # put :update, id: thing.id, thing: {name: "Trb"}
      visit edit_thing_path(thing_with_fred.id)
      fill_in 'Description', with: "Primitive MVC"
      click_button "Update Thing"

      # assert_redirected_to thing_path(thing)
      page.current_path.must_equal thing_path(thing_with_fred.id)
      page.must_have_css "h1", text: "Rails"
      page.must_have_content "Primitive MVC"
    end

    it do
      sign_in!()

      # put :update, id: thing.id, thing: {description: "bla"}
      visit edit_thing_path(thing_with_fred.id)
      fill_in 'Description', with: "bla"
      click_button "Update Thing"

      page.must_have_css ".error"
    end
  end

  describe "#show" do
    it do
      visit thing_path(thing.id)

      page.must_have_content "Rails"

       # the form. this assures the model_name is properly set.
      page.must_have_css "input.button[value=\"Create Comment\"]"
      # make sure the user form is displayed.
      page.must_have_css ".comment_user_email"
      # comments must be there.
      page.must_have_css ".comments .comment"
    end
  end

  describe "#create_comment" do
    it "invalid" do
      # post :create_comment, id: thing.id, comment: {body: "invalid!"}
      visit thing_path(thing.id)
      fill_in 'Your comment', with: "invalid!"
      click_button "Create Comment"

      page.must_have_css ".comment_user_email.error"
    end

    it do
      # post :create_comment, id: thing.id, comment: {body: "That green jacket!", weight: "1", user: {email: "seuros@trb.org"}}
      visit thing_path(thing.id)
      fill_in 'Your comment', with: "That green jacket!"
      choose "Rubbish!"
      fill_in "Your Email", with: "seuros@trb.org"
      click_button "Create Comment"

      # assert_redirected_to thing_path(thing)
      page.current_path.must_equal thing_path(thing)
      # flash[:notice].must_equal "Created comment for \"Rails\""
      page.must_have_css ".alert-box", text: "Created comment for \"Rails\""
    end
  end

  describe "#next_comments" do
    it do
      visit thing_path(thing.id)
      # xhr :get, :next_comments, id: thing.id, page: 2
      click_link "More!"

      page.must_have_content /zavan@trb.org/
    end
  end
end