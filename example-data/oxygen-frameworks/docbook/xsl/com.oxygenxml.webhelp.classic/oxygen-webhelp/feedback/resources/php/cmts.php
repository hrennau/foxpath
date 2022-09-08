<?php
/*
    
Oxygen WebHelp Plugin
Copyright (c) 1998-2017 Syncro Soft SRL, Romania.  All rights reserved.

*/

function readCms($includeFile)
{
    $contents = '';
    if (file_exists($includeFile)) {
        $handle = fopen($includeFile, "r");
        while (!feof($handle)) {
            $contents .= fread($handle, filesize($includeFile));
        }
        fclose($handle);
    }
    //sleep(5);
    return $contents;
}

if ($_POST['isInstaller']) {
    $baseDir = dirname(dirname(__FILE__));
    $depthStr = "";
    if (isset($_POST['depth']) && trim($_POST['depth']) != '') {
        $depthStr = trim($_POST['depth']);
    }

    $realInclude = $baseDir . '/cmts.html';
    $contents = readCms($realInclude);
    $contents = str_replace("@relPath@", $depthStr, $contents);
    ob_start();
    ob_clean();
    flush();
    echo $contents;
    ob_end_flush();
} else {

    $baseDir = dirname(dirname(__FILE__));
    require_once $baseDir . '/php/init.php';

    $ses = Session::getInstance();
    if (!isset($ses->errBag)) {
        $ses->errBag = new OxyBagHandler();
    }

    $depthStr = "";
    if (isset($_POST['depth']) && trim($_POST['depth']) != '') {
        $depthStr = trim($_POST['depth']);
    }

    $realInclude = $baseDir . '/cmts.html';
    $contents = readCms($realInclude);
    $contents = str_replace("@relPath@", $depthStr, $contents);
    ob_start();
    ob_clean();
    flush();
    echo $contents;
    ob_end_flush();

}
?>
