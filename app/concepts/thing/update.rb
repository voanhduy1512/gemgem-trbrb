class Thing < ActiveRecord::Base
  class Update < Create
    self.builder_class = Create.builder_class
    policy Thing::Policy, :update?
    action :update

    class SignedIn < self
      contract do
        property :name, writeable: false

        # DISCUSS: should inherit: true be default?
        # collection :users, inherit: true, skip_if: :skip_user? do
        collection :users, inherit: true, populator: ->(fragment:, collection:, index:, **) {
            puts "))) #{users.inspect}"
            user = users.find { |u| u.id.to_s == fragment["id"].to_s }
            puts "@@@@@ user: #{user.inspect}"
            puts fragment.inspect
            puts
            if fragment["remove"].to_s == "1" and users.delete(user)
              return Representable::Pipeline::Stop
            end

            return Representable::Pipeline::Stop if collection[index] # populate-if_empty
            puts "...............#{collection[index]}"


            # raise fragment.inspect
            # raise user.inspect


            users.insert index, User.new
            } do
          property :id
          property :email, skip_if: :skip_email?

          def skip_email?(fragment, options)
            model.persisted?
          end
        end

      private
        def skip_user?(fragment, options)
          # puts "@@@@@ #{fragment.inspect}"
          # don't process if it's getting removed!
          return true if fragment["remove"] == "1" and users.delete(users.find { |u| u.id.to_s == fragment["id"] })
          # replicate skip_if: :all_blank logic.
          return true if fragment["email"].blank?
        end
      end
    end # SignedIn

    class Admin < SignedIn
      include Thing::SignedIn

      contract do
        property :name
      end
    end
  end # Update
end
