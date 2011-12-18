class OldPost < ActiveRecord::Base
  establish_connection(:legacy)
  set_table_name "articles"
  has_many :old_comments, :foreign_key=>'article_id', :order => 'created_at'
  has_many :old_threads, { :class_name=>'OldComment', :foreign_key=>'article_id', :conditions=>'parent_id = 0', :order=>'created_at ASC' }
end
