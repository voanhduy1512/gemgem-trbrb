module Thing::Api
  class Create < Thing::Create
    include Representer
    include Responder

    representer do
      feature Roar::JSON::HAL

      representable_attrs[:definitions].delete("persisted?")

      property :users, inherit: true, as: :authors, embedded: true do
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

    representer Create.representer do
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