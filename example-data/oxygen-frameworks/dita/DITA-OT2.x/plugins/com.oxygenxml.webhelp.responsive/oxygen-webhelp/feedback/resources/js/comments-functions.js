/*

 Oxygen WebHelp Plugin
 Copyright (c) 1998-2017 Syncro Soft SRL, Romania.  All rights reserved.
 
 */

/**
 * init.js must be included before and var conf must be defined after call of init();
 */

/**
 * @description Browser URL including query
 * @type {string}
 */
var pageSearch = window.location.href;

/**
 * @description Browser URL hash (anchor)
 * @type {string}
 */
var pageHash = window.location.hash;

/**
 * @description TRUE if authenticated user is moderator, FALSE otherwise
 * @type {boolean}
 */
var isModerator = false;

/**
 * @description TRUE if anonymous user, FALSE otherwise
 * @type {boolean}
 */
var isAnonymous = false;
var pathName = window.location.pathname;

/**
 * @description Element id to scroll to after AJAX execution
 * @type {string}
 */
var scrollAfterAjax = null;

/**
 * @description Comments position: 0 - invisible; 1 - partial visible; 2 - full visible
 * @type {number}
 */
var commentsPosition = 0; // default 0 not visible

/**
 * @description TRUE if Add New Comment is available, FALSE otherwise
 * @type {boolean}
 */
var showAddNewComment = true;

/**
 * @description Browser URL without query and hash
 * @type {string}
 */
var pageWSearch = pagePath;

/**
 * @description Last message from preload DIV
 * @type {null}
 */
var lastPreloadMessage = null;

/**
 * @description Array with all scripts from page
 * @type {HTMLElement}
 */
var scripts = $("script");
src = scripts[scripts.length - 1].src;
src = src.substring(src.lastIndexOf('/') + 1);

/**
 * @description debug function used for display messages in DEBUG mode
 */
if (typeof debug !== 'function') {
    function debug(msg, obj) {
        if (top !== self) {
            if (typeof parent.debug !== 'function') {
                //
            } else {
                parent.debug("[" + src + ']' + msg, obj);
            }
        } else {
            // local log
        }
    }
}

/**
 * @description info function used for display messages in INFO mode
 */
if (typeof info !== 'function') {
    function info(msg, obj) {
        if (top !== self) {
            if (typeof parent.info !== 'function') {
                //
            } else {
                parent.info("[" + src + ']' + msg, obj);
            }
        } else {
            // local log
        }
    }
}

/**
 * @description warn function used for display messages in WARN mode
 */
if (typeof warn !== 'function') {
    function warn(msg, obj) {
        if (top !== self) {
            if (typeof parent.warn !== 'function') {
                //
            } else {
                parent.warn("[" + src + ']' + msg, obj);
            }
        } else {
            // local log
        }
    }
}

/**
 * @description error function used for display messages in ERROR mode
 */
if (typeof error !== 'function') {
    function error(msg, obj) {
        if (top !== self) {
            if (typeof parent.error !== 'function') {
                //
            } else {
                parent.error("[" + src + ']' + msg, obj);
            }
        } else {
            // local log
        }
    }
}

window.onerror = function (msg, url, line) {
    error("[JS]: " + msg + " in page: " + url + " al line: " + line);
};

/**
 * @description Initiate new comment form
 */
function initNewComment() {
    if ($("#newComment").parent().get(0).tagName != "BODY") {
        $("#newComment").appendTo("body");
    }
    if (showAddNewComment) {
        $('#commentTitle').html(getLocalization('newPost'));
        $('#newComment').show();
    }
    refreshEditor();
    $("#commentText").cleditor()[0].clear();
    $('#newComment').hide();
}

/**
 * @description Used for internationalization.
 * @param localizationKey
 * @returns translated @localizationKey
 */
function getLocalization(localizationKey) {
    var toReturn = localizationKey;
    if ((localizationKey in localization)) {
        toReturn = localization[localizationKey];
    }

    return toReturn;
}

/**
 * @description Reset data from forms
 */
function resetData() {
    $('#loginData').hide();
    initNewComment();
    if ($("#newComment").parent().get(0).tagName != "BODY") {
        $("#newComment").appendTo("body");
    }

    $('#commentTitle').html(getLocalization('newPost'));
    $('#newComment').hide();
    $('#signUp').hide();
    $('#editedId').val("");
    $('#u_Profile').hide();
    $("#u_Profile input").attr("type", function (arr) {
        var inputType = $(this).attr("type");
        if (inputType == "text" || inputType == "password") {
            $(this).val("");
        }
    });
    $('#recoverPwd').hide();
    if ($("#confirmDelete").parent().get(0).tagName != "BODY") {
        $("#confirmDelete").appendTo("body").hide();
        $("#commentToDelete").html('');
    }

    $("#newComment textarea").val("");
    $("#loginResponse").html("");
    $("#loginData input").attr("type", function (arr) {
        var inputType = $(this).attr("type");
        if (inputType == "text" || inputType == "password") {
            $(this).val("");
        }
    });
}

/**
 * @description Check if webhelp system is installed
 * @returns {boolean}
 */
