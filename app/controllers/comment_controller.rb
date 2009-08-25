class CommentController < ApplicationController
  before_filter :authenticate, :only=>[:delete]
  cache_sweeper :blog_sweeper, :only=>[:create,:update,:delete]

	def preview
		redirect_to index_url unless request.xhr?
		@entry = Entry.find(params[:entry][:id])
		@entry.threads.build(params[:comment])
	  @entry.comments_count += 1
	end
  
  def create
    unless request.env.has_key?('HTTP_REFERER')
      # Almost certainly a spambot, give them the silent treatment
      logger.silence do
        render :text=>'', :status=>404 and return
      end
    end
    
    tokens = spam_challenge_tokens
    entry = Entry.find(params[:entry][:id])
    comment = Comment.new(params[:comment])
    comment.entry = entry
    comment.ip = request.env['REMOTE_ADDR']

    unless SETTINGS['features_enabled']['comments']
      redirect_to entry_url(entry)
    else
      unless params[tokens[0]] == tokens[1]
        flash[:errors] = "Sorry, your comment didn't make it through our spam filtering."
        redirect_to entry_url(entry)
      else
        unless comment.save
          flash[:errors] = comment.errors.full_messages
          flash[:comment] = params[:comment]
          redirect_to entry_url(entry)
        else
          vars = {
            :comment => comment, 
            :read_link => entry_url(entry, :anchor=>"comment-#{comment.id}"),
            :junk_link => url_for(:controller=>'comment', :action=>'delete', :id=>comment),
            :request => request
          }
          email = Mailer.deliver_comment(vars)
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
    comment = Comment.find(params[:id])
    comment.destroy
    redirect_to entry_url(comment.entry)
  end

end
