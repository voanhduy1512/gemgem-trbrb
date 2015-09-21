module Thing::Api
  class Create < Thing::Create
    # def to_json(*)
    #   "ficken"
    # end
    include Representer
    include Responder

    representer do
      feature Roar::JSON
      feature Roar::Hypermedia

      representable_attrs[:definitions].delete("persisted?")

      property :users, inherit: true, as: :authors do
        representable_attrs[:definitions].delete("persisted?")

        property :id
        link(:self) { api_user_path(represented.id) }
      end

      property :id
      link(:self) { api_thing_path(represented) }
    end
  end


  class Show < Thing::Show
    # def to_json(*)
    #   "hello"
    # end
    include Representer
    representer do
      feature Roar::Hypermedia
      feature Roar::JSON

      def self.properties(*names)
        names.each { |n| property(n) }
      end
      properties :id, :name, :description
      link(:self) { thing_path(represented) }

      collection :users, as: :authors do
        property :email

        link :self do
          user_path(represented)
        end
      end

      collection :comments do
        property :body
      end
    end
    # include Responder

    def represented
      model
    end
  end
end