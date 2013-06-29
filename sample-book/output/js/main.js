$( document ).ready(function() {
	var QueryString = function () {
		var query_string = {};
		var query = window.location.search.substring(1);
		var vars = query.split("&");
		for (var i=0;i<vars.length;i++) {
			var pair = vars[i].split("=");
			if (typeof query_string[pair[0]] === "undefined") {
				query_string[pair[0]] = pair[1];
			} else if (typeof query_string[pair[0]] === "string") {
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
		QueryString.pageid = "01";
	}
	
	if (parseInt(QueryString.pageid) === 1) {
		 $('#back').removeClass('invisible_link');
	} else {
		var back = parseInt(QueryString.pageid) - 1 + "";
		while (back.length < 2) back = "0" + back;
		 $('#back').click(function(){
			 window.location = './shell.html?pageid=' + back;
		 });
	}
		  
	if (parseInt(QueryString.pageid) === 6) {
		 $('#forward').removeClass('invisible_link');
	} else {
		var forward = parseInt(QueryString.pageid) + 1 + "";
		while (forward.length < 2) forward = "0" + forward;
		 $('#forward').click(function(){
			 window.location = './shell.html?pageid=' + forward;
		 });
	}
});

