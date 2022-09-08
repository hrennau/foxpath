<?php
/*
    
Oxygen WebHelp Plugin
Copyright (c) 1998-2017 Syncro Soft SRL, Romania.  All rights reserved.

*/

require_once 'init.php';

//$ses=Session::getInstance();
//echo "test";
//error_log('profile.php -> $_POST' . print_r($_POST,true));

if (isset($_POST['update']) && trim($_POST['update']) != '') {
    $toReturn = new JsonResponse();
    $toReturn->set("updated", "false");
    $info = array();

    if (isset($_POST['password']) && trim($_POST['password']) != "") {
        $info['password'] = $_POST['password'];
    }
    if (isset($_POST['oldPassword'])) {
        $info['oldPassword'] = $_POST['oldPassword'];
    }
    $info['name'] = $_POST['name'];
    $info['email'] = $_POST['email'];
    $info['notifyPage'] = $_POST['notifyPage'];
    $info['notifyAll'] = $_POST['notifyAll'];
    $info['notifyReply'] = $_POST['notifyReply'];

    $pName = (isset($_POST['product']) ? $_POST['product'] : "");
    $pVersion = (isset($_POST['version']) ? $_POST['version'] : "");
    $fullUser = base64_encode($pName . "_" . $pVersion . "_user");
    $ses = Session::getInstance();
    if (isset($ses->$fullUser)) {
        if ((isset($_POST['userId']) && strlen(trim($_POST['userId'])) != "") && ($ses->$fullUser->level = 'admin')) {
            // from admininstrative pages requests
            $info['editByAdmin'] = true;
            $info['company'] = $_POST['company'];
            $info['level'] = $_POST['level'];
            $info['status'] = $_POST['status'];
            $info['userId'] = $_POST['userId'];
        } else {
            $info['editByAdmin'] = false;
        }
        $err = $ses->$fullUser->updateProfile($info);
        if ($err != "") {
            $toReturn->set("msgType", "info");
            $toReturn->set("msg", $err);
            echo $toReturn;
        } else {
            $toReturn->set("updated", "true");
            echo $toReturn;
        }
    } else {
        $toReturn->set("msgClass", "error");
        $toReturn->set("msg", Utils::translate("err.notLoggedIn"));
        echo $toReturn;
    }

} else {
    if (isset($_POST['select']) && trim($_POST['select']) != '') {
        $toReturn = new JsonResponse();
        $pName = (isset($_POST['product']) ? $_POST['product'] : "");
        $pVersion = (isset($_POST['version']) ? $_POST['version'] : "");
        $fullUser = base64_encode($pName . "_" . $pVersion . "_user");
        $ses = Session::getInstance();
        if (isset($ses->$fullUser)) {
            $delim = $_POST['delimiter'];
            $user = $ses->$fullUser;
            $toReturn->set("isLogged", "true");
            $toReturn->set("name", $user->name);
            $toReturn->set("email", $user->email);
            $toReturn->set("notifyPage", $user->notifyPage);
            $toReturn->set("notifyReply", $user->notifyReply);
            $toReturn->set("notifyAll", $user->notifyAll);
            $toReturn->set("ldapUser", $user->ldapUser);
        } else {
            $toReturn->set("isLogged", "false");
        }
        echo $toReturn;
    } else {
        echo "Invalid data!";
    }
}
?>
