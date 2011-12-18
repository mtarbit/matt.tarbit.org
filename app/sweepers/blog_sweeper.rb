class BlogSweeper < ActionController::Caching::Sweeper
  observe Entry, Comment

  def after_create(record)
    expire_entry(record)
    expire_entry_counts(record)
  end

  def after_update(record)
    expire_entry(record)
  end

  def after_destroy(record)
    expire_entry(record)
    expire_entry_counts(record)
  end

private

  def options_for_entry(entry)
    # Was having issues with the entry_options method from the
    # application controller. Possibly out of scope? Seemed to
    # be working intermittently though, not sure of cause?
    y,m,d = entry.created_at.strftime('%Y %m %d').split
    entry_opts = {:y=>y, :m=>m, :d=>d, :slug=>entry.slug}
  end

  def expire_entry(record)
    return if record.nil?

    # Find the appropriate entry page and expire it
    entry = record.is_a?(Entry) ? record : record.entry
    # Expire fragment seems to behave oddly with a path, it's happier with a hash
    expire_fragment({:controller=>'entry',:action=>'read'}.merge(options_for_entry(entry)))

    # Expire the front page if this entry is on it
    last = Entry.published.find(:first, :order=>'created_at DESC', :offset=>19)
    expire_page(index_path) if entry.created_at >= last.created_at

    # Expire the date pages that this entry appears on
    date_opts = options_for_entry(entry)
    date_opts.delete(:slug)
    expire_page(date_path(date_opts)) # Day page
    date_opts.delete(:d)
    expire_page(date_path(date_opts)) # Month page
    date_opts.delete(:m)
    expire_page(date_path(date_opts)) # Year page

    # Expire the "archives by title" page. The archive page itself only has
    # article counts on it, so doesn't need expiring for entry updates.
    expire_page(titles_path)

    if record.is_a?(Entry)
      # Expire the tag pages that this entry appears on
      expire_page(tags_path)
      if entry.tags
        entry.tags.each {|t| expire_page(tag_path(:name=>t.name)) }
      end

      # Expire next / prev entry pages (due to metadata links)
      # expire_fragment(entry_path(entry.find_next))
      # expire_fragment(entry_path(entry.find_prev))
    end
  end

  def expire_entry_counts(record)
    return unless record.is_a?(Entry)
    expire_page(archive_path)
    expire_page(titles_path)
    expire_page(about_path)
  end

end
