module Thing::Api
  module T_Representer
    # include Representable::JSON

    def self.included(includer)
      includer.class_eval do
        feature Roar::JSON::HAL

        representable_attrs[:definitions].delete("persisted?")

        property :users, inherit: true, as: :authors, embedded: true do
          representable_attrs[:definitions].delete("persisted?")

          property :id, writeable: false
          link(:self) { api_user_path(represented.id) }
        end

        # puts "***"+ representable_attrs.get(:users)[:instance].inspect

        property :id
        link(:self) { api_thing_path(represented) }
      end
    end
  end

  class Create < Thing::Create
    include Representer
    include Responder

    representer do
      include T_Representer
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
      # representer Create.representer
      representer do
       include T_Representer
      end

      # puts representer_class.representable_attrs.get(:users).inspect
    end

  end
end