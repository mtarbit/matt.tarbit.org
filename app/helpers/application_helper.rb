# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

	def form_rows_for(name, *args, &block)
    options = args.last.is_a?(Hash) ? args.pop : {}
    options = options.merge(:builder => FormRowBuilder)
    args << options
    form_for(name, *args, &block)
  end

	def render_comments(comments, depth=0)
		s = ''
		for c in comments.to_a
			s << render(:partial=>'entry/comment', :locals=>{:c=>c, :depth=>depth})
			s << render_comments(c.children, depth+1) unless c.children.empty?
		end
		s
	end

  def linkify_tags(tags)
    tags.map{|t| link_to(t.name, tag_url(:name=>t.name), {:class=>'tag'}) }.to_sentence(:last_word_connector=>' &amp; ')
  end

  def linkify_authors(authors, html_options={})
    authors.map{|a| link_to(a.name, {:controller=>:author,:action=>:show,:id=>a.id}, html_options) }.to_sentence(:last_word_connector=>' and ').html_safe
  end

  def highlight_html(str,words)
		return str if str.nil? or words.nil?
		# make sure we're only highlighting non-tag text
		text_open = '(^|\G|<(?:.*?)>)'
		text_shut = '($|<(?:.*?)>)'
		reg = /#{text_open}(.*?)#{text_shut}/
		str.gsub(reg) { $1 + highlight_text($2,words) + $3 }
	end
																					        
	def highlight_text(str,words)
		return str if str.nil? or words.nil?
		words.map! {|w| Regexp.escape(w) }
		words = words.join('|')
		str.gsub(/\b(#{words})\b/i, '<em class="highlight">\1</em>')
	end

end