function checkConfig() {
    var page = conf.htpath + "resources/php/checkInstall.php";

    var response = false;

    $.ajax({
        type: "POST",
        url: page,
        data: "",
        async: false,
        success: function (data_response) {
            debug('check page:' + page);
            var config = eval("(" + data_response + ")");
            if (config.installPresent == "true" && config.configPresent == "true") {
                $("#commentsContainer").parent().append("<div id='fbUnavailable'>" + getLocalization('label.fbUnavailable') + "<br/>" + getLocalization('label.removeInst') + "</div>");
                $("#commentsContainer").hide().remove();
                debug('showComments() - red');
            } else if (config.configPresent == "true") {
                response = true;
                // show comments
            } else {
                debug('Redirect to Install ...');
                $('#bt_logIn').hide();
                $('#bt_signUp').hide();
                $('#bt_new').hide();
                $('#cm_title').append(' - ' + getLocalization('configInvalid'));
                window.parent.location.href = conf.htpath + "install/";
            }
        }
    });
    debug('checkConfig() -', response);

    return response;
}

/**
 * @description Load and display comments
 */
function showComments(pagePath) {
    debug('showComments('+pagePath+')');
    hideAll();
    displayUserAccount();
    if ($('#comments') && (!lastCmdLocation)) {
        lastCmdLocation = $('#comments').css('top');
    }
    showPreload(getLocalization('label.plsWaitCmts'));
    resetData();
    var processComments = conf.htpath + "resources/php/showComments.php";
    var page = {page: pagePath, productName: productName, productVersion: productVersion};

    $.ajax({
        type: "POST",
        url: processComments,
        contentType: "application/x-www-form-urlencoded",
        data: page,
        success: function (data_response) {
            hidePreload();
            var $oldComments = $('#oldComments');
            $oldComments.html(data_response).show();
            var count = $(".commentStyle").children('li').length;
            var toApprove = $("li .bt_approve").length;
            if (isModerator && count > 0 && toApprove > 0) {
                $("#approveAll").show();
            } else {
                $("#approveAll").hide();
            }
            if (count > 0) {
                $('#cm_count').html(count);
            } else {
                $('#cm_count').html("");
            }
            if ($.trim(pageHash) != '') {
                window.location.href = pageHash;
            }
            if (scrollAfterAjax) {
                goToByScroll(scrollAfterAjax);
            }
            // Open links in new tab
            $oldComments.find('a').click(function (ev) {
                $(this).attr("target", "blank");
            });
        },
        error: function (data_response) {
            hidePreload();
        }
    });

    if (getParam('a') != '') {
        $("#loginResponse").html(getLocalization('recoveryConfirmation'));
        showLoggInDialog();
    }
}

/**
 * @description Get value of @name parameter
 * @param name
 * @returns Value of @name parameter
 */
function getParam(name) {
    var results = new RegExp('[\\?&]' + name + '=([^&#]*)').exec(window.location.href);
    if (results != null && results.length > 1) {
        return results[1];
    } else {
        return "";
    }
}

/**
 * @description Display user account information and buttons that apply to account type
 */
function displayUserAccount() {
    $("#cmt_info").removeClass('textError').removeClass('textInfo');
    var url = conf.htpath + "resources/php/checkUser.php";
    var data = "check=true&productName=" + productName + "&productVersion=" + productVersion + "&delimiter=|";

    $.ajax({
        type: "POST",
        url: url,
        data: data,
        success: function (data_response) {

            var response = eval("(" + data_response + ")");
            isAnonymous = (response.isAnonymous == 'true' ? true : false);
            showMessage(response);
            if (response.loggedIn == 'true') {
                if ($("html").attr("dir") != "rtl") {
                    $("#accountInfo").html( response.name);
                    $(".avatar_userName").html( response.userName);
                } else {
                    $("#accountInfo").html(response.name);
                    $(".avatar_userName").html( response.userName);
                }
                if (response.level == "admin" || response.level == "moderator") {
                    isModerator = true;
                    if (isModerator == true) {
                        if ($("#approveAll").parent().attr('id') != "bt_new") {
                            $("#approveAll").appendTo('#bt_new');
                        }
                    }
                    if ($("html").attr("dir") != "rtl") {
                        $("#accountInfo").append(" <span class='level'>" + getLocalization("label." + response.level) + "</span>");
                    } else {
                        $("#accountInfo").html(" <span class='level'>" + getLocalization("label." + response.level) + "</span>" + $("#accountInfo").html());
                    }
                } else {
                    isModerator = false;
                }
                if (response.level != "user" && $('#adminLink').length < 1) {
                    $("#show_profile").find('#divider-admin').after("<li><a href='#' id='adminLink' onclick='setLastPage(); window.location=\"" + conf.htpath + "resources/admin.html\"' >" + getLocalization("label.adminPanel") + "</a></li>");
                }

                if (isAnonymous) {
                    $('#userAccount #show_profile').hide();
                    $('#bt_editProfile').hide();
                    $("#userAccount").show();
                    $('#userAccount #bt_logIn').show();
                    $('#userAccount #bt_signUp').show();
                    $("#loginData").hide();
                    $("#o_captcha").show();
                } else {
                    $("#o_captcha").hide();
                    $("#userAccount").show();
                    $('#userAccount #show_profile').show();
                    $('#userAccount #bt_logIn').hide();
                    $('#userAccount #bt_signUp').hide();
                    $('#bt_editProfile').show();
                    $("#loginData").hide();
                }
                if (response.minVisibleVersion <= productVersion) {
                    $('#bt_new').show();
                }
                showAddNewComment = true;
                //loggin to moderatePost
                if (getParam('l') != '') {
                    $("#loginResponse").html(getLocalization('label.logAdmin'));
                    showLoggInDialog();
                }
            } else {
                $("#accountInfo").html(getLocalization("label.guest"));
                $('#userAccount #show_profile').hide();
                $('#userAccount #bt_logIn').show();
                $('#userAccount #bt_signUp').show();
                $("#userAccount").show();
                $('#newComment').hide();
                if (response.minVisibleVersion <= productVersion) {
                    $('#bt_new').show();
                }
                showAddNewComment = false;
            }
        }
    });
}

