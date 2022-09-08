/*

 Oxygen WebHelp Plugin
 Copyright (c) 1998-2017 Syncro Soft SRL, Romania.  All rights reserved.

 */

/**
 * @description Browser URL including query
 * @type {string|href}
 */
var pageSearch = window.location.href;

/**
 * @description Browser URL without query
 * @type {string}
 */
//var pageWSearch = pageSearch.replace(location.search, "");

/**
 * @description Used for internationalization.
 * @param localizationKey
 * @returns translated @localizationKey
 */
function getLocalization(localizationKey) {
    if (localization[localizationKey]) {
        return localization[localizationKey];
    } else {
        return localizationKey;
    }
}

/**
 * {Refactored}
 * @description Check if webhelp system is installed
 * @returns {boolean}
 */
function checkConfig() {
    var page = conf.htpath + "resources/php/checkInstall.php";

    var response = {"installPresent": "true", "configPresent": "false"};
    $.ajax({
        type: "POST",
        url: page,
        data: "",
        async: false,
        success: function (data_response) {
            response = eval("(" + data_response + ")");
        }
    });
    return response;
}

/**
 * {Refactored}
 * @description Reset data from forms
 */
function resetData() {
    $('#loginData').hide();
    $('#u_Profile').hide();
    $("#u_Profile input").attr("type", function (arr) {
        var inputType = $(this).attr("type");
        if (inputType == "text" || inputType == "password") {
            $(this).val("");
        }
    });

    if ($("#preload").parent().get(0).tagName != "BODY") {
        $("#preload").appendTo("body");
    }
    if ($("#editUser").parent().get(0).tagName != "BODY") {
        $("#editUser").appendTo("body");
    }

    $("#loginResponse").html("");
    $("#loginData input").attr("type", function (arr) {
        var inputType = $(this).attr("type");
        if (inputType == "text" || inputType == "password") {
            $(this).val("");
        }
    });
}

/**
 * @description Edit user details
 * @param id - User id
 */
function editUser(id) {
    hideAll();
    $('#editUser').modal('show');
    $('#setVersionDiv').hide();
    $("#edit_userId").val(id);
    $('#edit_uName').html($("#u_" + id + " .username").text());
    $('#edit_name').val($("#u_" + id + " .name").text());
    $('#edit_company').val($("#u_" + id + " .company").text());
    $('#edit_email').val($("#u_" + id + " .email").text());
    $('#edit_date').html($("#u_" + id + " .date").text());

    if ($("#u_" + id + " .notifyAll").text() == 'yes') {
        $('#edit_nAll').attr('checked', 'checked');
    } else {
        $('#edit_nAll').removeAttr('checked');
    }
    if ($("#u_" + id + " .notifyPage").text() == 'yes') {
        $('#edit_nPage').attr('checked', 'checked');
    } else {
        $('#edit_nPage').removeAttr('checked');
    }
    if ($("#u_" + id + " .notifyReply").text() == 'yes') {
        $('#edit_nReply').attr('checked', 'checked');
    } else {
        $('#edit_nReply').removeAttr('checked');
    }

    // User Type
    var ldapUser = $("#u_" + id + " .type").text() == "LDAP User";
    if (ldapUser) {
        $('#edit_name').attr('disabled', 'disabled');
        $('#edit_email').attr('disabled', 'disabled');
    } else {
        $('#edit_name').removeAttr('disabled');
        $('#edit_email').removeAttr('disabled');
    }

    // reset options
    $("#editUser option").removeAttr('selected');

    // level
    var currentLevel = $("#u_" + id + " .level").text();
    $("select option#level" + currentLevel).attr('selected', 'selected');

    // status
    var currentStatus = $("#u_" + id + " .status").text();
    $("select option#status" + currentStatus).attr('selected', 'selected');
}

/**
 * @description Edit user account from admin panel
 * @returns {boolean} Return FALSE
 */
