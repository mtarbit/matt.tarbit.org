class OldComment < ActiveRecord::Base
  establish_connection(:legacy)
  set_table_name "comments"
  acts_as_tree :order => 'created_at'
  belongs_to :old_post, :foreign_key => 'article_id'
  belongs_to :old_user, :foreign_key => 'user_id'
end