<?php
/*
    
Oxygen WebHelp Plugin
Copyright (c) 1998-2017 Syncro Soft SRL, Romania.  All rights reserved.

*/

include 'init.php';


$share = "";
if (isset($_REQUEST['version']) && trim($_REQUEST['version']) != '') {
    $version = trim($_REQUEST['version']);
    $product = new Product($dbConnectionInfo, $version);
    $shareFrom = $product->getSharedWith();
    foreach ($shareFrom as $productId => $productName) {
        $share .= "<div class=\"shareF\"><span class=\"sharePID\">" . $productId . "</span><span class=\"sharePName\">" . $productName . "</span></div>";
    }
}
echo $share;

?>