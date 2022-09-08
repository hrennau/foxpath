<?php
/*
    
Oxygen WebHelp Plugin
Copyright (c) 1998-2017 Syncro Soft SRL, Romania.  All rights reserved.

*/

if (!headers_sent()) {
    header('Content-Type: text/html; charset=utf-8');
}

phpinfo();
// enable debug
define('__DEBUG__', true);
$baseDir0 = dirname(dirname(__FILE__));
include $baseDir0 . '/resources/php/init.php';

?>