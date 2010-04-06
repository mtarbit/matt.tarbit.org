# Override BlueCloth code block handling
class BlueCloth

  def escape_shell_arg(str)
    "'%s'" % str.gsub("'","'\\\\''")
  end

  def transform_code_blocks(str, rs)
    @log.debug " Transforming code blocks"

    str.gsub(CodeBlockRegexp) {|block|
      code,rest = $1,$2

      # Remove the syntax line and extract the language from it
      regx = /(?:[ ]{4}|\t)+@@(.*)\n+/
      lang = code.slice!(regx).slice(regx,1)

      # Escape newlines (No idea why this is necessary. Wasn't previously.)
      code.gsub!(/\\r/,"\\\\\\r")
      code.gsub!(/\\n/,"\\\\\\n")

      # Call out to pygmentize to markup the code for highlighting
      code = `echo #{escape_shell_arg(code)} | #{escape_shell_arg(SETTINGS['pygmentize_path'])} -f html -l #{escape_shell_arg(lang)}`

      # Remove the extraneous wrapper markup that we're not using
      code.sub!(/<div class="highlight"><pre>(.*)<\/pre><\/div>/m, '\1')

      # Generate the codeblock
      %{\n\n<pre class="code"><code>%s\n</code></pre>\n\n%s} % [ outdent(code).rstrip, rest ]
    }
  end

=begin
  alias old_transform_code_blocks transform_code_blocks

  def transform_code_blocks(str, rs)
    str = old_transform_code_blocks(str, rs)
    str.gsub!(/<code>@@(.*)\n+/, '<code class="\1">')
    return str
  end
=end

end
