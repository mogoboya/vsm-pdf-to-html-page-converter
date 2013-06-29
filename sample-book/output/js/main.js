$( document ).ready(function() {
	// Parse url parameters
	var QueryString = function () {
		var query_string = {};
		var query = window.location.search.substring(1);
		var vars = query.split('&');
		for (var i=0;i<vars.length;i++) {
			var pair = vars[i].split('=');
			if (typeof query_string[pair[0]] === 'undefined') {
				query_string[pair[0]] = pair[1];
			} else if (typeof query_string[pair[0]] === 'string') {
				var arr = [ query_string[pair[0]], pair[1] ];
				query_string[pair[0]] = arr;
			} else {
				query_string[pair[0]].push(pair[1]);
			}
		}
		return query_string;
	} ();
	
	if (parseInt(QueryString.pageid) > 0 && parseInt(QueryString.pageid) < 7) {
		$('#page_inset').attr('src', 'page-' + QueryString.pageid + '.html');
	} else {
		QueryString.pageid = '01';
	}
	
	// Add forward/back navigation
	if (parseInt(QueryString.pageid) === 1) {
		 $('#back').removeClass('invisible_link');
	} else {
		var back = parseInt(QueryString.pageid) - 1 + '';
		while (back.length < 2) back = '0' + back;
		 $('#back').click(function(){
			 window.location = './shell.html?pageid=' + back;
		 });
	}
	
	// Add forward/back navigation
	if (parseInt(QueryString.pageid) === 6) {
		 $('#forward').removeClass('invisible_link');
	} else {
		var forward = parseInt(QueryString.pageid) + 1 + '';
		while (forward.length < 2) forward = '0' + forward;
		 $('#forward').click(function(){
			 window.location = './shell.html?pageid=' + forward;
		 });
	}
	
	// Hide text until the background image loads
	$('span').each(function () {
		$(this).css('display', 'hidden');
	});
	
	// Initialize word lookup table
	var lookupTable = {};
	
	// Place text / resize and reposition text on window resize
	var placeText = function() {
		var nativeW = document.getElementById('bg-image').naturalWidth; // eg 500
		var nativeH = document.getElementById('bg-image').naturalHeight; // eg 1000
		var currW = ($(this).width()); // zoomed in to 1.5x - 750
		var sizeRatio = currW / nativeW; // eg 1.5
		var currH = sizeRatio * nativeH; // 1.5 * 1000 = 1500
		$('span').each(function () {
			var $this = $(this);
			var newX, newY, newSize;
			var id = $this.attr('id');
			// Check lookupTable if ID has been defined
			if (!(lookupTable[id])) {
				var origX = parseFloat($this.css('left'),10);
				var origY = parseFloat($this.css('top'),10);
				var origSize = parseFloat($this.css('font-size'),10);
				lookupTable[id] = {'x' : origX, 'y': origY, 'size': origSize};
				$this.css('transition', 'all .02s ease-out');
				$this.css('webkit-transition', 'all .02s ease-out');
			}
			newX = lookupTable[id].x * sizeRatio;
			newY = lookupTable[id].y * sizeRatio;
			newSize = lookupTable[id].size * sizeRatio;
			$this.css('left', newX + 'px');
			$this.css('top', newY + 'px');		
			$this.css('font-size', newSize + 'px');		
			$this.css('display', 'block');
		});
	};
	
	// Place and size text as soon as the background image loads, then again on every window resize.
	$('#bg-image').load(placeText);
	$(window).resize(placeText);
});