function persistEdit() {
    var level = $("select#edit_level option:selected").val();
    var status = $("select#edit_status option:selected").val();
    var notifyAll = ($('#edit_nAll').prop('checked') ? 'yes' : 'no');
    var notifyPage = ($('#edit_nPage').prop('checked') ? 'yes' : 'no');
    var notifyReply = ($('#edit_nReply').prop('checked') ? 'yes' : 'no');
    var name = $('#edit_name').val();
    var email = $('#edit_email').val();
    var userId = $("#edit_userId").val();
    var company = $('#edit_company').val();
    var postData = 'update=true&product=' + productName + '&version='
        + productVersion + "&name=" + name + "&email=" + email
        + "&notifyPage=" + notifyPage + "&notifyAll=" + notifyAll
        + "&notifyReply=" + notifyReply + "&userId=" + userId + "&level="
        + level + "&company=" + company + "&status=" + status;

    $("#preload").show();

    $.ajax({
        type: "POST",
        url: conf.htpath + "resources/php/profile.php",
        dataType: "html",
        data: postData,
        success: function (data_response) {
            // display all users
            var response = eval('(' + data_response + ')');
            if (response.updated != 'true') {
                $('#msgInfo').html(response.msg);
            }
            if ($("#preload").parent().get(0).tagName != "BODY") {
                $("#preload").appendTo("body");
            }
            $("#preload").hide();
            $("#editUser").modal('hide');
            $('#editUserBck').hide();
            $("#edit_userId").val('');
            shown = false;
            showAdmin();
        },
        error: function (xhr, ajaxOptions, thrownError) {
            if ($("#preload").parent().get(0).tagName != "BODY") {
                $("#preload").appendTo("body");
            }
            $("#preload").hide();
            $('#msgInfo').html("...");
        }
    });

    return false;
}

/**
 * @description In Admin Panel, show administrators only when user is logged as administrator
 */
function showAdmin() {
    var postData = 'select=true&product=' + productName + '&version=' + productVersion;
    $("#preload").show();
    $('#adminUsers').hide();
    $.ajax({
        type: "POST",
        url: conf.htpath + "resources/php/adminShowUsers.php",
        data: postData,
        success: function (data_response) {
            // display all users
            if ($("#preload").parent().get(0).tagName != "BODY") {
                $("#preload").appendTo("body");
            }
            $("#preload").hide();
            if (data_response != "0") {
                $('#adminUsers #list').html(data_response);
                $('#adminUsers').show();
            }
            if (window.location.search != "") {
                var s = window.location.search;
                var substr = s.split('=');
                $('input#id_search').val(substr[1]);
                $('input#id_search').attr('value', substr[1]).trigger('keyup');
                // $('input#id_search').trigger('submit');
            }

        },
        error: function (data_response) {
            if ($("#preload").parent().get(0).tagName != "BODY") {
                $("#preload").appendTo("body");
            }
            $("#preload").hide();
        }
    });

    displayUserAccount();

    if (getParam('a') != '') {
        $("#loginResponse").html(getLocalization('label.logAdmin'));
        showLoggInDialog();
    }
}

/**
 * @description Retrieve specified parameter from current URL
 * @param name Required parameter
 * @returns {*} Value of required parameter
 */
function getParam(name) {
    var results = new RegExp('[\\?&]' + name + '=([^&#]*)')
        .exec(window.location.href);
    if (results != null && results.length > 1) {
        return results[1];
    } else {
        return "";
    }
}

/**
 * @description Display user account information
 */
