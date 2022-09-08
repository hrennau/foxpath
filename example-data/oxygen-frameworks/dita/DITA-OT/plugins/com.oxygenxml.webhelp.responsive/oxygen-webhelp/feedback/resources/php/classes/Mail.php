<?php

/*

Oxygen WebHelp Plugin
Copyright (c) 1998-2017 Syncro Soft SRL, Romania.  All rights reserved.

*/

class Mail
{

    private $subject;
    private $from;
    private $replyTo;
    private $sendTo = array();
    private $ccTo = array();
    private $bccTo = array();
    private $body;
    private $headers;
    private $use_mb;

    function __construct()
    {
        $this->use_mb = function_exists('mb_send_mail');
        if ($this->use_mb) {
            mb_language('uni');
            mb_internal_encoding('UTF-8');
        }
    }


    function Subject($subject)
    {
        $this->subject = strtr($subject, "\r\n", "  ");
    }

    function From($from)
    {
        if (!is_string($from)) {
            throw new Exception("Class Mail: error, From is not a string");
        }
        $this->from = $from;
    }

    function ReplyTo($address)
    {

        if (!is_string($address)) {
            throw new Exception("Class Mail: error, Reply-To is not a string");
        }
        $this->replyTo = $address;
    }


    function To($to)
    {
        if (is_array($to)) {
            $this->sendTo = $to;
        } else {
            $this->sendTo[] = $to;
        }

    }

    function Cc($cc)
    {
        if (is_array($cc)) {
            $this->ccTo = $cc;
        } else {
            $this->ccTo[] = $cc;
        }


    }

    function Bcc($bcc)
    {
        if (is_array($bcc)) {
            $this->bccTo = $bcc;
        } else {
            $this->bccTo[] = $bcc;
        }

    }

    function Body($body)
    {
        $this->body = $body;
    }

    function Organization($org)
    {
        if (trim($org != "")) {
            $this->organization = $org;
        }
    }

    private function parse_rfc822_address(
        $rfc822_address
    ) {
        $trimmed_rfc822_address = trim($rfc822_address);

        $may_have_display = preg_match('/^(.*)<(.+)>$/', $trimmed_rfc822_address, $matches);
        if ($may_have_display) {
            $parsed['display'] = trim($matches[1]);
            $parsed['address'] = $matches[2];
        } else {
            $parsed['display'] = '';
            $parsed['address'] = $trimmed_rfc822_address;
        }

        return $parsed;
    }

    private function encode_rfc822_address(
        $rfc822_address
    ) /*
		Encode the display name part, leaving the email address part intact.
		No encode when mb functions are not available.
	*/
    {
        $parsed = $this->parse_rfc822_address($rfc822_address);

        $encoded_display = $this->use_mb
            ? mb_encode_mimeheader($parsed['display'])
            : $parsed['display'];

        $concated = $encoded_display;
        $concated .= $encoded_display ? " <" : '';
        $concated .= $parsed['address'];
        $concated .= $encoded_display ? '>' : '';
        return $concated;
    }

    private function encode_and_flatten_rfc822_address_array(
        $rfc822_address_array
    ) {
        $encoded_array = array_map(array($this, 'encode_rfc822_address'), $rfc822_address_array);
        $encoded_flatten = implode(",\r\n", $encoded_array);
        return $encoded_flatten;
    }

    private function build_address_header_line(
        $header_name,
        $rfc822_address_or_array
    ) {
        $encoded = is_array($rfc822_address_or_array)
            ? $this->encode_and_flatten_rfc822_address_array($rfc822_address_or_array)
            : $this->encode_rfc822_address($rfc822_address_or_array);

        $line = $header_name . ': ' . $encoded . "\r\n";
        return $line;
    }

    private function build()
    {
        $this->headers = "";

        if (count($this->ccTo) > 0) {
            $this->headers .= $this->build_address_header_line('CC', $this->ccTo);
        }

        if (trim($this->replyTo) != "") {
            $this->headers .= $this->build_address_header_line('Reply-To', $this->replyTo);
        }
        $this->headers .= $this->build_address_header_line('From', $this->from);


        if (count($this->bccTo) > 0) {
            $this->headers .= $this->build_address_header_line('BCC', $this->bccTo);
        }
        // $this->xheaders['BCC'] = implode( ", ", $this->abcc );
        $this->headers .= "X-Mailer: oXygen Webhelp system\r\n";
        $this->headers .= "MIME-Version: 1.0\r\n";
        $this->headers .= "Content-Type: text/html; charset=UTF-8\r\n";
    }

    function Send()
    {
        $this->build();

        $encoded_sendTo = $this->encode_and_flatten_rfc822_address_array($this->sendTo);

        $result = $this->use_mb
            ? @mb_send_mail($encoded_sendTo, $this->subject, $this->body, $this->headers)
            : @mail($encoded_sendTo, $this->subject, $this->body, $this->headers);
        return $result;
    }


} // class Mail

?>