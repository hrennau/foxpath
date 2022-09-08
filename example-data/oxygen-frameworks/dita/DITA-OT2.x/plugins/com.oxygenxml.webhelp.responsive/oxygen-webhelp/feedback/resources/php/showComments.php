<?php
/*
    
Oxygen WebHelp Plugin
Copyright (c) 1998-2017 Syncro Soft SRL, Romania.  All rights reserved.

*/

require_once 'init.php';
if (isset($_POST['page']) && trim($_POST['page']) != '') {
    $url = $_POST['page'];
    $chars = strlen(__BASE_PATH__);
    $url = substr($url, $chars);

    $comment = new Comment($dbConnectionInfo, "commentStyle");
    $info['page'] = $url;
    $info['product'] = (isset($_POST['productName']) ? $_POST['productName'] : "noProduct");
    $info['version'] = (isset($_POST['productVersion']) ? $_POST['productVersion'] : "noVersion");

    $fullUser = base64_encode($info['product'] . "_" . $info['version'] . "_user");
    $ses = Session::getInstance();
    $info['userId'] = -1;
    $level = "notLoggedIn";
    if (isset($ses->$fullUser)) {
        $level = $ses->$fullUser->level;
        $info['userId'] = $ses->$fullUser->userId;
    }

    if ($level != "user" && $level != "notLoggedIn") {
        $list = $comment->listForPage($info, -1, true);
    } else {
        $list = $comment->listForPage($info);
    }

    echo $list;
    // 	for ($i=0;$i<10;$i++){
    // 		echo "<table><tr><td>comment $i for $url</td></tr></table>";
    // 	}
} else {
    echo "no page for comment";
}
?>