function displayUserAccount() {
    $.ajax({
        type: "POST",
        url: conf.htpath + "resources/php/checkUser.php",
        data: "check=true&productName=" + productName + "&productVersion=" + productVersion + "&delimiter=|",
        success: function (data_response) {
            // Logged In|name|userName|level
            // var info = data_response.split("|");
            var response = eval('(' + data_response + ')');

            if (response.loggedIn == 'true') {
                loggedUser(response);
            } else {
                if ($("html").attr("dir") != "rtl") {
                    $("#accountInfo").html(getLocalization("label.welcome") + " " + getLocalization("label.guest"));
                } else {
                    $("#accountInfo").html(getLocalization("label.guest") + " " + getLocalization("label.welcome"));
                }
                $('#userAccount #show_profile').hide();
                $('#userAccount #bt_logIn').show();
                $('#userAccount #bt_signUp').show();
            }
        }
    });
}

/**
 * @description Display admin pages only if the user has permission otherwise redirect to login page.
 */
function showAdminPage() {
    $.ajax({
        type: "POST",
        url: conf.htpath + "resources/php/checkUser.php",
        data: "check=true&productName=" + productName + "&productVersion=" + productVersion + "&delimiter=|",
        success: function (data_response) {
            // Logged In|name|userName|level
            // var info = data_response.split("|");
            var response = eval('(' + data_response + ')');

            if (response.level == 'moderator' || response.level == 'admin') {
                $('#cover').hide();
                $('#loginData').hide();
            } else {
                $('#cover').show();
                showLoggInDialog();
            }
        }
    });
}

/**
 * @description Go to last page stored in cookie
 */
function goLastPage() {
    var link = readCookie('backLink');
    if (link != '') {
        window.location = link;
    } else {
        parent.window.location = conf.htpath;
    }
}

/**
 * @description Show login dialog
 * @returns {boolean} Return FALSE
 */
function showLoggInDialog() {
    var encoded = readCookie("oxyAuth");
    var pss = Base64.decode(encoded);
    var auth = pss.split("|");

    $('#myUserName').val(auth[0]);
    $('#myPassword').val(auth[1]);
    $("#myRemember").attr('checked', (readCookie("oxyAuth") != ""));
    document.getElementById('loginData').style.top = $(document).scrollTop() + $(window).height() / 2 + 'px';
    $('#loginData').show();

    return false;
}

/**
 * @description Show information about logged user
 * @param response Response of AJAX request. This contain information about logged user
 */
function loggedUser(response) {
    if ($("html").attr("dir") != "rtl") {
        $("#accountInfo").html(getLocalization("label.welcome") + " " + response.name + " [" + response.userName + "]");
    } else {
        $("#accountInfo").html("[" + response.userName + "] " + response.name + " " + getLocalization("label.welcome"));
    }
    if (response.level == "admin" || response.level == "moderator") {
        $("#accountInfo").append(" <span class='level'>" + getLocalization('label.' + response.level) + "</span>");
        $('#adminMenu #bt_setVersion').show();
        $('#adminMenu #bt_export').show();
        $('#adminMenu #bt_viewPosts').show();
        //$('#adminUsers').show();
    }
    $("#accountInfo").append(" <button type='button' class='bt_toolbar btn btn-default' onclick='goLastPage()'>" + getLocalization('label.back') + "</button>");

    $('#userAccount #show_profile').show();
    $('#userAccount #bt_logIn').hide();
    $('#userAccount #bt_signUp').hide();
}

$("#bt_logIn").click(function () {
    // process form
    var encoded = readCookie("oxyAuth");
    var pss = Base64.decode(encoded);
    var auth = pss.split("|");

    $('#myUserName').val(auth[0]);
    $('#myPassword').val(auth[1]);
    $("#myRemember").attr('checked', (readCookie("oxyAuth") != ""));


    showLoggInDialog();
    $("#u_Profile").hide();

    return false;
});

// login form execute
//$("#logIn").click(logIn);

$(".bt_close").click(closeDialog($(this).parent()));

// logoff form execute
$("#bt_logOff").click(logOff);

/**
 * @description Close dialog of clicked button
 * @returns {boolean} return FALSE
 */
function closeDialog() {
    $(this).parent().hide();
    return false;
};

/**
 * @description Submit formName form
 * @param formName Name of form that will be submitted
 */
