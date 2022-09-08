<?php

/*

Oxygen WebHelp Plugin
Copyright (c) 1998-2017 Syncro Soft SRL, Romania.  All rights reserved.

*/

interface IFilter
{
    /**
     * Filter or not the values to be exported
     * @param array $AssociativeRowArray row to be exported
     * @return boolean <code>true</code> if the specified row is to be filtered
     */
    public function filter($AssociativeRowArray);

    /**
     * Get SQL filter clause
     */
    public function getSqlFilterClause();
}

?>