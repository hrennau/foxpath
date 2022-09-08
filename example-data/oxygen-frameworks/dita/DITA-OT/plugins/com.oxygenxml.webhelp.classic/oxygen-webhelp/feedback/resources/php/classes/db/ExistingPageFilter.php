<?php

/*

Oxygen WebHelp Plugin
Copyright (c) 1998-2017 Syncro Soft SRL, Romania.  All rights reserved.

*/

class ExistingPageFilter implements IFilter
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
        $toReturn = true;
        $file = $this->baseDir . DIRECTORY_SEPARATOR . str_replace("/", DIRECTORY_SEPARATOR, $AssociativeRowArray[$this->pageField]);
        if (!file_exists($file)) {
            $toReturn = false;
        }
        return $toReturn;
    }

    public function getSqlFilterClause()
    {
        return null;
    }
}

?>