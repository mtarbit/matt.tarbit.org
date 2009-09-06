class BookController < ApplicationController
  before_filter :authenticate, :except=>[:index,:show]
  caches_page :index, :show
  cache_sweeper :book_sweeper, :only=>[:create,:update,:delete]

  def index
    @books = Book.find(:all,:include=>[:authors], :order=>'books.created_at DESC')
  end

  def show
    @book = Book.find(params[:id],:include=>[:authors])
  end

  def new
    @wide_layout = true
    @book = Book.new
    render :action=>'edit'
  end

  def edit
    @wide_layout = true
    @book = Book.find(params[:id])
    @products = @book.search_for_products
  end

  def search
    @wide_layout = true
    if params[:book][:id]
      @book = Book.find(params[:book][:id])
      @book.attributes = params[:book]
    else
      @book = Book.new(params[:book])
    end
    @products = @book.search_for_products

    logger.info("@@@@@@@@@@@@@@@")
    logger.info(@products.inspect)
    logger.info("@@@@@@@@@@@@@@@")

    render :action=>'edit'
  end

  def create
    book = Book.new(params[:book])
    asin = params[:book_image]

    unless asin.empty?
      book.book_images = Product.find_images_by_asin(asin)
    end
    
    book.save!
    redirect_to librarian_url
  end
  
  def update
    book = Book.find(params[:book][:id])
    asin = params[:book_image]

    unless asin.empty?
      # Delete all existing imagery
      book.book_images.map(&:destroy)
      book.book_images.delete

      # Look up & add the new imagery
      book.book_images = Product.find_images_by_asin(asin)
    end

    book.attributes = params[:book]
    book.save!
    delete_orphans

    redirect_to librarian_url
  end

  def delete
    book = Book.destroy(params[:id])
    book.destroy
    delete_orphans

    redirect_to librarian_url
  end

private

  def delete_orphans
    # Delete any authors which have been left orphaned by the edit
    authors = Author.find(:all, :include=>[:books])
    orphans = authors.select {|a| a.books.size < 1 }
    orphans.map(&:destroy)
  end

end
