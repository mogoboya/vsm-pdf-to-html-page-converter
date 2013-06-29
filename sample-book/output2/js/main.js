$( document ).ready(function() {
	
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
				$this.css('transition', 'left .05s ease-out 0s top .05s ease-out 0s font-size .05s ease-out 0s');
				$this.css('webkit-transition', 'left .05s ease-out 0s top .05s ease-out 0s font-size .05s ease-out 0s');
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