/**
 * @description Show message @response
 * @param response Message to be displayed
 */
function showMessage(response) {
    if (response.msgType) {
        if (response.msgType == 'error') {
            $("#cmt_info").addClass('textError').removeClass('textInfo');
        } else {
            $("#cmt_info").removeClass('textError').addClass('textInfo');
        }
        $("#cmt_info").html(getLocalization('checkUser.' + response.msg));
    }
}

/**
 * @description Write last page URL to cookie
 */
function setLastPage() {
    setCookie("backLink", window.location.href, 7);
}

/**
 * @description Check if user is logged on
 * @param button - Element clicked when invoked
 */
function checkUser(button) {
    debug("checkUser(" + button.attr('id') + ")");
    // check if user is logged on
    var processLogin = conf.htpath + "resources/php/checkUser.php";

    $("#loginResponse").html("");
    $.ajax({
        type: "POST",
        url: processLogin,
        data: "check=true&productName=" + productName + "&productVersion=" + productVersion + "&delimiter=|",
        success: function (data_response) {
            debug("checkUser.php=", data_response);
            var response = eval('(' + data_response + ')');
            isAnonymous = (response.isAnonymous == 'true' ? true : false);

            if ($("#newComment").parent().attr('id') != button.attr('id')) {
                $("#newComment").appendTo(button);
            }

            if ($("#recoverPwd").parent().attr('id') != button.attr('id')) {
                $("#recoverPwd").appendTo(button);
            }

            if (response.loggedIn == 'true') {
                $('#commentTitle').html(getLocalization('newPost'));
                showNewComment();
                refreshEditor();
                $("#commentText").cleditor()[0].clear();
            } else {
                isModerator = false;
                $("#signUp").hide();
                $("#recoverPwd").hide();
                showLoggInDialog();
            }
        }
    });
}

/**
 * @description Reply to other comment
 * @param element - Clicked button
 * @param commentId - ID of comment to reply to
 */
function reply(element, commentId) {
    hideAll();
    setScrollTo(commentId);
    $('#referedCmtId').val(commentId);
    $('#editedId').val('');
    checkUser($(element).parent());
    setTimeout("goToByScroll(" + commentId + ")", 100);
}

/**
 * @description Set scroll to after ajax execution on show comments
 * @param ids - element id to scroll to
 */
function setScrollTo(ids) {
    scrollAfterAjax = ids;
}

/**
 * @description Scroll to element with @id
 * @param id - the element id to scroll to
 */
function goToByScroll(id) {
    debug("goToByScroll(" + id + ")");
    var rowpos = $('#' + id).position();
    try {
        // IE
        $('html').scrollTop(rowpos.top);
        // FF Chrome
        $('body').scrollTop(rowpos.top);
    } catch (e) {
        debug(e);
    }
}

/**
 * @description Scroll to newComment element
 */
function goToNewComment() {
    debug("goToByScroll('newComment')");
    var windowHeight = $(window).height();
    var idHeight = $('#newComment').height();
    var diff = $(window).height() - idHeight - 30;

    var rowpos = $('#newComment').position();
    try {
        // IE
        $('html').scrollTop(eval(rowpos.top - diff));
        // FF Chrome
        $('body').scrollTop(eval(rowpos.top - diff));
    } catch (e) {
        debug(e);
    }
}

/**
 * {Refactored}
 * @description Show Reset Password dialog
 */
function showLostPwd() {
    $('#loginResponse').removeClass("textInfo").removeClass("textError").html("").hide();

    //reset email input text
    $("#recoverEmail").val("");
    $('#recoverPwdResponse').removeClass("textInfo").removeClass("textError").html("").hide();
    $('#recoverPwd').modal('show');
}

/**
 * @description Show/Hide replies
 * @param id - Comment ID
 */
function toggleReply(id) {
    var currentNode = "li#" + id;
    $(currentNode + " ul").slideToggle("1000");

    if ($("#toggle_" + id).attr('class') == 'minus') {
        $("#toggle_" + id).removeClass('minus').addClass('plus');
    } else {
        $("#toggle_" + id).removeClass('plus').addClass('minus');
    }
}

/**
 * @description Show confirm delete dialog
 * @param id - Id of comment to be deleted
 */
function showConfirmDeleteDialog(id) {
    hideAll();
    var confDialog = $("#confirmDelete");
    $("#confirmDelete").remove();
    var content = $("#cmt_text_" + id).html();
    $("#" + id + " .head").first().append(confDialog);
    $("#commentToDelete").html(content);
    $("#idToDelete").val(id);
    $("#bt_yesDelete").click(deleteComment);

    $('#confirmDelete').modal('show');

    /*$("#confirmDelete").css('top', 'auto');
    $("#confirmDelete").show();

    reposition('confirmDelete');*/
}

/**
 * @description Bind click events for confirmDelete dialog components
 */
