class ThingsController  < ApplicationController
  respond_to :html

  def new
    form Thing::Create
    @form.prepopulate!

    render_form
  end

  def create
    run Thing::Create do |op|
      return redirect_to op.model
    end

    @form.prepopulate!
    render_form
  end

  def show
    @thing_op = present Thing::Show
    @thing    = @thing_op.model

    form Comment::Create # overrides @model and @form!
  end

  def create_comment
    @thing_op = present Thing::Show
    @thing    = @thing_op.model

    run Comment::Create do |op| # overrides @model and @form!
      flash[:notice] = "Created comment for \"#{op.thing.name}\""
      return redirect_to thing_path(op.thing)
    end

    render :show
  end

  def edit
    puts "edit: @@@@??@ #{params.inspect}"

    form Thing::Update

    @form.prepopulate!

    render_form
  end

  def update
    run Thing::Update do |op|
      return redirect_to op.model
    end

    # @form.prepopulate!
    render_form
  end

  # TODO: test me.
  def destroy
    run Thing::Delete do |op|
      flash[:notice] = "#{op.model.name} deleted."
      return redirect_to root_path
    end
  end


  protect_from_forgery except: :next_comments # FIXME: this is only required in the test, things_controller_test.
  def next_comments
    present Thing::Show

    render js: concept("comment/cell/grid", @model, page: params[:page]).(:append)
  end

private
  def render_form
    # raise @operation.class.inspect
    render text: concept("thing/cell/form", @operation),
      layout: true
  end
end