require 'test_helper'
require 'md2man/html/engine'

describe 'html engine' do
  before do
    @markdown = Md2Man::HTML::ENGINE
  end

  def heredoc document
    document.gsub(/^\s*\|/, '').chomp
  end

  it 'renders nothing as nothing' do
    @markdown.render('').must_be_empty
  end

  it 'renders paragraphs' do
    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |just some paragraph
      |spanning
      |multiple
      |lines
      |but within 4-space indent
    INPUT
      |<p>just some paragraph
      |spanning
      |multiple
      |lines
      |but within 4-space indent</p>
    OUTPUT
  end

  it 'renders tagged paragraphs with uniformly two-space indented bodies' do
    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |just some paragraph
      |  spanning
      |  multiple
      |  lines
      |  but within 4-space indent
      |
      |  and a single line following
      |
      |  and multiple
      |  lines following
    INPUT
      |<dl><dt>just some paragraph</dt><dd>spanning
      |multiple
      |lines
      |but within 4-space indent</dd></dl><dl><dd>and a single line following</dd></dl><dl><dd>and multiple
      |lines following</dd></dl>
    OUTPUT
  end

  it 'does not break surrounding Markdown while processing references' do
    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |For example, the `printf(3)` cross reference would be emitted as this HTML:
      |
      |    <a class="md2man-reference" href="../man3/printf.3.html">printf(3)</a>
    INPUT
      |<p>For example, the <code>printf(3)</code> cross reference would be emitted as this HTML:</p><pre><code>&lt;a class=&quot;md2man-reference&quot; href=&quot;../man3/printf.3.html&quot;&gt;printf(3)&lt;/a&gt;
      |</code></pre>
      |
    OUTPUT
  end

  it 'renders references to other man pages as hyperlinks in middle of line' do
    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |convert them from markdown(7) into roff(7), using
    INPUT
      |<p>convert them from <a class="md2man-reference" href="../man7/markdown.7.html">markdown(7)</a> into <a class="md2man-reference" href="../man7/roff.7.html">roff(7)</a>, using</p>
    OUTPUT
  end

  it 'renders references to other man pages as hyperlinks at beginning of line' do
    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |markdown(1) into roff(2)
    INPUT
      |<p><a class="md2man-reference" href="../man1/markdown.1.html">markdown(1)</a> into <a class="md2man-reference" href="../man2/roff.2.html">roff(2)</a></p>
    OUTPUT
  end

  it 'does not render references inside code blocks' do
    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |    this is a code block
      |    containing markdown(7),
      |    roff(7), and much more!
    INPUT
      |<pre><code>this is a code block
      |containing markdown(7),
      |roff(7), and much more!
      |</code></pre>
      |
    OUTPUT
  end

  it 'does not render references inside code spans' do
    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |this is a code span `containing markdown(7), roff(7), and` much more!
    INPUT
      |<p>this is a code span <code>containing markdown(7), roff(7), and</code> much more!</p>
    OUTPUT
  end

  it 'does not render references inside image descriptions' do
    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |![Obligatory screenshot of md2man-roff(1) in action!](
      |https://raw.github.com/sunaku/md2man/master/EXAMPLE.png)
    INPUT
      |<p><img src="https://raw.github.com/sunaku/md2man/master/EXAMPLE.png" alt="Obligatory screenshot of md2man-roff(1) in action!"></p>
    OUTPUT
  end

  it 'escapes backslashes inside code blocks' do
    # NOTE: we have to escape backslashes in the INPUT to
    #       prevent Ruby from interpreting them as escapes
    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |    _______      _______
      |     ___  /___________ /__
      |      _  __/ __ \\  __/ /_/
      |      / /_/ /_/ / / / ,\\
      |      \\__/\\____/_/ /_/|_\\
      |                 >>>------>
    INPUT
      |<pre><code>_______      _______
      | ___  /___________ /__
      |  _  __/ __ \\  __/ /_/
      |  / /_/ /_/ / / / ,\\
      |  \\__/\\____/_/ /_/|_\\
      |             &gt;&gt;&gt;------&gt;
      |</code></pre>
      |
    OUTPUT
  end

  it 'adds permalinks to headings' do
    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |# foo *BAR*
      |## bar BAZ
      |### --BAZ-QUX--
      |#### qux (MOZ)
      |##### {m}oz END
      |# bar BAZ
      |## bar *BAZ*
      |### bar **BAZ**
      |#### -bar--BAZ---
    INPUT
<h1 id="foo-bar"><a name="foo-bar" href="#foo-bar" class="md2man-permalink" title="permalink"></a><span class=\"md2man-title\">foo</span> <span class=\"md2man-section\"><em>BAR</em></span></h1>\
<h2 id="bar-baz"><a name="bar-baz" href="#bar-baz" class="md2man-permalink" title="permalink"></a>bar BAZ</h2>\
<h3 id="baz-qux"><a name="baz-qux" href="#baz-qux" class="md2man-permalink" title="permalink"></a>--BAZ-QUX--</h3>\
<h4 id="qux-moz"><a name="qux-moz" href="#qux-moz" class="md2man-permalink" title="permalink"></a>qux (MOZ)</h4>\
<h5 id="m-oz-end"><a name="m-oz-end" href="#m-oz-end" class="md2man-permalink" title="permalink"></a>{m}oz END</h5>\
<h1 id="bar-baz-1"><a name="bar-baz-1" href="#bar-baz-1" class="md2man-permalink" title="permalink"></a>bar BAZ</h1>\
<h2 id="bar-baz-2"><a name="bar-baz-2" href="#bar-baz-2" class="md2man-permalink" title="permalink"></a>bar <em>BAZ</em></h2>\
<h3 id="bar-baz-3"><a name="bar-baz-3" href="#bar-baz-3" class="md2man-permalink" title="permalink"></a>bar <strong>BAZ</strong></h3>\
<h4 id="bar-baz-4"><a name="bar-baz-4" href="#bar-baz-4" class="md2man-permalink" title="permalink"></a>-bar--BAZ---</h4>
    OUTPUT
  end

  it 'adds permalinks to headings that contain man page references' do
    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |## here is-a-reference(3) to another man page
      |
      |here is a paragraph containing is-a-reference(3) again
      |
      |here is another paragraph containing is-a-reference(3) yet again
    INPUT
<h2 id="here-is-a-reference-3-to-another-man-page"><a name="here-is-a-reference-3-to-another-man-page" href="#here-is-a-reference-3-to-another-man-page" class="md2man-permalink" title="permalink"></a>here <a class="md2man-reference" href="../man3/is-a-reference.3.html">is-a-reference(3)</a> to another man page</h2>\
<p>here is a paragraph containing <a class="md2man-reference" href="../man3/is-a-reference.3.html">is-a-reference(3)</a> again</p>\
<p>here is another paragraph containing <a class="md2man-reference" href="../man3/is-a-reference.3.html">is-a-reference(3)</a> yet again</p>
    OUTPUT
  end

  it 'https://github.com/sunaku/md2man/issues/19' do
    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |### Macros
      |
      |    #define PIPES_GET_LAST(CHAIN)
      |    #define PIPES_GET_IN(CHAIN)
      |    #define PIPES_GET_OUT(CHAIN)
      |    #define PIPES_GET_ERR(CHAIN)
      |
      |### `PIPES_GET_LAST(CHAIN)`
    INPUT
      |<h3 id="macros"><a name="macros" href="#macros" class="md2man-permalink" title="permalink"></a>Macros</h3><pre><code>#define PIPES_GET_LAST(CHAIN)
      |#define PIPES_GET_IN(CHAIN)
      |#define PIPES_GET_OUT(CHAIN)
      |#define PIPES_GET_ERR(CHAIN)
      |</code></pre>
      |<h3 id="pipes_get_last-chain"><a name="pipes_get_last-chain" href="#pipes_get_last-chain" class="md2man-permalink" title="permalink"></a><code>PIPES_GET_LAST(CHAIN)</code></h3>
    OUTPUT
  end
end