function submitForm(formName) {
    document.forms[formName].submit();
}

/**
 * @description Process login form
 * @returns {boolean} return FALSE
 */
function logInAdmin() {
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
        $('#preload').show();
        $('#loginData').hide();
        $.ajax({
            type: "POST",
            url: processLogin,
            data: dataString,
            success: function (data_response) {
                var response = eval('(' + data_response + ')');
                if (typeof pageWSearch !== 'undefined' && window.location.href != pageWSearch) {
                    if (response.authenticated == 'false') {
                        showLoggInDialog();
                        if (response.error) {
                            var msg = getLocalization('checkUser.loginError');
                            msg = msg + "<!--" + response.error + " -->";
                            $('#loginResponse').html(msg).show();
                        } else {
                            if (rememberMe == "yes") {
                                var pss = Base64.encode(userName + "|" + password);
                                setCookie("oxyAuth", pss, 14);
                            } else {
                                eraseCookie("oxyAuth");
                            }
                            $('#loginResponse').html(getLocalization('checkUser.loginError')).show();
                        }
                    } else {
                        $('#loginResponse').html("").hide();
                        window.location.href = pagePath;
                    }
                } else {
                    $('#preload').hide();
                    if (response.authenticated == 'true') {
                        $('#loginResponse').hide();
                        $('#userAccount #show_profile').show();
                        $('#userAccount #bt_logIn').hide();
                        $('#userAccount #bt_signUp').hide();
                        $('#cover').hide();
                        if (rememberMe == "yes") {
                            var pss = Base64.encode(userName + "|" + password);
                            setCookie("oxyAuth", pss, 14);
                        } else {
                            eraseCookie("oxyAuth");
                        }
                    } else {
                        showLoggInDialog();
                        if (response.error) {
                            var msg = getLocalization('checkUser.loginError');
                            msg = msg + "<!-- " + response.error + " -->";
                            $('#loginResponse').html(msg).show();
                        } else {
                            $('#loginResponse').html(getLocalization('checkUser.loginError')).show();
                        }
                    }
                }
                showAdmin();
            },
            error: function (data_response) {
                if ($("#preload").parent().get(0).tagName != "BODY") {
                    $("#preload").appendTo("body");

                }
                $("#preload").hide();
            }
        });
    }
    return false; //or the form will post your data to login.php
}

/**
 * @description Process Logoff
 * @returns {boolean} return FALSE
 */
function logOff() {
    // process form
    var dataString = "&logOff=true&productName=" + productName + "&productVersion=" + productVersion;
    var processLogin = conf.htpath + "resources/php/checkUser.php";
    $.ajax({
        type: "POST",
        url: processLogin,
        data: dataString,
        success: function (data_response) {
            displayUserAccount();
            $("#adminUsers").hide();
        }
    });
    resetData();
    goLastPage();
    return false;
}

/**
 * @description Read cookie information
 * @param a Cookie that will be retrieved
 * @returns {string} Value of retrieved cookie
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
 * @description Set cookie
 * @param c_name Cookie name
 * @param value Cookie value
 * @param exdays Cookie will expire after exdays
 */
function setCookie(c_name, value, exdays) {
    var exdate = new Date();
    exdate.setDate(exdate.getDate() + exdays);
    var c_value = escape(value) + ((exdays == null) ? "" : "; expires=" + exdate.toUTCString());
    document.cookie = c_name + "=" + c_value + "; path=/";
}

/**
 * @description Delete specified Cookie
 * @param name Cookie name
 */
function eraseCookie(name) {
    setCookie(name, "", -1);
}

$(".bt_close").click(closeDialog);

/**
 * @description Show dialog with all available versions.
 * @returns {boolean} return FALSE
 */
