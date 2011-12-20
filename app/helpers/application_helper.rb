# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def form_rows_for(name, *args, &block)
    options = args.last.is_a?(Hash) ? args.pop : {}
    options = options.merge(:builder => FormRowBuilder)
    args << options
    form_for(name, *args, &block)
  end

  def render_comments(comments, depth=0)
    s = ActiveSupport::SafeBuffer.new
    for c in comments.to_a
      s.safe_concat(render(:partial=>'entry/comment', :locals=>{:c=>c, :depth=>depth}))
      s.safe_concat(render_comments(c.children, depth+1)) unless c.children.empty?
    end
    s
  end

  def linkify_tags(tags)
    tags.map{|t| link_to(t.name, tag_url(:name=>t.name), {:class=>'tag'}) }.to_sentence(:last_word_connector=>' &amp; ').html_safe
  end

  def linkify_authors(authors, html_options={})
    authors.map{|a| link_to(a.name, {:controller=>:author,:action=>:show,:id=>a.id}, html_options) }.to_sentence(:last_word_connector=>' and ').html_safe
  end

  def highlight_html(str,words)
    return str if str.nil? or words.nil?

    # Make sure we're only highlighting non-tag text.
    # \G is the point where the last match finished.
    text_open = '(^|<.*?>|\G)'
    text_shut = '($|<.*?>)'
    reg = /#{text_open}(.*?)#{text_shut}/

    # Block form of gsub is broken for SafeBuffers. Escape first,
    # convert to str, then convert back to SafeBuffer when done.
    # See: https://github.com/rails/rails/issues/1555
    str = ERB::Util.html_escape(str).to_str
    str.gsub!(reg) { $1 + highlight_text($2, words) + $3 }
    str.html_safe
  end

  def highlight_text(str,words)
    return str if str.nil? or words.nil?

    # Create a reg-ex pattern from the search words.
    words.map! {|w| Regexp.escape(w) }
    words = words.join('|')

    # See comments in highlight_html() above.
    str = ERB::Util.html_escape(str).to_str
    str.gsub!(/\b(#{words})\b/i, '<em class="highlight">\1</em>')
    str.html_safe
  end

  def codify(str)
    str = ERB::Util.html_escape(str).to_str
    str.gsub!(%r|<pre><code>\s*@@(\w+)\s*(.*?)\s*</code></pre>|m) do
      code = Pygments.highlight($2, :lexer => $1)
      code.sub!(%r|<div class="highlight">\s*<pre>(.*)</pre>\s*</div>|m, '\1')
      %{\n\n<pre class="code"><code>%s\n</code></pre>\n\n} % [code.rstrip]
    end
    str.html_safe
  end

end
