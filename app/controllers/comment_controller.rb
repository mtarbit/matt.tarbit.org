class CommentController < ApplicationController
  before_filter :authenticate, :only=>[:index,:delete]
  cache_sweeper :blog_sweeper, :only=>[:create,:update,:delete]

  layout :layout_for_action

  def layout_for_action
    action_name == 'index' ? 'admin' : 'application'
  end

  def index
    @single_column = true
    @comments = Comment.paginate(:all, :page=>params[:page], :per_page=>15, :order=>'comments.created_at DESC')
  end

	def preview
		redirect_to index_url unless request.xhr?
		@entry = Entry.published.find(params[:entry][:id])
		@entry.threads.build(params[:comment])
	  @entry.comments_count += 1
	end
  
  def create
    # If no referer, it's probably a spambot, so give it the silent treatment.
    unless request.env.has_key?('HTTP_REFERER')
      logger.silence do
        render :text=>'', :status=>404 and return
      end
    end
    
    tokens = spam_challenge_tokens
    entry = Entry.published.find(params[:entry][:id])
    comment = Comment.new(params[:comment])
    comment.entry = entry
    comment.ip = request.env['REMOTE_ADDR']

    last_comment = Comment.find(:first, :order=>'created_at DESC')
    is_duplicate = (last_comment and last_comment.content == comment.content)

    # Is this a duplicate comment, or are comments disabled?
    if is_duplicate or not SETTINGS['features_enabled']['comments']
      redirect_to entry_url(entry)
    else

      # Did the comment pass our spam challenge?
      unless params[tokens[0]] == tokens[1]
        flash[:errors] = "Sorry, your comment didn't make it through our spam filtering."
        redirect_to entry_url(entry)
      else

        # Did we successfully save the comment?
        unless comment.save
          flash[:errors] = comment.errors.full_messages
          flash[:comment] = params[:comment]
          redirect_to entry_url(entry)
        else

          # Remember the user's details for next time.
          cookies[:user_name] = { :value => comment.name, :expires => 1.year.from_now }
          cookies[:user_email] = { :value => comment.email, :expires => 1.year.from_now }
          cookies[:user_website] = { :value => comment.website, :expires => 1.year.from_now }

          # Send a comment notification email then show the comment added to the page.
          vars = {
            :comment => comment, 
            :read_link => entry_url(entry, :anchor=>"comment-#{comment.id}"),
            :junk_link => url_for(:controller=>'comment', :action=>'delete', :id=>comment),
            :request => request
          }
          if SETTINGS['features_enabled']['emails']
            email = Mailer.deliver_comment(vars)
          end
          redirect_to vars[:read_link]

        end
      end
    end

  end
  
  def update
    comment = Comment.find(params[:comment][:id])
    comment.attributes = params[:comment]
    comment.save!
    redirect_to entry_url(comment.entry)
  end

  def delete
    begin
      comment = Comment.find(params[:id])
      comment.destroy
      redirect_to request.referer || entry_url(comment.entry)
    rescue ActiveRecord::RecordNotFound
      render_not_found
    end
  end

end
