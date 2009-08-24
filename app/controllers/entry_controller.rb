class EntryController < ApplicationController
  before_filter :authenticate, :except=>:read
  cache_sweeper :blog_sweeper, :only=>[:create,:update,:delete]
  
  def read
    if params[:slug]
      @entry = Entry.find_by_slug(params[:y],params[:m],params[:d], params[:slug])
    end
    if @entry.nil?
      render :template => 'blog/notfound'
    else
   		@title = @entry.page_title
  		@next = @entry.find_next
  		@prev = @entry.find_prev
      @comment = Comment.new(flash[:comment])
      @tokens = spam_challenge_tokens 
    end
  end

  def new
    @wide_layout = true
    @entry = Entry.new
		@entry.format = params[:variant]

    if @entry.format=='review'
      if params[:asin]
        if @product = Product.search_by_asin(params[:asin])
          @entry.product = @product
          @entry.title = @entry.page_title
        else
          flash[:notice] = Product.error
        end
      end
      redirect_to :controller=>'admin', :action=>'amazon' if @product.nil?
    end
  end

  def edit
    @wide_layout = true
    @entry = Entry.find(params[:id])
  end

  def create
    entry = Entry.new(params[:entry])
    entry.save!

		if entry.format == 'review'
			if product = Product.find(params[:product][:id])
				product.entry = entry
				product.save!
			end
		end
				
    redirect_to admin_url
  end
  
  def update
    entry = Entry.find(params[:entry][:id])
    entry.attributes = params[:entry]
    entry.save!
    redirect_to admin_url
  end

  def delete
    entry = Entry.destroy(params[:id])
    entry.destroy
    redirect_to admin_url
  end

end
