class TagController < ApplicationController
  caches_page :index, :read

  def index
    @tags = Tag.find_by_sql "SELECT t.name, COUNT(*) AS count FROM tags t LEFT JOIN entries_tags e ON t.id = e.tag_id GROUP BY t.id ORDER BY count DESC"
    @title = "Tags"
  end

  def read
    @tag = Tag.find_by_name(params[:name])
    if @tag.nil?
      render :template => 'blog/notfound'
    else
      @title = "Tagged as #{@tag.name}"
    end
  end

end
