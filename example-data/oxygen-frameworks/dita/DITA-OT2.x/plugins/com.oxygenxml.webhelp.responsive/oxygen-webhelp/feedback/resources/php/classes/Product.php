<?php

/*

Oxygen WebHelp Plugin
Copyright (c) 1998-2017 Syncro Soft SRL, Romania.  All rights reserved.

*/

class Product
{
    private $dbConnectionInfo;
    private $version;

    function __construct($dbConnectionInfo, $version)
    {
        $this->dbConnectionInfo = $dbConnectionInfo;
        $this->version = $version;
    }

    /**
     * @return array all products that share comments with this one
     */
    function getSharedWith()
    {
        $toReturn = array();
        $db = new RecordSet($this->dbConnectionInfo, false, true);
        $query = "Select product,value from webhelp where parameter='name' and version='" . $db->sanitize($this->version) . "' ";

        if (defined('__SHARE_WITH__')) {
            $query .= "AND product in (";
            $shareArray = explode(",", __SHARE_WITH__);
            foreach ($shareArray as $key => $value) {
                $query .= "'" . $db->sanitize($value) . "', ";
            }
            $query = substr($query, 0, -2) . ");";
        }

        $prds = $db->Open($query);

        if ($prds > 0) {
            while ($db->MoveNext()) {
                $product = $db->Field('product');
                $value = $db->Field('value');
                $toReturn[$product] = $value;

            }
        }
        $db->close();
        return $toReturn;
    }
}

?>