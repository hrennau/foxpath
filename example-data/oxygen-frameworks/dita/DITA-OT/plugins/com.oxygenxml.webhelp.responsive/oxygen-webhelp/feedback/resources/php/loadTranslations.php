<?php
/*
    
Oxygen WebHelp Plugin
Copyright (c) 1998-2017 Syncro Soft SRL, Romania.  All rights reserved.

*/

include_once "config.php";
include_once "../localization/strings.php";
global $localization;
$toReturn = new JsonResponse();
foreach ($localization as $key => $translation) {
    $toReturn->set($key, $translation);
}
echo $toReturn;
?>