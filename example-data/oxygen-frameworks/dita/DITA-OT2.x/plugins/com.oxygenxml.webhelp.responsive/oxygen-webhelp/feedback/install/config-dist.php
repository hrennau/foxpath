<?php
/*
    
Oxygen WebHelp Plugin
Copyright (c) 1998-2017 Syncro Soft SRL, Romania.  All rights reserved.

*/

require_once('config.ldap.php');

// The language of WebHelp 
define('__LANGUAGE__', '@LANGUAGE@');

// Email address to be used as from in sent emails
define('__EMAIL__', 'no-reply@oxygenxml.com');

// Email address to be notified when error occur
define('__ADMIN_EMAIL__', 'no-reply@oxygenxml.com');

// Send errors to system administartor?
define('__SEND_ERRORS__', true);

// If the system is moderated each post must be confirmed by moderator
define('__MODERATE__', true);

// User session life time in seconds, by default is 7 days
define('__SESSION_LIFETIME__', 604800);

// Is unauthenticated user allowed to post comments
define('__GUEST_POST__', true);

$dbConnectionInfo['dbName'] = 'comments';
$dbConnectionInfo['dbUser'] = 'oxygen';
$dbConnectionInfo['dbPassword'] = 'oxygen';
$dbConnectionInfo['dbHost'] = 'localhost';

?>