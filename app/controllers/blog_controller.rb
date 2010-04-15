class BlogController < ApplicationController
  caches_page :index, :archive, :archives_by_title, :date, :about

  def index
    @entries = Entry.published.find(:all, :include=>[:comments], :order=>'entries.created_at DESC', :limit=>20)
    @first_date = @entries.first.created_at
    @books = Book.find(:all, :include=>[:authors], :order=>'books.created_at DESC', :limit=>4)
  end
	
  def archive
    @dates = Entry.published.counts_by_date
  end

  def archives_by_title
    @entries = Entry.published.find(:all, :order=>'entries.created_at DESC')
  end

  def date
    y,m,d = [params[:y], params[:m], params[:d]].map {|v| v.to_i if v }
    begin
      @entries = Entry.published.find_by_date(y,m,d)
      @format1 = m ? d ? "%e %b %Y" : "%b %Y" : "%Y"
      @format2 = m ? d ? "%Y %m %d" : "%Y %m" : "%Y"
      @title = 'All entries from ' + Time.local(y,m,d).strftime(@format1)
      @prev = @entries.last.find_prev
      @next = @entries.first.find_next
    rescue:
      render_not_found
    end
  end

  def search
    if params[:words]
      @words = split_search_terms(params[:words])
      @entries = Entry.published.find_by_words(@words)
			@title = 'Search results for "%s"' % params[:words]
		else
			@title = 'Search'
		end
  end

  def about
    @count = Entry.published.count(:all, :group=>:variant, :order=>'count_all DESC')
    @total = @count.inject(0) { |sum,a| sum + a.last }
    @books = Book.count
    @authors = Author.count
  end
  
  def cv
    @single_column = true
  end
  
  def hobby_games
    @wide_layout = true
  end
  
  def family_games
  	@wide_layout = true
  end

private

  def split_search_terms(str)
    # within quoted text replace spaces with a placeholder
    reg = /\"(.*?)\"/
    str = str.gsub(reg) { |s| s.gsub(/\s/,'[SPACE]') }
    # split on spaces
    words = str.split
    # replace placeholders with spaces and remove quotes
    words.map {|w| w.gsub('[SPACE]',' ').gsub(reg,'\1') }
  end
    
end
