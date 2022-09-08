/*

 Oxygen WebHelp Plugin
 Copyright (c) 1998-2017 Syncro Soft SRL, Romania.  All rights reserved.
 
 */

/**
 * start, last, dif used for display date in logs when debug mode enabled
 * @description Time elapsed from last registered log until current log
 * @type {number}
 */
var dif = 0;
/**
 * @description Time when current log occurred
 * @type {number}
 */
var last = 0;
/**
 * @description Time when first log occurred
 * @type {number}
 */
var start = 0;

var isInstaller;

/**
 * @description Array - stores the htpath and baseUrl
 * @type {Object}
 */
var conf = null;

/**
 * @description Log messages
 * @param msg
 */
function logLocal(msg) {
    var date = new Date();
    if (start == 0) {
        start = date.getTime();
    }
    dif = date.getTime() - last;
    last = date.getTime();
    var total = last - start;
    console.log(total + ":" + dif + " " + msg);
}

/**
 * Define debug(msg, obj) function
 */
if (typeof debug !== 'function') {
    function debug(msg, obj) {
        logLocal(msg, obj);
    }
}

/**
 * Define error(msg, obj) function
 */
if (typeof error !== 'function') {
    function error(msg, obj) {
        logLocal(msg, obj);
    }
}

/**
 * Define info(msg, obj) function
 */
if (typeof info !== 'function') {
    function info(msg, obj) {
        logLocal(msg, obj);
    }
}

/**
 * Define warn(msg, obj) function
 */
if (typeof warn !== 'function') {
    function warn(msg, obj) {
        logLocal(msg, obj);
    }
}

/**
 * @description Converts object to string
 * @param obj
 * @returns {string}
 */
function objToString(obj) {
    var str = '';
    for (var p in obj) {
        if (obj.hasOwnProperty(p)) {
            str += p + '::' + obj[p] + '\\n';
        }
    }
    return str;
}

$.ajaxSetup({
    cache: true,
    timeout: 60000,
    error: function (jqXHR, errorType, exception) {
        error("[AJX] error :[" + jqXHR.status + ":" + jqXHR.responseText + "]:" + errorType + ":" + objToString(exception));
    },
    complete: function (jqXHR, textStatus) {
        if (textStatus != "success") {
            //console.log(\"?complete :\"+jqXHR+\":\"+textStatus);
        }
    }
});

window.onerror = function (msg, url, line) {
    console.log("[JS]: " + msg + " in page: " + url + " at line: " + line);
};


/**
 * New implementation
 */
var wh = parseUri(window.location);
var whUrl = wh.protocol + '://' + wh.authority + wh.directory;
var pageName = wh.file;
var whDirectory = wh.directory;

function getDepth(relPath) {
    debug("getDepth(" + relPath + ");");
    var toReturn = "";

    var split = relPath.split("/");
    for (var i = 0; i < split.length; i++) {
        if (split[i] !== "") {
            toReturn += "../";
        }
    }

    return toReturn;
}

isInstaller = true;

function getLocalization(localizationKey) {
    var toReturn = localizationKey;
    if (localizationKey in localization) {
        toReturn = localization[localizationKey];
    }
    return toReturn;
}

/**
 * @description Page associated with comments
 */
var pagePath;

/**
 * @description Initialize comments
 *              Calculate htpath and baseUrl. Ex: For http://www.example.com/webhelp/topics/intro.html page the htpath is /webhelp/ and the baseUrl is
 *              http://www.example.com/webhelp/
 * @param page Relative path to the WebHelp root directory
 */
function init(page, feedbackDestination) {
    debug("init(" + page + ");");
    pagePath=page;
    var scripts = $('script[src*="/init.js"]');
    var source = scripts[0].src;
    var searchString = "resources/js/init.js";
    var baseURL = source.substring(0, source.indexOf(searchString));
    try {
        var parsedUrl = parseUri(baseURL);
    } catch (e) {
        debug(e);
    }
    var relPath = parsedUrl.directory;

    var depth;
    if (relPath.lastIndexOf("/")==relPath.length-1) {
        depth = relPath.substring(0, relPath.length-1);
    } else {
        depth = relPath;
    }

    conf = {"htpath": relPath, "baseUrl": baseURL};
    var url = depth + "/resources/php/cmts.php";
    var data = "&depth=" + depth + "&isInstaller=" + isInstaller;

    if (window.location.href.indexOf('file://') !== 0) {
        loadBootstrap(depth);

        $.ajax({
            type: "POST",
            url: url,
            data: data,
            success: function (data_response) {
                try {
                    $(feedbackDestination).html(data_response);
                } catch (e) {
                    debug(e);
                }
            }
        });
    }
}

/**
 * @description Load Bootstrap resources. Resources will be loaded only if necessary, if Bootstrap is not already included.
 * @param depth Relative path of the "feedback" directory
 */
function loadBootstrap(depth) {
    $(document).ready(function(){
        var link;
        if (!$("link[href*='/bootstrap.min.css']").length) {
            link = document.createElement("link");
            link.rel = "stylesheet";
            link.type = "text/css";
            link.media= "screen";
            link.href = depth + "/resources/bootstrap/css/bootstrap.min.css";

            document.getElementsByTagName("head")[0].appendChild(link);
        }

        if (!$("link[href*='/bootstrap-theme.min.css']").length) {
            link = document.createElement("link");
            link.rel = "stylesheet";
            link.type = "text/css";
            link.media= "screen";
            link.href = depth + "/resources/bootstrap/css/bootstrap-theme.min.css";

            document.getElementsByTagName("head")[0].appendChild(link);
        }

        if (!$("script[src*='/bootstrap.min.js']").length) {
            var script = document.createElement("script");
            script.type = "text/javascript";
            script.src = depth + "/resources/bootstrap/js/bootstrap.min.js";

            document.getElementsByTagName("head")[0].appendChild(script);
        }
    });
}

//init(whUrl+pageName);
