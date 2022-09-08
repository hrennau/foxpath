<?php
/*
    
Oxygen WebHelp Plugin
Copyright (c) 1998-2017 Syncro Soft SRL, Romania.  All rights reserved.

*/

require_once 'init.php';

function notifyUsers($userEmail, $page, $id, $text, $userName, $product, $usersToNotify)
{
    $productTranslate = (defined("__PRODUCT_NAME__") ? __PRODUCT_NAME__ : $product);
    $subject = "[" . $productTranslate . "] " . Utils::translate('newCommentApproved');
    $subject .= " [" . $page . "]";

    foreach ($usersToNotify as $key => $value) {
        if (strpos($value, "<" . $userEmail . ">") === false) {
            $template = new Template("./templates/" . __LANGUAGE__ . "/newComment.html");

            $confirmationMsg = $template->replace(array(
                "page" => __BASE_URL__ . $page . "#" . $id,
                "text" => $text,
                "user" => $userName,
                "productName" => $productTranslate
            ));
            $mail = new Mail();
            $mail->Subject($subject);
            $mail->To($value);
            $mail->From(__EMAIL__);
            $mail->Body($confirmationMsg);
            $mail->Send();
            //echo "\nSEND to ".$value."user email='".$userEmail."'";
        }
    }
}

function notifyModerators($id, $page, $text, $userName, $name, $product, $moderators)
{
    $template = new Template("./templates/" . __LANGUAGE__ . "/newCommentToModerate.html");
    $productTranslate = (defined("__PRODUCT_NAME__") ? __PRODUCT_NAME__ : $product);
    $subject = "[" . $productTranslate . "] " . Utils::translate('newCommentToModerate');
    if (defined('__MODERATE__') && !__MODERATE__) {
        $template = new Template("./templates/" . __LANGUAGE__ . "/newUnmoderatedComment.html");
        $subject = "[" . $productTranslate . "] " . Utils::translate('newUnmoderatedCommentAdded');
    }

    $subject .= " [" . $page . "]";

    $ca = base64_encode($id . "&approved");
    $cr = base64_encode($id . "&deleted");
    $confirmationMsg = $template->replace(array(
        "page" => __BASE_URL__ . $page . "#" . $id,
        "text" => $text,
        "userName" => $userName,
        "user" => $name,
        "productName" => $productTranslate,
        "aproveLink" => __FEEDBACK_MODULE_URL__ . "/resources/moderate.html?c=" . $ca,
        "deleteLink" => __FEEDBACK_MODULE_URL__ . "/resources/moderate.html?c=" . $cr
    ));
    foreach ($moderators as $key => $value) {
        $mail = new Mail();
        $mail->Subject($subject);
        $mail->To($value);
        $mail->From(__EMAIL__);
        $mail->Body($confirmationMsg);
        $mail->Send();
    }
}

$ses = Session::getInstance();