/*
function attachEvents() {
    //debug("js 4");
    $("#bt_yesDelete").click(deleteComment);
    //debug("js 5");
    /!*$("#bt_noDelete").click(hideDeleteDialog);*!/
    //debug("js 5");
    /!*$(".bt_close").click(closeDialog);*!/
}
*/

/**
 * @description Reposition dialogs so that will be totally visible
 * @param id - Id of dialog to pe repositioned
 */
function reposition(id) {
    var pos = $('#' + id).position();
    var winH = $(window).height() - 55;
    var dialogH = $('#' + id).height();

    var scrollPos = $('body').scrollTop() || $('html').scrollTop();
    var bottomLimit = winH + scrollPos;
    var bottomDialog = pos.top + dialogH;

    var new_top = 0;

    if (dialogH < winH) {
        if (pos.top > scrollPos) {
            if (bottomLimit < bottomDialog) {
                new_top = pos.top - (bottomDialog - bottomLimit) - 10;
                $('#' + id).css('top', new_top);
            } else {
                // Leave dialog at its original position
            }
        }
    } else {
        // Leave dialog at its original position
    }
}

/**
 * @description Moderate comment (approve / delete)
 * @param id - Id of comment to be moderated
 * @param action - Action to pe performed
 * @returns {boolean} - TRUE if action performed successfully
 *                    - FALSE if action not performed
 */
function moderatePost(id, action) {
    if (action == 'suspended') {
        toggleReply(id);
    }
    $.ajax({
        type: "POST",
        url: conf.htpath + "resources/php/moderate.php",
        data: "uncodedId=" + id + "&action=" + action + '&product=' + productName + '&version=' + productVersion,
        success: function (data_response) {
            if (data_response != "") {
                setScrollTo(id);
                showComments(pagePath);
            } else {
                $("#cmt_info").html("Action not performed !");
            }
        }
    });
    return false;
}

/**
 * {Refactored}
 * @description Refresh CLEditor
 */
function refreshEditor() {
    if ($("html").attr("dir") != "rtl") {
        $("#commentText").cleditor({
            "width": "98%",
            "height": "300",
            controls: "bold italic underline strikethrough subscript superscript | font size " +
            "style | color highlight removeformat | bullets numbering | outdent " +
            "indent | alignleft center alignright justify | undo redo | " +
            "rule image link unlink | cut copy paste pastetext",
            styles: [["Paragraph", "<p>"], ["Preformatted", "<pre>"], ["Header 1", "<h1>"], ["Header 2", "<h2>"],
            ["Header 3", "<h3>"], ["Header 4", "<h4>"], ["Header 5", "<h5>"],
            ["Header 6", "<h6>"]]
        });
    } else {
        $("#commentText").cleditor({
            "width": "98%",
            "height": "300",
            bodyStyle: "direction:rtl",
            controls: "bold italic underline strikethrough subscript superscript | font size " +
            "style | color highlight removeformat | bullets numbering | outdent " +
            "indent | alignleft center alignright justify | undo redo | " +
            "rule image link unlink | cut copy paste pastetext"
        });
    }
    var editor = $("#commentText").cleditor()[0];
    editor.refresh().focus();
    editor.$area.hide();
    editor.$frame.show();
}

/**
 * @description Edit comment
 * @param id - Id of the comment to be edited
 */
function editPost(id) {
    hideAll();
    var comment = "#" + id + " div#cmt_text_" + id;
    var getComment = $(comment).html();
    if ($("#newComment").parent().attr('id') != 'c_' + id) {
        $('#newComment').appendTo("div#c_" + id);
    }
    $('#commentTitle').html(getLocalization('editPost'));
    $('#editedId').val(id);
    $('#referedCmtId').val('');
    $('#commentText').val(getComment);
    showNewComment();
    refreshEditor();
    setTimeout("goToNewComment()", 100);

}

/**
 * @description Show Edit Account dialog
 * @returns {boolean} return FALSE
 */
function showProfileChange(e) {
    e.preventDefault();
    
    var dataString = 'select=true' + '&delimiter=|&product=' + productName + '&version=' + productVersion;
    var processLogin = conf.htpath + "resources/php/profile.php";
    hideAll();
    $('#u_response').html('');
    $("#u_notify_page").attr('checked', true);
    /*$('#u_Profile').show();*/
    $('#u_Profile').modal('show');
    showPreload(getLocalization('label.plsWaitChProfile'));
    $.ajax({
        type: "POST",
        url: processLogin,
        data: dataString,
        success: function (data_response) {
            hidePreload();
            if (data_response != '') {
                var response = eval('(' + data_response + ')');
                if (response.isLogged == 'true') {
                    $("#u_name").val(response.name);
                    $("#u_email").val(response.email);
                    if (response.ldapUser == 'true') {
                        $("#u_name").attr('disabled', 'disabled');
                        $("#u_email").attr('disabled', 'disabled');
                        $("#u_pass").attr('disabled', 'disabled');
                        $("#u_pass1").attr('disabled', 'disabled');
                    } else {
                        $("#u_name").removeAttr('disabled');
                        $("#u_email").removeAttr('disabled');
                        $("#u_pass").removeAttr('disabled');
                        $("#u_pass1").removeAttr('disabled');
                    }
                    if (response.notifyPage == 'yes') {
                        $("#u_notify_page").attr('checked', true);
                    } else {
                        $("#u_notify_page").attr('checked', false);
                    }
                    if (response.notifyReply == 'yes') {
                        $("#u_notify_reply").attr('checked', true);
                    } else {
                        $("#u_notify_reply").attr('checked', false);
                    }
                    if (response.notifyAll == 'yes') {
                        $("#u_notify_all").attr('checked', true);
                    } else {
                        $("#u_notify_all").attr('checked', false);
                    }
                }
            } else {
                $('#u_Profile').show();
                $('#u_response').html('').show();
            }
        },
        error: function (data_response) {
            hidePreload();
        }
    });
    return false;
}

