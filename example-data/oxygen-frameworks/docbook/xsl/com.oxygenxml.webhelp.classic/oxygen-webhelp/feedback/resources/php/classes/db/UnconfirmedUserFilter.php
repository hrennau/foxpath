<?php
/*

Oxygen WebHelp Plugin
Copyright (c) 1998-2017 Syncro Soft SRL, Romania.  All rights reserved.

*/

/**
 * Filter all users that are validated or waiting for validation
 */
class UnconfirmedUserFilter extends AbstractUserFilter
{

    /**
     *
     * @see IFilter::filter()
     */
    public function filter($AssociativeRowArray)
    {
        return $AssociativeRowArray[$this->dateField] >= $this->lastDate && $AssociativeRowArray['userName'] != 'anonymous';
    }

    public function getSqlFilterClause()
    {
        return $this->dateField . "<'" . $this->lastDate . "' AND status='created' AND userName<>'anonymous'";
    }
}

?>