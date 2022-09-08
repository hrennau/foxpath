// Add some Bootstrap classes when document is ready
var highlighted = false;

$(document).ready(function () {

    var searchQuery = '';
    try {
        searchQuery = getParameter('searchQuery');
        searchQuery = decodeURIComponent(searchQuery);
        searchQuery = searchQuery.replace(/\+/g, " ");
        if (searchQuery!='' && searchQuery!==undefined && searchQuery!='undefined') {
            $('#textToSearch').val(searchQuery);
            executeQuery();
        }
    } catch (e) {
        debug(e);
    }

    // If we have a contextID, we must to redirect to the corresponding topic
    var contextId = getParameter('contextId');
    var appname = getParameter('appname');

    if ( contextId != undefined && contextId != "") {
        var scriptTag = document.createElement("script");
        scriptTag.type = "text/javascript";
        scriptTag.src = "context-help-map.js";
        document.getElementsByTagName('head')[0].appendChild(scriptTag);

        var ready = setInterval(function () {
                if (helpContexts != undefined) {
                    for(var i = 0; i < helpContexts.length; i++) {
                        var ctxt = helpContexts[i];
                        if (contextId == ctxt["appid"] && (appname == undefined || appname == ctxt["appname"])) {
                            var path = ctxt["path"];
                            if (path != undefined) {
                                window.location = path;
                            }
                            break;
                        }
                    }
                    clearInterval(ready);
                }
        }, 100);
    }

    // Navigational links and print
    $('#topic_navigation_links .navprev>a').addClass("glyphicon glyphicon-arrow-left");
    $('#topic_navigation_links .navnext>a').addClass("glyphicon glyphicon-arrow-right");
    $('.wh_print_link a').addClass('glyphicon glyphicon-print');
	
	// Hide sideTOC when it is empty
    var sideToc = $('#wh_side_toc');
    if (sideToc !== undefined) {
        var sideTocChildren = sideToc.find('*');
        if (sideTocChildren.length == 0) {
            sideToc.css('display', 'none');

            // The topic content should span on all 12 columns
            sideToc.removeClass('col-lg-4 col-md-4 col-sm-4 col-xs-12');
            var topicContentParent = $('.wh_topic_content').parent();
            if (topicContentParent !== undefined) {
                topicContentParent.removeClass(' col-lg-8 col-md-8 col-sm-8 col-xs-12 ');
                topicContentParent.addClass(' col-lg-12 col-md-12 col-sm-12 col-xs-12 ');
            }
        } else {
            /* WH-1518: Check if the tooltip has content. */
            var emptyShortDesc = sideToc.find('.topicref .wh-tooltip .shortdesc:empty');
            if (emptyShortDesc.length > 0) {
                var tooltip = emptyShortDesc.closest('.wh-tooltip');
                tooltip.remove();
            }
        }
    }

    // WH-1518: Hide the Breadcrumb tooltip if it is empty.
    var breadcrumb = $('.wh_breadcrumb');
    var breadcrumbShortDesc = breadcrumb.find('.topicref .wh-tooltip .shortdesc:empty');
    if (breadcrumbShortDesc.length > 0) {
        var tooltip = breadcrumbShortDesc.closest('.wh-tooltip');
        tooltip.remove();
    }

    $(".wh_main_page_toc .wh_main_page_toc_accordion_header").click(function(event) {
        if ($(this).hasClass('expanded')) {
            $(this).removeClass("expanded");
        } else {
            $(".wh_main_page_toc .wh_main_page_toc_accordion_header").removeClass("expanded");
            $(this).addClass("expanded");
        }

        event.stopImmediatePropagation();
        return false;
    });

    $(".wh_main_page_toc a").click(function(event) {
        event.stopImmediatePropagation();
    });

    highlightSearchTerm();
    
    
    /* 
    * Codeblock copy to clipboard action
    */
    $('.codeblock').mouseover(function(){
        var item = $('<span class="copyTooltip"/>');
        if ( $(this).find('.copyTooltip').length == 0 ){
            $(this).prepend(item);

            $('.codeblock .copyTooltip').click(function(){
                var txt = $(this).closest(".codeblock").text();
                if(!txt || txt == ''){
                    return;
                }
                copyTextToClipboard(txt);
            });
        }
    });

    $('.codeblock').mouseleave(function(){
        $('.copyTooltip').tooltip('hide');
        $(this).find('.copyTooltip').remove();
    });

    /**
     * Check to see if the window is top if not then display button
     */
    $(window).scroll(function(){
        if ($(this).scrollTop() > 5) {
            $('#go2top').fadeIn('fast');
        } else {
            $('#go2top').fadeOut('fast');
        }
    });

    /**
     * Click event to scroll to top
     */
    $('#go2top').click(function(){
       $('html, body').animate({scrollTop : 0},800);
       
       return false;
    });
});

