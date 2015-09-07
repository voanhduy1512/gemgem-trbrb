class Thing::Cell::Form < ::Cell::Concept
  inherit_views Thing::Cell

  include ActionView::RecordIdentifier
  include SimpleForm::ActionViewExtensions::FormHelper

  def show
    render :form
  end

private
  property :contract

  def css_class
    return "admin" if admin?
    ""
  end

  # this will be ::property :signed_in?, boolean: true
  def signed_in?
    model.policy.signed_in?
  end

  def admin?
    model.policy.admin?
  end
end