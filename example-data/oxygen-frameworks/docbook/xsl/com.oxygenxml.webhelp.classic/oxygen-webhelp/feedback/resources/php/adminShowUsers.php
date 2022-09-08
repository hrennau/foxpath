<?php
/*
    
Oxygen WebHelp Plugin
Copyright (c) 1998-2017 Syncro Soft SRL, Romania.  All rights reserved.

*/

require_once 'init.php';

$ses = Session::getInstance();

if (isset($_POST["select"]) && trim($_POST["select"]) == "true") {
    $info = array();

    $pName = (isset($_POST['product']) ? $_POST['product'] : "");
    $pVersion = (isset($_POST['version']) ? $_POST['version'] : "");
    $fullUser = base64_encode($pName . "_" . $pVersion . "_user");

    if (isset($ses->$fullUser) && ($ses->$fullUser instanceof User)) {
        $user = $ses->$fullUser;
        if ($user->level == 'admin') {
            echo $user->listUsers();
            echo "<script>";
            echo "$('input#id_search').quicksearch('table#usersList tbody tr');</script>";
        } else {
            echo "0";
        }
    } else {
        echo "0";
    }
} else {
    echo "0";
}
?>