function showVersion() {
    var dataString = "productName=" + productName + "&productVersion=" + productVersion + "&qVersion=true";
    var setVersionPath = conf.htpath + "resources/php/comment.php";

    $('#setVersionDiv').modal('hide');
    $('#v_preload').show();
    $.ajax({
        type: "POST",
        url: setVersionPath,
        data: dataString,
        success: function (data_response) {
            if (data_response == 'USER_SESSION_ERROR') {
                showLoggInDialog();
                $('#cover').show();
            } else {
            $('#v_preload').hide();
            shown = false;
            var response = eval('(' + data_response + ')');
            if (response.versions == "") {
                $('#setVersionInfo').html(getLocalization("info.noComments"));
                $('#versions').html("");
            } else {
                $('#setVersionInfo').html(getLocalization('label.versionInfo'));
                $('#setVersionInfo').append(response.minVersion);
                $('#versions').html(response.versions);
            }

                $('#setVersionDiv').modal('show');
            }
        }
    });

    return false;
}

/**
 * @description Set visible version
 * @param minVersion Version that will be visible
 * @returns {boolean} return FALSE
 */
function setVersion(minVersion) {
    var dataString = "productName=" + productName + "&productVersion=" + productVersion + "&minVersion=" + minVersion;
    var setVersionPath = conf.htpath + "resources/php/comment.php";
    $('#setVersionDiv').modal('hide');
    $('#v_preload').show();
    $.ajax({
        type: "POST",
        url: setVersionPath,
        data: dataString,
        success: function (data_response) {
            $('#v_preload').hide();
            if (data_response != "Success") {
                $('#setVersionDiv').modal('show');
            } else {
                //showVersion();
                return false;
            }
        }
    });
    return false;
}

/**
 * @description Show Export Comments dialog
 * @returns {boolean} return FALSE
 */
function showExportComments() {
    hideAll();

    var dataString = "productName=" + productName + "&productVersion=" + productVersion + "&qInfo=true";
    $('#ll_viewAll_tit').html(getLocalization('label.allPosts'));
    $('#exProductVersion').val("");
    $('#exFrmProductName').val("");
    $("#bt_do_export").addClass('disabled');
    var setVersionPath = conf.htpath + "resources/php/commentInfo.php";
    $('#exportDiv').modal('hide');
    $('#preload').show();
    $.ajax({
        type: "POST",
        url: setVersionPath,
        data: dataString,
        success: function (data_response) {
            if (data_response == 'USER_SESSION_ERROR') {
                showLoggInDialog();
                $('#cover').show();
            } else {
                shown = false;
                if (data_response == "") {
                    $('#ex_prod_val').html("<div class='listTitle'>" + getLocalization("info.noComments") + "</div>");
                } else {
                    $('#ex_prod_val').html(data_response);
                    $('#ex_prod_val').append("<div id='empty_versions'>&nbsp;</div>");
                }
                $('#preload').hide();
                $('#exportDiv').modal('show');
            }
        }
    });

    return false;
}

/**
 * @description Add specific class to selected version from Export Comments dialog
 * @param selected Clicked item
 * @param version Value of clicked (selected) item
 */
function setExpVersion(selected, version) {
    $('.selectable').removeClass('selectedItem');
    $(selected).addClass('selectedItem');
    $('#exProductVersion').val(version);
    $("#bt_do_export").removeClass('disabled');
    $("#bt_do_export").show();
}

/**
 * @description Show available versions for selected product
 * @param idx Item ID from available versions
 * @param product Product name
 * @returns {boolean} return FALSE
 */
function showVersions(idx, product) {
    $('#empty_versions').hide();
    $('.versions').show();
    $('.selectable').removeClass('selectedItem');
    var productStr = "#p_" + idx;
    $('.p_selectable').removeClass('selectedItem');
    $(productStr).addClass('selectedItem');
    $('#exFrmProductName').val(product);
    $("#bt_do_export").addClass('disabled');
    $('.product_Versions').hide();
    var productStr = "#v_" + idx;
    $(productStr).show();
    $('.product_Versions').parent().removeClass('selected');
    $(productStr).parent().addClass('selected');
    return false;
}