if (isset($_POST["page"]) && trim($_POST["page"]) != "") {
    $info = array();
    $info["page"] = $_POST['page'];
    $info["editedId"] = (isset($_POST['editedId']) ? $_POST['editedId'] : -1);
    $info["page"] = substr($info["page"], (strlen(__BASE_PATH__)));
    $info["text"] = $_POST['text'];
    $info["referedComment"] = ((isset($_POST['comment']) && $_POST['comment']!="") ? $_POST['comment'] : 0);
    $pName = (isset($_POST['product']) ? $_POST['product'] : "");
    $pVersion = (isset($_POST['version']) ? $_POST['version'] : "");

    $fullUser = base64_encode($pName . "_" . $pVersion . "_user");
    $info["sessionUserName"] = $fullUser;
    $info["product"] = $pName;
    $info["version"] = $pVersion;
    $comment = new Comment($dbConnectionInfo, "", $fullUser);
    if ($info['editedId'] > 0) {
        // edit comment
        $result = $comment->update($info);
        if (isset($result['rows']) && $result['rows'] > 0) {
            echo "Comment edited !|" . $result['id'];
        } else {
            if (isset($result['rows'])) {
                echo "Comment not edited!";
            }
        }
    } else {
        // insert comment
        $result = $comment->insert($info);

        if ($result['rows'] > 0) {
            if (isset($ses->$fullUser)) {
                $user = $ses->$fullUser;
                $userEmail = $ses->$fullUser->email;
                $userName = $ses->$fullUser->userName;
                $name = $ses->$fullUser->name;
            } else {
                $user = new User($dbConnectionInfo);
                $userEmail = "";
                $userName = "noUser";
                $name = "noName";
            }
            $moderators = $user->getModeratorsEmails();
            $usersToNotify = $user->getUsersToNotify($info["page"], $result['id']);
            // notify moderators
            if (defined('__MODERATE__') && !__MODERATE__) {
                // unmoderated list
                if (sizeof($usersToNotify) > 0) {
                    notifyUsers($userEmail, $info["page"], $result['id'], $info["text"], $userName, $info['product'], $usersToNotify);
                }
                if (sizeof($moderators) > 0) {
                    notifyModerators($result['id'], $info["page"], $info["text"], $userName, $name, $info['product'], $moderators);
                }
            } else {
                // moderated list
                if ($user->level != 'user') {
                    // moderator or admin
                    if (sizeof($usersToNotify) > 0) {
                        notifyUsers($userEmail, $info["page"], $result['id'], $info["text"], $userName, $info['product'], $usersToNotify);
                    }
                } else {
                    // user
                    if (sizeof($usersToNotify) > 0) {
                        notifyUsers($userEmail, $info["page"], $result['id'], $info["text"], $userName, $info['product'], $usersToNotify);
                    }
                    if (sizeof($moderators) > 0) {
                        notifyModerators($result['id'], $info["page"], $info["text"], $userName, $name, $info['product'], $moderators);
                    }
                }
            }
            $toReturn = "Inserted comment!|";
            if (defined('__MODERATE__') && !__MODERATE__) {
                $toReturn .= $result['id'];
            } else {
                $toReturn .= "moderated|" . $result['id'];
            }
            echo $toReturn;
        } else {
            throw new Exception("Comment not inserted!");
            echo "Comment not inserted!";
        }
    }
} else {
    if (isset($_POST["minVersion"]) && trim($_POST["minVersion"]) != "") {
        $pName = (isset($_POST['productName']) ? $_POST['productName'] : "");
        $minVersion = (isset($_POST['minVersion']) ? $_POST['minVersion'] : "");
        $pVersion = (isset($_POST['productVersion']) ? $_POST['productVersion'] : "");

        if (!Utils::isLoggedModerator($pName, $pVersion)) {
            echo "USER_SESSION_ERROR";
            exit();
        }

        $fullUser = base64_encode($pName . "_" . $pVersion . "_user");
        $comment = new Comment($dbConnectionInfo, "", $fullUser);
        if (!$comment->setMinimalVisibleVersion($pName, $minVersion,$pVersion)) {
            echo "Fail";
        } else {
            echo "Success";
        }
    } else {
        if (isset($_POST["qVersion"]) && trim($_POST["qVersion"]) != "" && ($_POST["qVersion"] == "true")) {
            $response = new JsonResponse();
            $pName = (isset($_POST['productName']) ? $_POST['productName'] : "");
            $pVersion = (isset($_POST['productVersion']) ? $_POST['productVersion'] : "");

            if (!Utils::isLoggedModerator($pName, $pVersion)) {
                echo "USER_SESSION_ERROR";
                exit();
            }

            $fullUser = base64_encode($pName . "_" . $pVersion . "_user");
            $comment = new Comment($dbConnectionInfo, "", $fullUser);
            $vList = $comment->queryVersions($pName,$pVersion);
            $toPrint = "";
            $minVersion = $comment->getMinimVersion($pName,$pVersion);
            $idx = 0;
            foreach ($vList as $version => $visible) {
                $visible = $version >= $minVersion ? "true" : "false";
                $toPrint .= "<div class='versionTimeLine'>";
                $toPrint .= "<div class='graph'><div class='middle'></div></div>";
                $toPrint .= "<div class='v_$visible' id='ver_" . $idx . "' onclick=setVersion('" . addslashes($version) . "');>" . $version . "</div>";
                $toPrint .= "</div>";
                $idx++;
            }
            $response->set("versions", $toPrint);
            $response->set("minVersion", $minVersion);
            echo $response;
        } else {
            echo "No data to insert as comment!";
        }
    }
}
?>