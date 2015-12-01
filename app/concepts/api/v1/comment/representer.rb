module API::V1
  module Comment
    module Representer
      class Show < Roar::Decorator
        include Roar::JSON::HAL

        property :body
        property :body

        link(:self) { api_v1_comment_path(represented.id) }
      end
    end
  end
end