<?php

/*

Oxygen WebHelp Plugin
Copyright (c) 1998-2017 Syncro Soft SRL, Romania.  All rights reserved.

*/

class Template
{
    /**
     * Tempplate file content
     * @var string
     */
    private $template;

    /**
     * Constructor
     * @param string $filepath template file path
     */
    function __construct($filepath)
    {
        $opts = array('http' => array('header' => 'Accept-Charset: UTF-8, *;q=0'));
        $context = stream_context_create($opts);
        $this->template = file_get_contents($filepath, false, $context);
    }

    /**
     * Replace provided value in template
     *
     * @param array $content array containing pairs of value to be replaced => value to preplace with
     * @return content of the template after replacement
     */
    function replace($content)
    {
        foreach ($content as $key => $val) {
            $this->template = str_replace("#$key#", $val, $this->template);
        }
        return $this->template;
    }

}

?>