/**
 * @description Read Cookies
 * @param a - Cookie name
 * @returns {string} Value of cookie
 */
function readCookie(a) {
    var b = "";
    a = a + "=";
    if (document.cookie.length > 0) {
        offset = document.cookie.indexOf(a);
        if (offset != -1) {
            offset += a.length;
            end = document.cookie.indexOf(";", offset);
            if (end == -1)
                end = document.cookie.length;
            b = unescape(document.cookie.substring(offset, end));
        }
    }
    return b;
}

/**
 * @description Set Cookie
 * @param c_name - Cookie name
 * @param value - Cookie value
 * @param exdays - Days until cookie will expire
 */
function setCookie(c_name, value, exdays) {
    var exdate = new Date();
    exdate.setDate(exdate.getDate() + exdays);
    var c_value = escape(value) + ((exdays == null) ? "" : "; expires=" + exdate.toUTCString());
    document.cookie = c_name + "=" + c_value + "; path=/";
}

/**
 * @description Delete cookie
 * @param name - Cookie name
 */
function eraseCookie(name) {
    setCookie(name, "", -1);
}

/**
 * @description Show recover password dialog
 */
function recover() {
    var email = $("#recoverEmail").val();
    var username = $("#recoverUser").val();
    var dataString = 'userName=' + username + '&email=' + email + '&product=' + productName + '&version='
        + productVersion;
    showPreload(getLocalization('label.plsWaitRecover'));
    $.ajax({
        type: "POST",
        url: conf.htpath + "resources/php/recover.php",
        data: dataString,
        success: function (data_response) {
            setCookie("page", pagePath, 7);
            var response = eval("(" + data_response + ")");

            hidePreload();
            if (response.success == "true") {
                $("#recoverPwd input").attr("type", function (arr) {
                    var inputType = $(this).attr("type");
                    if (inputType == "text") {
                        $(this).val("");
                    }
                });

                showLoggInDialog();
                $('#loginResponse').addClass("textInfo");
                $("#loginResponse").html(response.message);
                $("#loginResponse").show();
                $('#newComment').hide();
            } else {
                $('#recoverPwd').show();
                $('#recoverPwdResponse').addClass("textError");
                $('#recoverPwdResponse').html(response.message).show();
            }
        },
        error: function (data_response) {
            hidePreload();
        }
    });
    return false;
}

/**
 * @description Process login form
 * @returns {boolean}
 */
function loggInUser(e) {
    // process form
    var userName = $("#myUserName").val();
    var password = $("#myPassword").val();
    var rememberMe = "no";
    if ($("#myRemember").is(':checked')) {
        rememberMe = "yes";
    }
    var dataString = '&userName=' + userName + '&password=' + password + "&productName=" + productName + "&productVersion=" + productVersion;
    var processLogin = conf.htpath + "resources/php/checkUser.php";

    if (userName != '' && password != '') {
        showPreload(getLocalization("label.plsWaitAuth"));
        $.ajax({
            type: "POST",
            url: processLogin,
            data: dataString,
            success: function (data_response) {
                var response = eval('(' + data_response + ')');
                if (typeof pageWSearch !== 'undefined' && window.location.href != pageWSearch) {
                    if (response.authenticated == 'false') {
                        hidePreload();
                        if (response.error) {
                            var msg = getLocalization('checkUser.loginError');
                            msg = msg + "<!--" + response.error + " -->";
                            $('#loginResponse').html(msg).show();
                        } else {
                            $('#loginResponse').html(getLocalization('checkUser.loginError')).show();
                        }
                    } else {
                        if (rememberMe == "yes") {
                            var pss = Base64.encode(userName + "|" + password);
                            setCookie("oxyAuth", pss, 14);
                        } else {
                            eraseCookie("oxyAuth");
                        }
                        $('#loginResponse').html("").hide();
                        $("#userAccount").show();

                        // old script - does redirect to reload page
                        // window.location.href = pagePath; 

                        // instead of loading only comments and user data
                        showComments(pagePath);
                        $('#loginData').modal('hide');
                    }
                } else {
                    hidePreload();
                    if (response.authenticated == 'true') {
                        $("#userAccount").hide();
                        $('#loginResponse').html("").hide();
                        if (isAnonymous) {
                            $('#bt_editProfile').hide();
                            $("#o_captcha").show();
                        } else {
                            $("#o_captcha").hide();
                        }
                        $('#userAccount #bt_logIn').hide();
                        $('#userAccount #bt_signUp').hide();
                        if ($('#reloadComments').val() == "true") {

                            showComments(pagePath);
                            $('#reloadComments').val("");
                            if (rememberMe == "yes") {
                                var pss = Base64.encode(userName + "|" + password);
                                setCookie("oxyAuth", pss, 14);
                            } else {
                                eraseCookie("oxyAuth");
                            }
                        } else {
                            $("#userAccount").show();
                            $('#newComment').show();
                            $("#commentText").cleditor();
                            $('#commentText').focus();
                            setTimeout("goToByScroll('l_bt_submit_nc')", 100);
                        }
                    } else {
                        if (response.error) {
                            var msg = getLocalization('checkUser.loginError');
                            msg = msg + "<!-- " + response.error + " -->";
                            $('#loginResponse').html(msg).show();
                        } else {
                            $('#loginResponse').html(getLocalization('checkUser.loginError')).show();
                        }
                    }
                }
            },
            error: function (jqXHR, textStatus, errorThrown) {
                hidePreload();
            }
        });
    }
    //return false; //false or the form will post your data to login.php
    return false;
}

