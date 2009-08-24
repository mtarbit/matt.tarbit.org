class BookSweeper < ActionController::Caching::Sweeper
  observe Book

  def after_create(record)
    expire_item(record)
  end

  def after_update(record)
    expire_item(record)
  end

  def after_destroy(record)
    expire_item(record)
  end

private

  def expire_item(record)
    return if record.nil?
  
    # Expire the two index pages
    expire_page({:controller=>'book'})
    expire_page({:controller=>'author'})
    
    # Expire this record and any associated records
    if record.is_a?(Book)
      expire_book(record)
      record.authors.each {|author| expire_author(author) }
    else
      expire_author(record)
      record.books.each {|book| expire_book(book) }
    end
  end

  def expire_book(book)
    # Find the appropriate book page and expire it
    expire_page({:controller=>'book',:action=>'show',:id=>book.id})
    # Expire the front page if this book is on it
    last = Book.find(:first, :order=>'created_at DESC', :offset=>3)
  	expire_page(index_path) if book.created_at >= last.created_at
  end

  def expire_author(author)
    # Find the appropriate author page and expire it
    expire_page({:controller=>'author',:action=>'show',:id=>author.id})
  end
end
