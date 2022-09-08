<?php
/*
    
Oxygen WebHelp Plugin
Copyright (c) 1998-2017 Syncro Soft SRL, Romania.  All rights reserved.

*/



function isDebug()
{
    return defined('__DEBUG__') && __DEBUG__;
}

function getUpDir($level)
{
    $i = 1;
    $toReturn = dirname(__FILE__);
    while ($i < $level) {
        $i++;
        $toReturn = dirname($toReturn);
    }
    return $toReturn;
}

$baseDir = dirname(dirname(__FILE__));

define("__BASE_DIR__", getUpDir(5));

if (!strstr($_SERVER['PHP_SELF'], "checkInstall.php") && !strstr($_SERVER['PHP_SELF'], "install/index.php") && !strstr($_SERVER['PHP_SELF'],
        "install/index1.php") && !strstr($_SERVER['PHP_SELF'], "install/do_install.php")
) {
    if (file_exists($baseDir . '/php/config/config.php')) {
        include_once $baseDir . '/php/config/config.php';
        $ses = Session::getInstance();
        if (!isset($ses->errBag)) {
            $ses->errBag = new OxyBagHandler();
        }

        if (!defined('__FEEDBACK_MODULE_PATH__')) {
            $server_protocol = 'http://';
            if (isset($_SERVER['HTTPS'])) {
                if ($_SERVER['HTTPS'] != 'off' && $_SERVER['HTTPS'] != '') {
                    $server_protocol = 'https://';
                }
            }
            // The relative URL where the feedback module is installed on with trailing /
            define('__FEEDBACK_MODULE_PATH__', dirname(dirname(dirname($_SERVER["PHP_SELF"]))));
            if (!defined('__FEEDBACK_MODULE_URL__')) {
                // The absolute URL where the feedback module is installed on with trailing /
                define('__FEEDBACK_MODULE_URL__', __BASE_URL__ . str_replace(__BASE_PATH__, "", __FEEDBACK_MODULE_PATH__));
            }

        }
    } else {
        error_log("warn couldn't find " . $baseDir . '/php/config/config.php');
    }
}
global $dbConnectionInfo;

if (file_exists($baseDir . '/localization/strings.php')) {
    include_once $baseDir . '/localization/strings.php';
}

//set error handler
set_error_handler("OxyHandler::error");
set_exception_handler("OxyHandler::exception");

if (defined('__TIMEZONE__')) {
    date_default_timezone_set(__TIMEZONE__);
} else {
    if (!ini_get('date.timezone')) {
        date_default_timezone_set('UTC');
    }
}

// if (!isset($dbConnectionInfo)){
// 	throw new Exception("DB connection info not available!");
// }


/**
 * Loads a class form a specified directory
 * @param String $dirToCheck directory to cheeck for class
 * @param String $fileName class to load
 * @return boolean
 */
function loadClassFromDir($dirToCheck, $fileName)
{
    $toReturn = false;
    if ($handle = opendir($dirToCheck)) {
        /* recurse through directory. */
        while (false !== ($directory = readdir($handle)) && !$toReturn) {
            if (is_dir($dirToCheck . $directory)) {
                if ($directory != "." && $directory != "..") {
                    $path = trim($dirToCheck . $directory . "/" . $fileName . ".php");
                    if (file_exists($path)) {
                        require_once $path;
                        $toReturn = true;
                    }
                    if (!$toReturn) {
                        $toReturn = loadClassFromDir($dirToCheck . $directory . "/", $fileName);
                    }
                }
            }
        }
        closedir($handle);
    }
    if (isDebug()) {
        echo 'File : ' . $fileName;
        if ($toReturn) {
            echo " found in ";
        } else {
            echo " not found in ";
        }
        echo $dirToCheck . "<br/>";
    }
    return $toReturn;
}

/**
 * @param String $name
 * @throws Exception
 */
function __autoload($name)
{
    $found = false;
    if (isDebug()) {
        echo "Document Root:" . $_SERVER['DOCUMENT_ROOT'] . "<br/>";
        if (defined('__BASE_URL__')) {
            echo "Base URL:" . __BASE_URL__ . "<br/>";
        }
    }
    $baseDir = dirname(dirname(__FILE__));


    if (isDebug()) {
        echo 'dir:' . $baseDir . "<br/>";
    }
// 	if (defined('__BASE_URL__')){
// 		$parts=explode("/", __BASE_URL__,4);
// 	 if (count($parts)<4){
// 		  $classPath = $_SERVER['DOCUMENT_ROOT']."/oxygen-webhelp/resources/php/classes/";
//     }else{
//       $classPath = $_SERVER['DOCUMENT_ROOT']."/".$parts[3]."/oxygen-webhelp/resources/php/classes/";
//     }
// 	}else{		
    $classPath = $baseDir . "/php/classes/";
// 	}
    if (isDebug()) {
        echo 'classPath:' . $classPath . "<br/>";
    }

    $directory = $classPath;
    $path = $classPath . $name . ".php";
    if (file_exists($path)) {
        require_once $path;
        $found = true;
    } else {
        $found = loadClassFromDir($classPath, $name);
    }

    if (!$found) {
        echo "Can not load $name from $classPath" . "<br/>\n";
        throw new Exception("Unable to load $name.");
    }
}

?>