/**
 * @description Close dialog
 * @returns {boolean} - FALSE
 */
function closeDialog() {
    $("#editedId").val("");
    $(this).parent().hide();
    return false;
}

/**
 * @description Show new comment form
 */
function showNewCommentDialog() {
    debug("showNewCommentDialog()");
    hideAll();
    setScrollTo('new_comment');
    checkUser($("#new_comment"));
    setTimeout("goToByScroll('l_bt_submit_nc')", 100);
}

/**
 * @description Display / Scroll to new added comment
 */
function showNewComment() {
    if (isAnonymous) {
        $(".realperson-regen").click();
        $("#defaultReal").val("");
        $("#defaultReal").html("");
    }
    $("#newComment").show();
    if (scrollAfterAjax) {
        goToByScroll(scrollAfterAjax);
    }
    $("#l_bt_submit_nc").prop("disabled", false);
}

/**
 * @description Verify CAPTCHA
 * @returns {boolean}
 */
function checkReal() {
    debug('checkReal()');
    if (isAnonymous) {
        var value = $('.hasRealPerson').val();
        var hash = 5381;
        for (var i = 0; i < value.length; i++) {
            hash = ((hash << 5) + hash) + value.charCodeAt(i);
        }

        return hash == $("#captchaCode").realperson('getHash');

    } else {
        return true;
    }
}

/**
 * @description Post new comment
 * @returns {boolean} - Always return FALSE
 */
function postNewComment(pagePath) {
    if (!checkReal()) {
        alert(getLocalization('invalidCode'));
        return false;
    } else {
        // process form
        $(".bt_edit").prop("disabled", true);
        $(".bt_delete").prop("disabled", true);
        $("#l_bt_submit_nc").prop("disabled", true);

        var commentNo = $('#referedCmtId').val();
        var text = jQuery.trim($("#commentText").val());
        var dataString = {
            text: text,
            page: pagePath,
            comment: commentNo,
            product: productName,
            version: productVersion,
            editedId: $('#editedId').val()
        };
        var postComment = conf.htpath + "resources/php/comment.php";
        var $lPlsWait = $('#l_plsWait');
        $lPlsWait.html(getLocalization('label.insertCmt'));
        if ((text != '') && (text != '<br>')) {
            $.ajax({
                type: "POST",
                url: postComment,
                contentType: "application/x-www-form-urlencoded",
                data: dataString,
                success: function (data_response) {
                    var result = data_response.split("|");

                    if (result[0] == 'Comment not inserted!') {
                        $('#cmt_info').html(data_response);
                    } else {
                        $('#referedCmtId').val(0);
                        setScrollTo(result[1]);
                        //showComments();
                        hideAll();
                        if (isAnonymous && result[1] == "moderated") {
                            $(".anonymous_post_cmt").remove();
                            $("#bt_new").append("<div class='anonymous_post_cmt'>" + getLocalization('comment.moderate.info') + "</div>");
                            goToByScroll("commentsContainer");
                            $(".realperson-regen").click();
                            var $defaultReal = $("#defaultReal");
                            $defaultReal.val("");
                            $defaultReal.html("");
                        } else {
                            showComments(pagePath);
                        }
                    }
                }
            });
        }
        $lPlsWait.html(getLocalization('label.plsWait'));
        return false;
        //return true;
    }
}

/**
 * @description Validate email address
 * @param email - String that will be validated as email
 * @returns {boolean} - TRUE if email is valid
 *                    - FALSE if email is invalid
 */
function validateEmail(email) {
    var re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    return re.test(email);
}

/**
 * @description Check user name to have minimum 5 alphanumeric characters without spaces
 * @param name - String that will be validated as name
 * @returns {boolean} - TRUE if email is valid
 *                    - FALSE if email is invalid
 */
function validateUserName(name) {
    var patt = /^[^\W]{2,}$/;
    return patt.test(name);
}

/**
 * @description Check password to have minimum 5 characters
 * @param pswd - String that will be validated as password
 * @returns {boolean} - TRUE if email is valid
 *                    - FALSE if email is invalid
 */
function validatePassword(pswd) {
    var patt = /^.{5,}$/;
    return patt.test(pswd);
}

/**
 * @description Show error information in sign up dialog
 * @param key - The field that trigger this error
 */
function signUpShowInfo(key) {
    var info = getLocalization(key);
    var keyInfo = getLocalization(key + '.info');
    if (keyInfo != key + '.info') {
        info = info + "<br/><div class='info'>" + getLocalization(key + '.info') + "<div>";
    }
    $('#signUpResponse').html(info).show();
    $('#signUp').show();
}

/**
 * {Refactored}
 * @description Process sign up form
 * @returns {boolean} - Always return FALSE
 */
