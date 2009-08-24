class AdminController < ApplicationController
  before_filter :authenticate, :except=>:login
  cache_sweeper :blog_sweeper, :only=>[:sync_from_delicious, :sync_from_twitter]
  
  def login
    if request.post?
      user = User.authenticate(params[:user][:username], params[:user][:password])
      if user
        if params[:remember_me]
          cookies[:user] = {:value=>user.id.to_s, :expires=>10.years.from_now}
        end
        session[:user] = user
        redirect_to session[:referrer]
      else
        flash[:notice] = "Invalid username / password combination"
        @user = User.new(params[:user])
      end
    end
  end

  def logout
    session[:user] = nil
    cookies.delete(:user)
    redirect_to index_url
  end

  def index
    @wide_layout = true
		conditions = {:format => params[:variant]} if params[:variant]
    @entries = Entry.find(:all, :conditions=>conditions, :include=>[:comments,:tags], :order => 'entries.created_at DESC', :limit=>20)
  end

  def sync_from_delicious
    require 'rubilicious'
    r = Rubilicious.new(SETTINGS['delicious']['username'], SETTINGS['delicious']['password'])
		begin
			r.recent.each {|e| Entry.create_from_delicious(e) }
		rescue ActiveRecord::RecordNotSaved
			flash[:notice] = "Entry could not be created from del.icio.us bookmark"
		end
		redirect_to admin_url
  end

  def sync_from_twitter
    require 'twitter'
    latest = Entry.find(:first, :conditions=>{:format=>'status'}, :order=>'created_at DESC')
    params = latest ? {:since_id=>latest.url} : {:count=>200}
    tweets = Twitter::Base.new(SETTINGS['twitter']['username'], SETTINGS['twitter']['password']).timeline(:user, params)
		tweets.each {|e| Entry.create_from_twitter(e) }
    redirect_to admin_url
  end

  def amazon
    @wide_layout = true
		@title = 'Amazon search'

    if params[:keywords]
      if @items = Product.search(params[:keywords],{ :SearchIndex=>params[:search_index] })
  			@title << " results for \"#{params[:keywords]}\""
      end
    end
  end

  def library
    @wide_layout = true
    @books = Book.find(:all, :include=>[:authors], :order => 'books.created_at DESC')
  end

private

  def migrate_database
    Entry.destroy_all

    @old_posts = OldPost.find(:all)
    for p in @old_posts do
      e = Entry.new(
        :content => Post.new(:title=>p.subject, :content=>p.body),
        :updated_at => p.modified_at,
        :created_at => p.created_at
      )
      e.threads = convert_comments(e, p.old_threads)
      e.save!
    end

    @old_links = OldLink.find(:all)
    for l in @old_links do
      e = Entry.new(
        :content => Link.new(:href=>l.href, :text=>l.description, :description=>l.extended, :checksum=>l.attributes['hash']),
        :updated_at => l.modified_at,
        :created_at => l.time
      )
      e.tags = l.old_tags.map{ |t| Tag.find_or_initialize_by_name(t.name) }
      e.save!
    end
  end

  def convert_comments(e, comments)
    return if comments.nil?
    new_comments = []
    for c in comments
      if c.children.length > 0
        new_children = convert_comments(e, c.children) 
      else
        new_children = []
      end
      new_comments << Comment.new(
        :entry => e,
        :content => c.body,
        :name => c.old_user.name,
        :href => (c.old_user.url || c.old_user.email),
        :created_at => c.created_at,
        :updated_at => c.modified_at,
        :children => new_children
      )
    end
    new_comments
  end
  
  def migrate_library
    require 'csv'
    require 'time'
    require 'amazon/ecs'

    delete_indices = [2,4,5,7,8,9,11,12,13].reverse

    @csv = CSV.read("#{RAILS_ROOT}/lib/librarything.csv")
    @csv.shift # Not interested in the header row
    @csv.each do |row|
      # Strip square-brackets from around the 10 digit ISBN
      row[6].sub!(/\[([a-zA-Z0-9]+)\]/,'\1')
      # Convert entry date string to unix timestamp
      row[10] = Time.parse(row[10])
      # Delete the columns we aren't going to be using
      delete_indices.each {|i| row.delete_at(i) }

      # Product.search_by_keywords(params[:keywords])
      author = Author.find_or_initialize_by_name(row[1]) if row[1]
      book = Book.new
      book.title = row[0]
      book.authors << author if author
      book.isbn = row[3]
      book.created_at = row[4]
      book.save!
    end
  end

end
