<?php
/*
    
Oxygen WebHelp Plugin
Copyright (c) 1998-2017 Syncro Soft SRL, Romania.  All rights reserved.

*/

/**
 * @deprecated
 */
header('Content-Type: text/css');

$baseDir = dirname(dirname(__FILE__));
require_once $baseDir . '/php/init.php';

$admin = (isset($_GET['admin']) && $_GET['admin'] == "true") ? true : false;

$baseUrl = (isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] != 'off') ? 'https://' : 'http://';
$baseUrl .= isset($_SERVER['HTTP_HOST']) ? $_SERVER['HTTP_HOST'] : getenv('HTTP_HOST');
$baseUrl .= isset($_SERVER['SCRIPT_NAME']) ? dirname(dirname(dirname(dirname($_SERVER['SCRIPT_NAME'])))) : dirname(dirname(getenv('SCRIPT_NAME')));

$baseUrl = rtrim($baseUrl, '/\\');

$browser = Utils::getBrowser();
if (defined('__THEME__')) {
    $sufix = __THEME__ . "";
} else {
    $sufix = "";
}


switch ($browser['ub']) {
    case "Chrome":
        $sufix = "c_";
        break;
    case "Firefox":
        $sufix = "f_";
        break;
    case "MSIE":
        $sufix = "i_";
        break;
    case "Safari":
        $sufix = "s_";
        break;
    case "Opera":
        $sufix = "o_";
        break;
    case "Netscape":
        $sufix = "n_";
        break;
}

readCss($baseDir . "/css/", $sufix, "comments.css");

if ($admin) {
    readCss($baseDir . "/css/", $sufix, "admin.css");
    loadAdditionalStyles();
}

/**
 * read and puts css content
 *
 * @param String $file
 */
function readCss($path, $sufix, $fileName)
{
    $file = $path . $sufix . $fileName;
    if (file_exists($file)) {
        $includeFile = $file;
    } else {
        $file = $path . $fileName;
        if (file_exists($file)) {
            $includeFile = $file;
        } else {
            echo "/* invalid file : " . $path . $sufix . $fileName . " or " . $path . $fileName . " */";
            exit;
        }
    }

    $handle = fopen($includeFile, "r");
    $contents = '';
    while (!feof($handle)) {
        $contents .= fread($handle, 8192);
    }
    fclose($handle);
    echo $contents;

}

/**
 * Additional styles can be found in skins:
 *  1. Templates for responsive-WebHelp (oxygen-webhelp/template/resources/css/wt_default.css and E:\www\forTest\oxygen-webhelp\template\variants\tiles\oxygen\skin.css)
 *  2. Skins for classic WebHelp (oxygen-webhelp\resources\skins\skin.css)
 */
function loadAdditionalStyles() {
    /**
     * Load the classic skin if exists otherwise load template CSS's
     */

    if (file_exists(__BASE_DIR__ . DIRECTORY_SEPARATOR . 'oxygen-webhelp' . DIRECTORY_SEPARATOR . 'resources' . DIRECTORY_SEPARATOR  . 'skins' .
        DIRECTORY_SEPARATOR .
        'skin.css')) {
        readCss("", "", __BASE_DIR__ . DIRECTORY_SEPARATOR . 'oxygen-webhelp' . DIRECTORY_SEPARATOR . 'resources' . DIRECTORY_SEPARATOR  . 'skins' .
            DIRECTORY_SEPARATOR .
            'skin.css');
    } else {
        $Directory = new RecursiveDirectoryIterator(__BASE_DIR__ . DIRECTORY_SEPARATOR. 'oxygen-webhelp' . DIRECTORY_SEPARATOR . 'template');
        $Iterator = new RecursiveIteratorIterator($Directory);
        $Regex = new RegexIterator($Iterator, '/^.+(skin|wt_default)\.css$/i', RecursiveRegexIterator::GET_MATCH);

        foreach ($Regex as $key => $value) {
            readCss("", "", $value[0]);
        }
    }
}

?>