# split up files (update goes to separate.) split up contract?
# talk about this? http://stackoverflow.com/questions/4116415/preselect-check-box-with-rails-simple-form

# how does skipping work: Form.new[user, user2], then validate with [user, user2:skip,user], user2 will still be there but not updated.
#   save => users = [user] (without deleted), removes user from collection.
require_dependency "thing/policy"
require "trailblazer/operation/policy"
require "trailblazer/operation/model/external"

class Thing < ActiveRecord::Base
  class Create < Trailblazer::Operation
    include Resolver
    policy Thing::Policy, :create?
    # policy Thing, :create?, "signed_in" (can be infered from class?)
    model Thing, :create

    builds -> (model, policy, params) do
      return self::Admin    if policy.admin?
      return self::SignedIn if policy.signed_in?
    end



    require_dependency "thing/contract"
    self.contract_class = Contract
    contract_class.model Thing # TODO: do this automatically.



    class IsLimitReached
      def self.call(user, errors)
        return unless Tyrant::Authenticatable.new(user).confirmable?

        return if user.authorships.size == 0 && user.comments.size == 0
        errors.add("users", "User is unconfirmed and already assign to another thing or reached comment limit.")
      end
    end


    callback(:before_save) do
      on_change :upload_image!, property: :file
      collection :users do
        on_add :sign_up_sleeping!
      end
    end

    # declaratively define what happens at an event, for a nested setup.
    callback do
      collection :users do
        on_add :notify_author!
        on_add :reset_authorship!

        # on_delete :notify_deleted_author! # in Update!
      end

      on_change :expire_cache!
    end

  # private
    def notify_author!(user)
      # NewUserMailer.welcome_email(user)
    end

    def reset_authorship!(user)
      user.model.authorships.find_by(thing_id: model.id).update_attribute(:confirmed, 0)
    end

    include Gemgem::ExpireCache

    def upload_image!(thing)
      contract.image!(contract.file) do |v|
        v.process!(:original)
        v.process!(:thumb)   { |job| job.thumb!("120x120#") }
      end
    end

    require_dependency "session/operations"
    def sign_up_sleeping!(user)
      return if user.persisted? # only new
      Session::SignUp::UnconfirmedNoPassword.(user: user.model)
    end

    def process(params)
      validate(params[:thing]) do |f|
        dispatch!(:before_save)
        f.save
        dispatch!
      end
    end

    class SignedIn < self
      include Thing::SignedIn
    end

    class Admin < SignedIn
    end
  end

  class Show < Trailblazer::Operation
    include Model
    model Thing, :find

    include Trailblazer::Operation::Policy
    policy Thing::Policy, :show?

    def process(*)
    end

    def to_json(*)
      "hello"
    end
  end

  # TODO: do that in contract, too, in chapter 8.
  ImageProcessor = Struct.new(:image_meta_data) do
    extend Paperdragon::Model::Writer
    processable_writer :image
  end
end

require_dependency "thing/delete"