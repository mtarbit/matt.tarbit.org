function initSlugField() {
    var a = $('#entry_title');
    var b = $('#entry_slug');
    a.keyup(function(){
        var val = a.val().toLowerCase();
        val = val.replace(/i've been [^:]*: /,''); // Reviews
        val = val.replace(/[^a-z0-9._ ]+/g,'').replace(/ +/g,'-');
        val = val.split('-').slice(0,3).join('-');
        b.val(val);
    }).keyup();
}

function initCodeLineNumbers() {
    $('pre.code').each(function(code){
        var nodes = $(this).find('code').get(0).childNodes;
        var count = 1;
        var lines = [];

        for (var i=0; i<nodes.length; i++) {
            if (nodes[i].nodeType != 3) continue;
            var matches = nodes[i].nodeValue.match(/[\r\n]/g);
            if (matches) count += matches.length;
        }

        for (var i=1; i<count; i++) {
            lines.push(i);
        }

        $(this).prepend('<pre class="line"><code>'+lines.join("\n")+'</code></pre>');
    });
}

function initVideoLink() {
    $('body#entry-read .video-link').click(function(e){
        $('.video-player').show();
        e.preventDefault();
    });
}

function initImages() {
    var re = /_t\.jpg$/;
    $('div.img a').each(function(){
        var link = $(this);
        var img = link.find('img');
        var src = img.attr('src');
        if (src && re.test(src)) {
            link.attr('href', src.replace(re, '.jpg'));
            link.click(function(e){ window.open(this.href); e.preventDefault(); });
        }
    })
}

$(function(){
    initCodeLineNumbers();
    initSlugField();
    initVideoLink();
});
