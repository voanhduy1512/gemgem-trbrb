class Thing < ActiveRecord::Base
  class Update < Create
    self.builder_class = Create.builder_class
    policy Thing::Policy, :update?
    action :update

    class SignedIn < self
      contract do
        property :name, writeable: false

        # DISCUSS: should inherit: true be default?
        collection :users, inherit: true, skip_if: :skip_user? do
          property :email, skip_if: :skip_email?

          def skip_email?(fragment, options)
            model.persisted?
          end
        end

      private
        def skip_user?(fragment, options)
          puts "@@@@@ #{fragment.inspect}"
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