function signUp() {
    //hideAll();
    var userName = $("#myNewUserName").val();
    var myName = $("#myName").val();
    var myEmail = $("#myEmail").val();
    var password = $("#myNewPassword").val();
    var password1 = $("#myNewPassword1").val();

    $("#signUpResponse").css('color', '#cc0000');
    if (!validateUserName(userName)) {
        signUpShowInfo('signUp.err.6');
    } else if (!validateEmail(myEmail)) {
        signUpShowInfo('signUp.err.3');
    } else if (!validatePassword(password, password1)) {
        signUpShowInfo('pwd.tooShort');
    } else if (password == password1) {
        var dataString = 'userName=' + userName + '&name=' + myName + '&password=' + password + '&email=' + myEmail
            + '&product=' + productName + '&version=' + productVersion;
        var processLogin = conf.htpath + "resources/php/signUp.php";
        showPreload(getLocalization('label.plsWaitSignUp'));
        $.ajax({
            type: "POST",
            url: processLogin,
            data: dataString,
            success: function (data_response) {
                hidePreload();
                $('#signUpResponse').hide();
                var response = eval("(" + data_response + ")");
                if (response.error == 'false') {
                    setCookie("page", pagePath, 7);

                    $("#signUp tbody tr").hide();
                    $("#signUpResponse").html(getLocalization('checkEmail-signUp'));
                    $("#signUpResponse").css('color', '#378b18');

                    //$('#signUpResponse').append('<div id="bt_close" onclick=$("#signUp").hide();>' + getLocalization('label.close') + '</div>');

                    $('#newComment').hide();
                    $('#signUpResponse').show();
                    $('#signUp').show();
                } else {
                    $("#signUpResponse").css('color', '#cc0000');
                    $('#signUpResponse').html(getLocalization("signUp.err." + response.errorCode));
                    $('#signUpResponse').show();
                }
            },
            error: function (data_response) {
                hidePreload();
            }
        });
    } else {
        signUpShowInfo('pwd.repeat');
    }
    return false;
}

/**
 * @description Delete comment
 */
function deleteComment() {
    moderatePost($("#idToDelete").val(), "deleted");
    /*hideAll();*/
}

/**
 * @description Hide delete comment dialog
 */
/*function hideDeleteDialog() {
    hideAll();
}*/

/**
 * @description Hide all dialogs and preloaders
 *   1. #u_Profile - Edit user profile dialog (logged in users)
 *   2. #preload - TOC preoader
 *   3. #preload1 - Content preloader
 *   4. #newComment - New comment dialog
 *   5. #recoverPwd - Reset password dialog
 *   6. #loginData - Log in dialog
 *   7. #signUp - Sign up dialog
 *   8. #confirmDelete - Confirm delete comment dialog (moderator / admin panel)
 *   9. #showConfirmApproveAll - Approve all comments dialog (moderator / admin panel)
 */
function hideAll() {
    debug("hideAll()");
    /*$('#u_Profile').hide();*/
    $('#preload').hide();
    $('#preload1').hide();
    $('#newComment').hide();
    $('#recoverPwd').hide();
    $('#loginData').hide();
    $('#signUp').hide();
    $("#confirmDelete").hide();
    /*$('#showConfirmApproveAll').hide();*/
}

/**
 * @description Show approve all dialog
 */
function showApproveAllDialog() {
    /*hideAll();*/
    $("#approveInfo").html(getLocalization('approveAllConfirmation'));
    $('#showConfirmApproveAll').modal('show');
}

/**
 * @description Approve all comments
 * @returns {boolean} - Always return FALSE
 */
function approveAllComments() {
    hideAll();
    var url = conf.htpath + "resources/php/moderate.php";
    var data = "page=" + pagePath + '&product=' + productName + '&version=' + productVersion;
    $.ajax({
        type: "POST",
        url: url,
        data: data,
        success: function (data_response) {
            if (data_response != "") {
                showComments(pagePath);
                $('#showConfirmApproveAll').hide();
            } else {
                $("#approveInfo").html("Action not performed !");
            }
        }
    });
    return false;
}

/**
 * @description Hide approve all comments dialog
 */
function hideApproveDialog() {
    $("#showConfirmApproveAll").hide();
}

/**
 * @description Show log in dialog (and populate fields with data from cookie if is set)
 * @returns {boolean} - Always return FALSE
 */
function showLoggInDialog() {
    var encoded = readCookie("oxyAuth");
    var pss = Base64.decode(encoded);
    var auth = pss.split("|");

    hideAll();
    $("#reloadComments").val("true");
    $('#myUserName').val(auth[0]);
    $('#myPassword').val(auth[1]);
    $("#myRemember").attr('checked', (readCookie("oxyAuth") != ""));


    $('#loginData').modal('show');
    $('#l_login2').trigger('click');
    /*$('#loginData').css('top', $(document).scrollTop() + $(window).height() / 2 + 'px').show();*/

    $("#recoverPwd").hide();
    $("#u_Profile").hide();
    $("#signUp").hide();

    return false;
}

/**
 * @description Show Sign Up form
 */
function sharedWith() {
    console.log('sharedWith()');
    /*
     $("#loginData").hide();
     $("#recoverPwd").hide();
     $("#u_Profile").hide();
     */

    /*$("#signUp tbody tr").show();
     $('#signUp').css('top', $(document).scrollTop() + $(window).height() / 2 + 'px').fadeIn('100');*/
    showPreload(getLocalization('label.plsWaitUpProfile'));
    $.ajax({
        type: "POST",
        url: conf.htpath + "resources/php/sharedFrom.php",
        data: 'version=' + productVersion,
        success: function (data_response) {
            debug("Share comments from: " + data_response);
            hidePreload();
            if (data_response != "") {
                $('#shareWith').html(data_response).show();
            }
        },
        error: function (data_response) {
            hidePreload();
        }
    });


}



