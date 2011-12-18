class OldUser < ActiveRecord::Base
  establish_connection(:legacy)
  set_table_name "users"
  has_many :old_comments, :foreign_key => 'user_id'
end
