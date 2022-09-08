<?php

/*

Oxygen Webhelp Plugin
Copyright (c) 1998-2017 Syncro Soft SRL, Romania.  All rights reserved.

*/

class MissingPageFilter implements IFilter
{
    private $baseDir;
    private $pageField;

    /**
     * Constructor
     */
    function __construct($baseDir, $field)
    {
        $this->baseDir = $baseDir;
        $this->pageField = $field;
    }

    /**
     *
     * @see IFilter::filter()
     */
    public function filter($AssociativeRowArray)
    {
        // __BASE_DIR__
        $toReturn = false;
        $file = $this->baseDir . DIRECTORY_SEPARATOR . str_replace("/", DIRECTORY_SEPARATOR, $AssociativeRowArray[$this->pageField]);
        if (!file_exists($file)) {
            $toReturn = true;
        }
        return $toReturn;
    }

    public function getSqlFilterClause()
    {
        return null;
    }
}

?>