/**
 * @description Process export form
 * @returns {boolean} return FALSE
 */
function doExport() {
    $('#fl_ProductName').val(productName);
    $('#fl_ProductVersion').val(productVersion);
    submitForm('exportCmts');
    return false;
}

/**
 * @description Hide DIVs listed (setVersionDiv, exportDiv, loginData, editUser, inlineViewDiv, msgInfo)
 */
function hideAll() {
    //$("#setVersionDiv").hide();
    /*$("#exportDiv").hide();*/
    $("#loginData").hide();
    /*$("#editUser").hide();*/
    /*$('#inlineViewDiv').hide();*/
    $('#msgInfo').html('');
}

/**
 * @description Export comments in XML format.
 * @returns {boolean} return FALSE
 */
function viewAllPosts() {
    hideAll();
    $('#exportDiv').modal('hide');

    toDelete = "-1";

    var productV = $('#exProductVersion').val();
    var productN = $('#exFrmProductName').val();

    var dataString = "productName=" + productName + "&productVersion=" + productVersion + "&inPage=true&productN=" + productN + "&productV=" + productV;
    var setVersionPath = conf.htpath + "resources/php/exportComments.php";

    $('#preload').show();
    $('#ex_inline').html('');
    $('#bt_cleanUsr').hide();
    $('#bt_cleanCmts').hide();
    $('#bt_deleteCmts').show();
    $('#inlineViewDiv #v_preload').show();

    $.ajax({
        type: "POST",
        url: setVersionPath,
        data: dataString,
        success: function (data_response) {
            $('#preload').hide();
            /*$('#editUser').hide();*/
            shown = false;
            $('#ll_viewAll_tit_info').html("&nbsp;&nbsp;&nbsp;" + getLocalization('label.product') + ": " + productN + "&nbsp;&nbsp;&nbsp;" + getLocalization('label.version') + ": " + productV + " ");
            $('#inlineViewDiv #v_preload').hide();
            $('#ex_inline').html(data_response);
        }
    });
    $('#preload').hide();
    $('#inlineViewDiv').modal('show');

    return false;
}

/**
 * @description Last message displayed in preload DIV
 * @type {string}
 */
var lastPreloadMessage = "";

/**
 * @description Display preload message
 * @param text Message that will be displayed in preload
 */
function showPreload(text) {
    document.getElementById('preload').style.top = $(document).scrollTop() + $(window).height() / 2 + 'px';
    if (text) {
        lastPreloadMessage = $('#l_plsWait').html();
        $('#l_plsWait').html(text);
    }
    $('#preload').show();
}

/**
 * @description Hide preload message
 */
function hidePreload() {
    $('#preload').hide();
    if (lastPreloadMessage) {
        $('#l_plsWait').html(lastPreloadMessage);
    }
}

/**
 * @description ID of comment that will be deleted
 * @type {string}
 */
var toDelete = "-1";

/**
 * @description Add comment (ID) to list of comments that will be deleted
 * @param id ID of comment
 */
function addToDelete(id) {

    if ($('.cb-element:checked').length > 0) {
        $('#bt_cleanCmts').removeAttr('disabled');
        $('#bt_cleanUsr').removeAttr('disabled');
    } else {
        $('#bt_cleanCmts').attr('disabled', 'disabled');
        $('#bt_cleanUsr').attr('disabled', 'disabled');
    }

    var toAdd = "," + id;
    var found = toDelete.search(toAdd);
    if (found > 0) {
        toDelete = toDelete.substr(0, found) + toDelete.substr(found + toAdd.length);
    } else {
        toDelete = toDelete + toAdd;
    }
}

/**
 * @description Delete comments
 * @returns {boolean} return FALSE
 */
