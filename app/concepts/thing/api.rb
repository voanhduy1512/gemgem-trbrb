module Thing::Api
  class Create < Thing::Create
    include Representer
    include Responder

    representer do
      feature Roar::JSON::HAL

      collection :users, inherit: true, as: :authors, embedded: true, render_empty: false do
        property :id, writeable: false
        link(:self) { api_user_path(represented.id) }
      end

      # puts "***"+ representable_attrs.get(:users)[:instance].inspect

      property :id
      link(:self) { api_thing_path(represented) }
    end


  end


  class Show < Thing::Show
    # def to_json(*)
    #   "hello"
    # end
    include Representer



    representer Class.new(Create.representer) do
      collection :comments, embedded: true do
        property :body
      end
    end
    # include Responder

    def represented
      model
    end
  end

  class Update < Thing::Update
    class Admin < Thing::Update::Admin
      self.policy Thing::Policy, :true?

      # def setup!(param)
      #   raise param.inspect
      # end
      # def process(params)
      #   raise params.inspect
      # end
      include Representer
      representer Create.representer


      # puts representer_class.representable_attrs.get(:users).inspect
    end

  end

  class Index < Trailblazer::Operation
    def model!(params)
      Thing.latest
    end

    def process(*)

    end

    def to_json(*)
      Representer::Index.new(@model).to_json
    end
  end

  require "representable/hash/collection"
  module Representer
    class Index < Roar::Decorator
      include Representable::JSON::Collection

      items decorator: Create.representer
    end
  end
end