/*

Oxygen WebHelp Plugin
Copyright (c) 1998-2017 Syncro Soft SRL, Romania.  All rights reserved.

*/

var searchLoaded = true;

// Controls the transitions between main tabs.
// Should be no effect there.
 $(document).bind('pageinit', function(){     
    $("a[data-role=tab]").each(function () {
        var anchor = $(this);
        anchor.bind("click", function () {
            $($('.ui-page-active form :input:visible')[0]).focus();
        });
    });
    
    // Controls the swipe distance.
    var swipeDistance = screen.width * 2/5;
		$.event.special.swipe.horizontalDistanceThreshold = swipeDistance;
 });

/**
 * @description Search using Google Search if it is available, otherwise use our search engine to execute the query
 * @return {boolean} Always return false
 */
function executeQuery() {
	var input = document.getElementById('textToSearch');
	try {
		var element = google.search.cse.element.getElement('searchresults-only0');
	} catch (e) {
		debug(e);
	}
	if (element != undefined) {
		if (input.value == '') {
			element.clearAllResults();
		} else {
			element.execute(input.value);
		}
	} else {
		searchRequest('wh-mobile');
	}
	$("#search").trigger('click');
	return false;
}

// Avoid presenting the error twice.
var chromeErrorShown = false;
// Check if is Google Chrome with local files
var notLocalChrome = true;
var addressBar = window.location.href;
if ( window.chrome && addressBar.indexOf('file://') === 0 ){
    notLocalChrome = false;
}

$(document).bind('pageshow', function() {

    // Focus the first input in the page.
//    $($('.ui-page-active form :input:visible')[0]).focus();

    // Display an error message, for Google Chrome for local files.
    if ( !notLocalChrome && !chromeErrorShown){
        $.mobile.loading('show',
            {
                theme: $.mobile.pageLoadErrorMessageTheme,
                text: "Please move the generated WebHelp output to a web server, "+
                    "or use another browser. Google Chrome does not handle this " +
                    "kind of output stored locally on the file system.",
                textVisible: true,
                textonly: true
            }
        );
        chromeErrorShown = true;
    }
});

// Declare the function for open and highlight, but disable it.
function openAndHighlight(){
    return true;    
}

/**
 * @description Remove highlight from right frame, except in Chrome when is opened locally
 */
function clearHighlights() {
    return true;
}