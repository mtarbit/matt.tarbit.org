class OldLink < ActiveRecord::Base
  establish_connection(:legacy)
  set_table_name "links"
  has_and_belongs_to_many :old_tags, :join_table=>'links_tags', 
    :association_foreign_key=>'tag_id',
    :foreign_key=>'link_id'
end
