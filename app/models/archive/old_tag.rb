class OldTag < ActiveRecord::Base
  establish_connection(:legacy)
  set_table_name "tags"
	has_and_belongs_to_many :old_links, :join_table=>'links_tags'
end
