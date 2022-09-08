<?php

/*

Oxygen Webhelp Plugin
Copyright (c) 1998-2017 Syncro Soft SRL, Romania.  All rights reserved.

*/

abstract class AbstractUserFilter implements IFilter
{
    protected $lastDate;
    protected $dateField;

    /**
     * Constructor
     */
    function __construct($lastDays, $dateField)
    {
        $this->lastDate = date("Y-m-d H:i:s", strtotime($lastDays . " day"));
        $this->dateField = $dateField;
    }
}

?>