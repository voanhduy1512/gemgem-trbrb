module Comment::API
  module Representer
    class Show < Roar::Decorator
      include Roar::JSON::HAL

      property :body

      link(:self) { api_comment_path(represented.id) }
    end
  end

end

module Thing::Api
    # require "representable/hash/collection"
  module Representer
    class Create < Roar::Decorator
      include Roar::JSON::HAL

      property   :name
      collection :users, as: :authors, embedded: true, render_empty: false, populator: Reform::Form::Populator::External.new do
        include Roar::JSON::HAL

        property :email

        link(:self) { api_user_path(represented.id) }
      end

      link(:self) { api_thing_path(represented) }
    end

    class Index < Roar::Decorator
      include Roar::JSON::HAL

      with_comments = Class.new(Create) do
        collection :comments, decorator: Comment::API::Representer::Show, embedded: true
      end

      collection :to_a, as: :things, embedded: true, decorator: with_comments

      link(:self) { api_things_path }
    end
  end





  class Create < Thing::Create
    include Trailblazer::Operation::Representer
    include Responder

    representer Representer::Create
  end


  class Show < Thing::Show
    # def to_json(*)
    #   "hello"
    # end
    include Trailblazer::Operation::Representer



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
      include Trailblazer::Operation::Representer
      representer Create.representer


      # puts representer_class.representable_attrs.get(:users).inspect
    end

  end



  class Index < Trailblazer::Operation
    def model!(params)
      return Thing.oldest if params[:sort] == "oldest"
      Thing.latest
    end

    def process(*)

    end

    include Trailblazer::Operation::Representer
    representer Representer::Index
    # def to_json(*)
    #   Representer::Index.new(@model).to_json
    # end

    def to_json(*)
      options = {to_a: {}}

      if @params[:include]
        scalars = self.class.representer.definitions.get(:to_a).representer_module.
          definitions.values.reject { |dfn| dfn.typed? }.map { |dfn| dfn[:name].to_sym }

        options[:to_a][:include] = [*scalars, :links, @params[:include].to_sym]
      end

      super(options)
    end
  end
end