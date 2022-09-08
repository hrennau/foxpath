<?php
/*

Oxygen WebHelp Plugin
Copyright (c) 1998-2017 Syncro Soft SRL, Romania.  All rights reserved.

*/

/**
 * Exporter Interface
 *
 * @author serban
 *
 */
interface IExporter
{
    /**
     * Export one row
     * @param Array $AssociativeRowArray - array containing fieldName=>fieldValue
     */
    function exportRow($AssociativeRowArray);

    /**
     * Return the exported contents
     * @return String content exported
     */
    function getContent();

    /**
     * Enable rowFilter by setting this filter
     * @param IFilter $filter
     */
    function setFilter($filter);

    /**
     * Get current filter
     * @return IFilter
     */
    function getFilter();
}

?>