module API::V1
  module Comment
    module Representer
      class Show < Roar::Decorator
        feature Roar::JSON::HAL

        property :body
        property :user, embedded: true do
          property :email
          link(:self) { api_v1_user_path(represented.id) }
        end

        link(:self) { api_v1_comment_path(represented.id) }
      end
    end
  end
end