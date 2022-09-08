<?php
/*

Oxygen WebHelp Plugin
Copyright (c) 1998-2017 Syncro Soft SRL, Romania.  All rights reserved.


*/

/**
 * Cell renderer
 *
 * @author serban
 *
 */
interface ICellRenderer
{
    /**
     * Render cell for field with the specied value
     *
     * @param String $fieldName
     * @param Stringe $fieldValue
     */
    function render($fieldName, $fieldValue);

    function setAName($name);
}

?>