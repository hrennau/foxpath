<?php
/*

Oxygen WebHelp Plugin
Copyright (c) 1998-2017 Syncro Soft SRL, Romania.  All rights reserved.

*/

/**
 * Filter all users that are not validated
 */
class ConfirmedUserFilter extends AbstractUserFilter
{

    /**
     *
     * @see IFilter::filter()
     */
    public function filter($AssociativeRowArray)
    {
        return $AssociativeRowArray['status'] == "created" && $AssociativeRowArray['userName'] != 'anonymous';
    }

    public function getSqlFilterClause()
    {
        return "userName<>'anonymous' AND (status='validated' OR status='suspended')";
    }
}

?>