<?php
/*
    
Oxygen WebHelp Plugin
Copyright (c) 1998-2017 Syncro Soft SRL, Romania.  All rights reserved.

*/

if (!headers_sent()) {
    header('Content-Type: text/html; charset=utf-8');
}

$baseDir0 = dirname(dirname(__FILE__));
include $baseDir0 . '/resources/php/init.php';

$version = "@PRODUCT_VERSION@";

if (isset($_POST['host']) && isset($_POST['user']) && isset($_POST['passwd']) && isset($_POST['db'])) {
    $dbConnectionInfo = array(
        'dbHost' => $_POST['host'],
        'dbName' => $_POST['db'],
        'dbPassword' => $_POST['passwd'],
        'dbUser' => $_POST['user']
    );
    try {
        $db = new RecordSet($dbConnectionInfo, false, true);
        $prds = $db->Open("Select product,value from webhelp where parameter='name' and version='" . $db->sanitize($version) . "'; ");
        if ($prds > 0) {
            echo "<div class=\"title\">Display comments from</div>
			<div class=\"desc\">Share other products comments (having the same version) with this one. You must select one or more products from the list. Hold down the Ctrl (windows) / Command (Mac) button to select multiple options. </div>
			<table>
			<tr>
			<td>Existing products sharing the same database
			</td>
			<td>";

            echo "<select multiple=\"multiple\" name=\"shareWith[]\" size=\"5\">";
            while ($db->MoveNext()) {
                $product = $db->Field('product');
                $name = $db->Field('value');
                echo "<option value=\"" . $product . "\">" . $name . "</option>";
            }
            echo "</select>";
            echo "</td>
			</tr></table></div>";
        }
    } catch (Exception $ex) {
        echo "<br/>Could not connect to database using specified information:";
        echo "<table class=\"info\">";
        echo "<tr><td>Host </td><td>" . $dbConnectionInfo['dbHost'] . "</td></tr>";
        echo "<tr><td>Database </td><td>" . $dbConnectionInfo['dbName'] . "</td></tr>";
        echo "<tr><td>User </td><td>" . $dbConnectionInfo['dbUser'] . "</td></tr>";
        echo "</table>";
        echo "<br/>Details: (" . $ex->getCode() . ") " . $ex->getMessage();
        $continue = false;
    }
}

?>