function deleteCmts() {
    showPreload();
    $.ajax({
        type: "POST",
        url: conf.htpath + "resources/php/moderate.php",
        data: "ids=" + toDelete + '&product=' + productName + '&version=' + productVersion,
        success: function (data_response) {
            $('#editUser').hide();
            hidePreload();
            shown = false;
            if (data_response == "true") {
                toDelete = "-1";
                $('#inlineViewDiv').hide();
            }
            viewAllPosts();
        }
    });
    return false;
}

/**
 * @description Delete comments associated with a topic that doesn't exist anymore
 * @returns {boolean} return FALSE
 */
function cleanDeleteCmts() {
    $('#inlineViewDiv #v_preload').show();
    $.ajax({
        type: "POST",
        url: conf.htpath + "resources/php/moderate.php",
        data: "ids=" + toDelete + '&product=' + productName + '&version=' + productVersion,
        success: function (data_response) {
            $('#editUser').hide();
            hidePreload();
            shown = false;
            if (data_response == "true") {
                toDelete = "-1";
                $('#inlineViewDiv').hide();
            }
            cleanCommentsDb();
            addInfoDialog();
            setTimeout(function () {
                $('#info_container').remove();
            }, 5000);
        }
    });
    return false;
}

/**
 * @description Delete users older than 7 days and unconfirmed
 * @returns {boolean} return FALSE
 */
function cleanDeleteUsr() {
    $('#inlineViewDiv #v_preload').show();
    $.ajax({
        type: "POST",
        url: conf.htpath + "resources/php/deleteUsers.php",
        data: "ids=" + toDelete + '&productName=' + productName + '&productVersion=' + productVersion,
        success: function (data_response) {
            $('#editUser').hide();
            hidePreload();
            shown = false;
            if (data_response == "true") {
                toDelete = "-1";
                $('#inlineViewDiv').hide();
            }
            cleanUsersDb();
            addInfoDialog();
            setTimeout(function () {
                $('#info_container').remove();
            }, 5000);
        }
    });
    return false;
}

/**
 * @description Add and display confirmation dialog for clean users / comments actions
 *              This dialog will be removed automatically after 5 seconds
 */
function addInfoDialog() {
    $('#inlineViewDiv').append("<div id='info_container' style='display: block; position: absolute; top: 150px; width: 90%; margin:0 5%; background: #fffff0;'><div id='info_dialog'>" + getLocalization('label.confirmOk') + "</div></div>");
    $('#info_dialog').css("position", "relative");
    $('#info_dialog').css("display", "block");
    $('#info_dialog').css("background", "#fff");
    $('#info_dialog').css("margin", "auto");
    $('#info_dialog').css("width", "300px");
    $('#info_dialog').css("padding", "10px 0");
    $('#info_dialog').css("text-align", "center");
    $('#info_dialog').css("border", "1px solid #999");
    $('#info_dialog').css("color", "green");
    $('#info_dialog').css("font-weight", "bold");
    $('#info_dialog').css("border-radius", "5px");
    $('#info_dialog').css("box-shadow", "1px 1px 10px #999");
}

/**
 * @description Extract from DB users older than 7 days and unconfirmed
 * @returns {boolean}
 */
function cleanUsersDb() {
    $('#bt_cleanUsr').attr('disabled', 'disabled');
    toDelete = "-1";
    $('#exProductVersion').val(productVersion);
    $('#exFrmProductName').val(productName);

    $('#bt_cleanUsr').show();
    $('#bt_cleanCmts').hide();
    $('#bt_deleteCmts').hide();

    var dataString = "productName=" + productName + "&productVersion=" + productVersion
        + "&inPage=true&clean=true&productN=" + productName + "&productV=" + productVersion;
    var setVersionPath = conf.htpath + "resources/php/exportUsers.php";

    $('#ll_viewAll_tit').html(getLocalization('label.unconfirmedUsers'));
    $('#ll_viewAll_tit_info').html("&nbsp;&nbsp;&nbsp;" + getLocalization('label.product') + ": "
        + productName + "&nbsp;&nbsp;&nbsp;" + getLocalization('label.version') + ": " + productVersion + " ");
    $('#inlineViewDiv #v_preload').show();
    $.ajax({
        type: "POST",
        url: setVersionPath,
        data: dataString,
        success: function (data_response) {
            $('#preload').hide();
            $('#editUser').hide();
            shown = false;

            $('#ex_inline').html(data_response);
            if ($('#ex_inline').html() != "") {
                $('#inlineViewDiv').modal('show');
            }
        }
    });
    $('#inlineViewDiv #v_preload').hide();

    return false;
}