/**
 * @description Copy the text to the clipboard
 */
function copyTextToClipboard(text) {
    var textArea = document.createElement("textarea");
    textArea.style.position = 'fixed';
    textArea.value = text;
    document.body.appendChild(textArea);
    textArea.select();
    try {
        var successful = document.execCommand('copy');

        $('.copyTooltip').tooltip({
            title: 'Copied to clipboard',
            trigger: "manual"
        }).tooltip('show');

        setTimeout(function(){ $('.copyTooltip').tooltip('hide'); }, 3000);

    } catch (err) {
        // Unable to copy
        $('.copyTooltip').tooltip({title: 'Oops, unable to copy', trigger: "click"});
    }
    document.body.removeChild(textArea);
}



/**
 * @description Log messages and objects value into browser console
 */
function debug(message, object) {
    object = object || "";
    console.log(message, object);
}

/**
 * @description Highlight searched words
 */
function highlightSearchTerm() {
    debug("highlightSearchTerm()");
    if (highlighted) {
        return;
    }
    try {
        var $body = $('.wh_topic_content');
        var $relatedLinks = $('.wh_related_links');
				var $childLinks = $('.wh_child_links');

        // Test if highlighter library is available
        if (typeof $body.removeHighlight != 'undefined') {
            $body.removeHighlight();
            $relatedLinks.removeHighlight();

            var hlParameter = getParameter('hl');
            if (hlParameter != undefined) {
                var jsonString = decodeURIComponent(String(hlParameter));
                debug("jsonString: ", jsonString);
                if (jsonString !== undefined && jsonString != "") {
                    var words = jsonString.split(',');
                    debug("words: ", words);

                    for (var i = 0; i < words.length; i++) {
                        debug('highlight(' + words[i] + ');');
                        $body.highlight(words[i]);
                        $relatedLinks.highlight(words[i]);
                        $childLinks.highlight(words[i]);
                    }
                }
            }
        } else {
            // JQuery highlights library is not loaded
        }
    }
    catch (e) {
        debug (e);
    }
    highlighted = true;
}

/**
 * @description Returns all available parameters or empty object if no parameters in URL
 * @return {Object} Object containing {key: value} pairs where key is the parameter name and value is the value of parameter
 */
function getParameter(parameter) {
    var whLocation = "";

    try {
        whLocation = window.location;
        var p = parseUri(whLocation);

        for (var param in p.queryKey) {
            if (p.queryKey.hasOwnProperty(param) && parameter.toLowerCase() == param.toLowerCase()){
                return p.queryKey[param];
            }
        }
    } catch (e) {
        debug(e);
    }
}


/*
 * Hide the highlight of the search results
 */
$('.wh_hide_highlight').click(function(){
    $('.highlight').addClass('wh-h');
    $('.wh-h').toggleClass('highlight');
    $(this).toggleClass('hl-close');
});

/*
 * Show the highlight button only if 'hl' parameter is found
 */
if( getParameter('hl')!= undefined ){
    $('.wh_hide_highlight').show();
}




/**
 * Open the link from top_menu when the current group is expanded.
 *
 * Apply the events also on the dynamically generated elements.
 */
$(document).on('click', ".wh_top_menu li", function (event) {
    $(".wh_top_menu li").removeClass('active');
    $(this).addClass('active');
    $(this).parents('li').addClass('active');
    event.stopImmediatePropagation();
});


$(document).on('click', '.wh_top_menu a', function (event) {
    var isTouchEnabled = false;
    try {
        if (document.createEvent("TouchEvent")) {
            isTouchEnabled = true;
        }
    } catch (e) {
        debug(e);
    }
    if ($(window).width() < 767 || isTouchEnabled) {
        var areaExpanded = $(this).closest('li');
        var isActive = areaExpanded.hasClass('active');
        var hasChildren = areaExpanded.hasClass('has-children');
        if (isActive || !hasChildren) {
            window.location = $(this).attr("href");
            event.preventDefault();
            event.stopImmediatePropagation();
            return false;
        } else {
            event.preventDefault();
        }
    } else {
        return true;
    }
});