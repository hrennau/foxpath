<?php

/*

Oxygen WebHelp Plugin
Copyright (c) 1998-2017 Syncro Soft SRL, Romania.  All rights reserved.

*/

class NoFilter implements IFilter
{
    /**
     *
     * @see IFilter::filter()
     */
    public function filter($AssociativeRowArray)
    {
        return false;
    }

    public function getSqlFilterClause()
    {
        return null;
    }
}

?>