/**
 * @description Extract from DB comments associated with a topic that doesn't exist anymore
 * @returns {boolean} return FALSE
 */
function cleanCommentsDb() {
    $('#bt_cleanCmts').attr('disabled', 'disabled');
    toDelete = "-1";
    $('#exProductVersion').val(productVersion);
    $('#exFrmProductName').val(productName);

    $('#bt_cleanUsr').hide();
    $('#bt_cleanCmts').show();
    $('#bt_deleteCmts').hide();

    var dataString = "productName=" + productName + "&productVersion=" + productVersion
        + "&inPage=true&clean=true&productN=" + productName + "&productV=" + productVersion;
    var setVersionPath = conf.htpath + "resources/php/exportComments.php";

    $('#ll_viewAll_tit').html(getLocalization('label.invalidPosts'));
    $('#ll_viewAll_tit_info').html("&nbsp;&nbsp;&nbsp;" + getLocalization('label.product') + ": "
        + productName + "&nbsp;&nbsp;&nbsp;" + getLocalization('label.version') + ": " + productVersion + " ");
    $('#inlineViewDiv #v_preload').show();
    $.ajax({
        type: "POST",
        url: setVersionPath,
        data: dataString,
        success: function (data_response) {
            $('#preload').hide();
            $('#editUser').hide();
            shown = false;

            $('#ex_inline').html(data_response);
            if ($('#ex_inline').html() != "") {
                $('#inlineViewDiv').modal('show');
            }
        }
    });
    $('#inlineViewDiv #v_preload').hide();

    return false;
}

$("#bt_setVersion").click(showVersion);
$("#bt_viewPosts").click(function () {
    $("#bt_do_export").click(function () {
        return false;
    });
    $("#bt_do_export").off('click');
    $('#bt_do_export').click(viewAllPosts);
    $('#ll_exp_tit').html(getLocalization('label.forView'));
    showExportComments();
});

$("#bt_export").click(function () {
    $("#bt_do_export").click(function () {
        return false;
    });
    $("#bt_do_export").off('click');
    $('#bt_do_export').click(doExport);
    $('#ll_exp_tit').html(getLocalization('label.forExport'));
    showExportComments();
});

$("#bt_do_export").addClass('disabled');
$(".ex_close").click(closeDialog);
$(".bt_cancel").click(function () {
    $(".bt_close").click();
});
$("#l_cancelEdit").click(function () {
    $(".bt_close").click();
});

/**
 * @description TRUE if webhelp system is installed, FALSE otherwise
 * @type {boolean}
 */
var config = checkConfig();
if (config.installPresent == "true" && config.configPresent == "true") {
    window.location.href = conf.baseUrl + "install/removeInstallDir.html";
} else if (config.configPresent == "true") {
    showAdmin();
} else {
    $('#cm_title').append(' - ' + getLocalization('configInvalid'));
    window.parent.location.href = conf.htpath + "install/";
}

$("#cleanDbBtn").click(cleanCommentsDb);
$("#cleanDbUsrBtn").click(cleanUsersDb);

$('#checkAll').click(function () {
    $('.cb-element').each(function (index) {
        if ($(this).prop('checked')) {
            $(this).prop('checked', false);
        } else {
            $(this).prop('checked', true);
        }

        var id = $(this).attr('value');
        addToDelete(id);

    });
});

$(document).ready(function(){
    showAdminPage();
});