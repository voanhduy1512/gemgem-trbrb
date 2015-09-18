require "roar/json"
require 'roar/json/hal'

# TODO: this was handled in roar-rails. we don't need roar-rails in Trailblazer (yay!), so provide this via Trb.
# initializer "roar.set_configs" do |app|
  ::Roar::Representer.module_eval do
    include Rails.application.routes.url_helpers
    # include Rails.app.routes.mounted_helpers

    def default_url_options
      {}
    end
  end
# end

# this is too late, apparently. the railtie is not considered anymore.
# require 'trailblazer/rails/railtie'

Trailblazer::Operation.class_eval do
  include Trailblazer::Operation::Dispatch
  include Trailblazer::Operation::Policy
end