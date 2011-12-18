class EntryController < ApplicationController
  before_filter :authenticate, :except=>:read
  cache_sweeper :blog_sweeper, :only=>[:create,:update,:delete]

  layout :layout_for_action

  def layout_for_action
    action_name == 'read' ? 'application' : 'admin'
  end

  def read
    if params[:slug]
      @entry = Entry.find_by_slug(params[:y],params[:m],params[:d], params[:slug])
    end
    if @entry.nil? or (not session[:user] and not @entry.published)
      render_not_found
      # raise ActiveRecord::RecordNotFound
    else
      @title = @entry.page_title
      @next = @entry.find_next
      @prev = @entry.find_prev

      # Create the comment object, pre-populating it with data
      # from either a failed submission or a previous comment.
      @comment = Comment.new(flash[:comment] || {
        :name => cookies[:user_name],
        :email => cookies[:user_email],
        :website => cookies[:user_website]
      })

      @tokens = spam_challenge_tokens
    end
  end

  def new
    @single_column = true
    @entry = Entry.new
    @entry.variant = params[:variant]

    if @entry.variant=='review'
      if params[:asin]
        @entry.product = Product.search_by_asin(params[:asin])
        @entry.title = @entry.page_title
      else
        redirect_to :controller=>'admin', :action=>'amazon', :next=>request.path
      end
    end
  end

  def edit
    @single_column = true
    @entry = Entry.find(params[:id])

    if @entry.variant=='review' and params[:asin]
      @entry.product = Product.lookup(params[:asin])
      @entry.title = @entry.page_title
    end
  end

  def create
    entry = Entry.new(params[:entry])
    if entry.variant == 'review'
      entry.product = Product.search_by_asin(params[:asin])
    end
    entry.save!

    redirect_to admin_url
  end

  def update
    entry = Entry.find(params[:entry][:id])
    entry.attributes = params[:entry]
    if entry.variant == 'review'
      entry.product = Product.search_by_asin(params[:asin])
    end
    entry.save!
    redirect_to admin_url
  end

  def delete
    entry = Entry.destroy(params[:id])
    entry.destroy
    redirect_to admin_url
  end

end
