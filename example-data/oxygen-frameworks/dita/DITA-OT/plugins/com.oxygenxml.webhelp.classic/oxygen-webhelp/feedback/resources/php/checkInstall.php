<?php
/*
    
Oxygen WebHelp Plugin
Copyright (c) 1998-2017 Syncro Soft SRL, Romania.  All rights reserved.

*/

require_once "init.php";
$cfgFile = './config/config.php';
$cfgInstall = '../../install/';
$toReturn = new JsonResponse();
if (file_exists($cfgInstall)) {
    $toReturn->set("installPresent", "true");
} else {
    $toReturn->set("installPresent", "false");
}
if (file_exists($cfgFile) && filesize($cfgFile) > 0) {
    $toReturn->set("configPresent", "true");
} else {
    $toReturn->set("configPresent", "false");
}
echo $toReturn;

?>