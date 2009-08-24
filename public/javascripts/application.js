function pick(set) {
	var i = Math.round((set.length - 1) * Math.random());
	return set[i];
}

function initHomepageHeaders(){
	var homepage = $('blog-index');
	if (!homepage) return;

	var headerA = homepage.down('h2#long-entries');
	var headerB = homepage.down('h2#short-entries');
	if (headerA && headerB) {
		var strings = pick([
			['Verbosity', 'Concision'],
			['Long', 'Short'],
			['Long &amp; Straggly', 'Short &amp; Curly'],
			['Long &amp; Winding', 'Short &amp; Sweet'],
			['Paragraphs', 'Sentences'],
			['Diatribes', 'Epithets'],
			['Here', 'There'],
			['Hither', 'Thither'],
			['Home', 'Away'],
			['This', 'That'],
			['Tomes', 'Pamphlets'],
			['Slow &amp; Laborious', 'Quick &amp; Easy'],
			['Rarely', 'Often'],
			['Banquets', 'Snacks'],
			['Weblog', 'Linklog']
		]);
		headerA.update(strings[0]);
		headerB.update(strings[1]);
	}
}

function initSlugField() {
	var fieldA = $('entry_title');
	var fieldB = $('entry_slug');
	if (fieldA && fieldB) {
		function generateSlug(){
			var val = fieldA.value.toLowerCase();
			val = val.replace(/i've been [^:]*: /,''); // Reviews
			val = val.replace(/[^a-z0-9._ ]+/g,'').replace(/ +/g,'-');
			val = val.split('-').slice(0,3).join('-');
			fieldB.value = val;
		}
		fieldA.observe('keyup',generateSlug);
		generateSlug();
	}
}

function initCodeLineNumbers() {
	$$('pre.code code').each(function(code){
		var nodes = code.childNodes;
		var count = 1;
		var lines = [];
		for (var i=0; i<nodes.length; i++) {
			if (nodes[i].nodeType != 3) continue;
			var matches = nodes[i].nodeValue.match(/[\r\n]/g);
			if (matches) count += matches.length;
		}
		for (var i=1; i<count; i++) { lines.push(i); }
		code.up().insert({before:'<pre class="line"><code>'+lines.join("\n")+'</code></pre>'});
	});
}

document.observe('dom:loaded',function(){
	initCodeLineNumbers();
	initHomepageHeaders();
	initSlugField();
});
