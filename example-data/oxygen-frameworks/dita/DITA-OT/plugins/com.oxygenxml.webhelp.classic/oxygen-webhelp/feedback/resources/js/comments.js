/*

 Oxygen WebHelp Plugin
 Copyright (c) 1998-2017 Syncro Soft SRL, Romania.  All rights reserved.

 */
var pageSearch = window.location.href;
var pageHash = window.location.hash;
var isModerator = false;
var isAnonymous = false;
var pathName = window.location.pathname;


$(document).ready(function(){

    $(".bt_close").click(closeDialog);
    $(".bt_cancel").click(function () {
        $(".bt_close").click();
    });

    $("#l_addNewCmt").click(showNewCommentDialog);
    // post or edit comment
    //$("#l_bt_submit_nc").click(submitComment);

    $("#bt_recover").click(recover);

    //$("#bt_signUp").click(signUp);

    //debug("js 4");
    $("#bt_yesDelete").click(deleteComment);
    //debug("js 5");
    /*$("#bt_noDelete").click(hideDeleteDialog);*/
    //debug("js 5");

    $("#bt_approveAll").click(showApproveAllDialog);
    //debug("js 6");
    $("#bt_yesApprove").click(approveAllComments);

    $("#bt_noApprove").click(hideApproveDialog);

    $('#bt_editProfile').click(function(e){
        e.preventDefault();
        showProfileChange(e);
    });

    $("#bt_logIn").click(function () {
        $(".anonymous_post_cmt").remove();
        $('#loginResponse').html('');
        showLoggInDialog();
    });

    /*$(document).on('submit','form_login',function(){
        // code
        loggInUser();
    });*/


    $("#bt_signUp").click(function (e) {
        // show signup form
        $("#signUpResponse").html('');
        $('#loginData').modal('show');
        $('#l_signUp2').trigger('click');

        // get the shared projects
        sharedWith();
    });

    $("#l_signUp2").click(function (){
        // get the shared projects
        sharedWith();
    });


    $("#bt_profile").click(updateUserProfile);
    $("#bt_logOff").click(loggOffUser);


    $(window).on("scroll", function () {
        if ((eval($("#bt_new").position().top - $(window).scrollTop()) < $("#comments").height()) && $("#l_addNewCmt").is(":visible")) {
            $("#comments").addClass('float_comments');
        } else {
            $("#comments").removeClass('float_comments');
        }
    });


    if (checkConfig()) {
        showComments(pagePath);
    }
});