/**
 * {Refactored}
 * @description Update user profile
 * @returns {boolean}
 */
function updateUserProfile() {
    var name = $("#u_name").val();
    var email = $("#u_email").val();
    var notifyPage = "no";
    if ($("#u_notify_page").is(':checked')) {
        notifyPage = "yes";
    }

    var notifyAll = "no";
    if ($("#u_notify_all").is(':checked')) {
        notifyAll = "yes";
    }

    var notifyReply = "no";
    if ($("#u_notify_reply").is(':checked')) {
        notifyReply = "yes";
    }

    var oldPassword = $("#u_Cpass").val();
    var dataString = 'update=true' + '&name=' + name + '&notifyReply=' + notifyReply + '&notifyAll=' + notifyAll
        + '&notifyPage=' + notifyPage + '&email=' + email + '&product=' + productName + '&version=' + productVersion
        + '&oldPassword=' + oldPassword;
    var password = $("#u_pass").val();
    var password1 = $("#u_pass1").val();

    if (password == password1) {
        if (password != '') {
            dataString = dataString + '&password=' + password;
        }
        var processLogin = conf.htpath + "resources/php/profile.php";

        showPreload(getLocalization('label.plsWaitUpProfile'));
        $('#u_response').removeClass('textError').removeClass('textInfo').html("");
        /*$('#u_Profile').hide();*/
        $.ajax({
            type: "POST",
            url: processLogin,
            data: dataString,
            success: function (data_response) {
                hidePreload();
                var response = eval('(' + data_response + ')');
                if (response.updated != 'true') {
                    /*$('#u_Profile').show();*/
                    if (response.msgType == 'error') {
                        $('#u_response').removeClass('textInfo').addClass('textError');
                    } else {
                        $('#u_response').removeClass('textError').addClass('textInfo');
                    }
                    $('#u_response').html(response.msg);
                    //setTimeout("goToByScroll('u_Profile')", 100);
                } else {
                    $("#u_Profile").modal('hide');
                    showComments(pagePath);
                }
            },
            error: function (data_response) {
                hidePreload();
            }
        });
    } else {
        $('#u_response').html(getLocalization('pwd.repeat')).show();
    }
    return false;
}

/**
 * @description Log off user
 * @returns {boolean} - Always return FALSE
 */
function loggOffUser() {
    // process form
    var dataString = "&logOff=true&productName=" + productName + "&productVersion=" + productVersion;
    var processLogin = conf.htpath + "resources/php/checkUser.php";
    $.ajax({
        type: "POST",
        url: processLogin,
        data: dataString,
        success: function (data_response) {
            isModerator = false;
            showComments(pagePath);
            $("#approveAll").hide();
        }
    });
    resetData();
    return false;
}

/**
 * @description Submit form @formName
 * @param formName
 */
function submitForm(formName) {
    //document.forms[formName].submit();
    $("form[name='" + formName + "']").submit();
}

/**
 * @description Show preload in right pane (#comments bar)
 * @param text
 */
function showPreload(text) {
    if (text) {
        lastPreloadMessage = $('#l_plsWait').html();
        $('#l_plsWait').html(text);
    } else {
        $('#l_plsWait').html(getLocalization('label.plsWait'));
    }
    $('#cm_count').hide();
    $('#cm_title').hide();
    $('#preload').show();
}

/**
 * @description Hide preload from right pane (#comments bar)
 */
function hidePreload() {
    $('#preload').hide();
    $('#cm_count').show();
    $('#cm_title').show();
    if (lastPreloadMessage) {
        $('#l_plsWait').html(lastPreloadMessage);
    }
}

/**
 * @description Location where last command occurred (px)
 * @type {null}
 */
var lastCmdLocation = null;

/**
 * @description Evaluate comments container position (full visible / partial visible / invisible)
 */
function evaluateCmtPos() {
    var p = $("#commentsContainer");
    if (p) {
        var offset = p.offset();
        if (offset) {
            if (offset.top < $(document).scrollTop()) {
                commentsPosition = 2; //full visible
            } else if (offset.top > ($(document).scrollTop() + $(window).height())) {
                commentsPosition = 0; //invisible
            } else if (offset.top < ($(document).scrollTop() + $(window).height())) {
                commentsPosition = 1; //partial visible
            }
        }
    }
}

/**
 * Inform user about losing data when leave page if an edited comment is not submitted
 */
top.window.onbeforeunload = function () {
    var text = $('#commentText').val();
    if (text) {
        if ((text != "") && ($('#commentText').val() != "<br>") && ($('#commentText').val() != "<p></p>") && $("#newComment").is(":visible")) {
            var ss = getLocalization('label.Unsaved');
            return ss;
        } else {
            //return true;
        }
    }
};

/**
 * @description Display comments floating top
 */
function float() {
    evaluateCmtPos();
    if (commentsPosition == 2) {
        $('#comments').css('top', $(document).scrollTop() + 'px').css('position', 'absolute');
        $(window).css("margin-top", "100px");
    } else {
        $('#comments').css('top', lastCmdLocation + 'px').css('position', 'static');
    }
}

evaluateCmtPos();
$(window).scroll(evaluateCmtPos);