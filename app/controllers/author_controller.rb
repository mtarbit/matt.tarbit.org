class AuthorController < ApplicationController
  caches_page :index, :show

  def index
    @authors = Author.find_by_sql "SELECT a.id, a.name, COUNT(*) AS count FROM authors a LEFT JOIN authors_books ab ON a.id = ab.author_id GROUP BY a.id ORDER BY a.name ASC"
  end

  def show
    @author = Author.find(params[:id])
  end

end
