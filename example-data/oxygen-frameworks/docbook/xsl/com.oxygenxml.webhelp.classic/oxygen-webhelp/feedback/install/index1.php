<?php
/*
    
Oxygen WebHelp Plugin
Copyright (c) 1998-2017 Syncro Soft SRL, Romania.  All rights reserved.

*/

if (!headers_sent()) {
    header('Content-Type: text/html; charset=utf-8');
}

require_once '../config/config.php';

$cfgFile = '../resources/php/config/config.php';
if (file_exists($cfgFile) && filesize($cfgFile) > 0) {
    @include_once $cfgFile;
} else {
    @include_once './config-dist.php';
}
global $dbConnectionInfo;
$baseUrl = (isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] != 'off') ? 'https://' : 'http://';
$baseUrl .= isset($_SERVER['HTTP_HOST']) ? $_SERVER['HTTP_HOST'] : getenv('HTTP_HOST');
$baseUrl .= isset($_SERVER['SCRIPT_NAME']) ? dirname(dirname(dirname(dirname($_SERVER['SCRIPT_NAME'])))) : dirname(dirname(dirname(dirname(getenv
('SCRIPT_NAME')))));

$baseUrl = rtrim($baseUrl, '/\\');
$baseUrl .= "/";
$baseDir0 = dirname(dirname(__FILE__));
if (!defined("__BASE_URL__")) {
    define("__BASE_URL__", $baseUrl);
}

if (!defined("__BASE_PATH__")) {
    $file = $_SERVER["SCRIPT_NAME"];
    $break = Explode('/', $file);
    $pfile = $break[count($break) - 4] . '/' . $break[count($break) - 3] . '/' . $break[count($break) - 2] . '/' . $break[count($break) - 1];
    $relPath = "";
    if (strpos($_SERVER['REQUEST_URI'], $pfile)) {
        $pos = strpos($_SERVER['REQUEST_URI'], $pfile);
        $relPath = substr($_SERVER['REQUEST_URI'], 0, $pos);
    }
    define("__BASE_PATH__", $relPath);
}

//require_once DP_BASE_DIR.'/oxygen-webhelp/resources/php/classes/db/RecordSet.php';
include $baseDir0 . '/resources/php/init.php';
$ses = Session::getInstance();
function sval($str, $default)
{
    if (isset($_SESSION[$str])) {
        return $_SESSION[$str];
    } else {
        return $default;
    }
}

function check($id, $name)
{
    if (isset($_SESSION[$name])) {
        if ($_SESSION[$name] == 'on') {
            echo "<script>$('#" . $id . "').attr('checked','checked');</script>";
        } else {
            echo "<script>$('#" . $id . "').removeAttr('checked');</script>";
        }
    }
}

?>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang="en-US">
<head>
    <title>&lt;oXygen/&gt; XML Editor - WebHelp</title>
    <meta name="Description" content="WebHelp Installer"/>
    <META HTTP-EQUIV="CONTENT-LANGUAGE" CONTENT="en-US"/>
    <link rel="stylesheet" type="text/css" href="../resources/bootstrap/css/bootstrap.min.css"/>
    <link rel="stylesheet" type="text/css" href="install.css"/>
    <script src="../resources/js/jquery-3.1.1.min.js"></script>
</head>
<body>
<div id="logo" class="text-center">
    <img src="../../resources/img/LogoOxygen100x22.png" align="middle" alt="OxygenXml Logo"/>
    WebHelp Installer
</div>
<h1 class="text-center">
    Installation Settings for
    <span class="titProduct"><?php echo __PRODUCT_NAME__; ?></span>&nbsp;<span class="titProduct"><?php echo __PRODUCT_VERSION__; ?></span>
</h1>

<form id="doInstallData" name="installForm" action="do_install.php" method="post">
    <div class="container">
        <?php
        $cfgFile = '../resources/php/config/config.php';
        if (file_exists($cfgFile) && filesize($cfgFile) > 0) {
            ?>
            <div class="panel">
                <div class="title">Configuration File</div>
                <table>
                    <tr>
                        <td>
                            Overwrite Config File
                            <div class="settingDesc">Replaces the existing config file.</div>
                        </td>
                        <td>
                            <input type="checkbox" id="ck_OverWrite" name="overWriteConfig" title="Overwrite config file if exists."/>
                            <?php check('ck_OverWrite', 'overWriteConfig'); ?>
                        </td>
                    </tr>
                </table>
            </div>
            <?php
        } else {
            echo "<input type='hidden' id='ck_OverWriteHid' name='overWriteConfig' value='on' />";
        }
        ?>

        <div class="panel" id="cfgPanel" style="display: none;">
            <div class="title">Deployment Settings</div>
            <table>
                <tr>
                    <td>WebHelp Feedback Time Zone
                        <div class="settingDesc">Set time zone for this product.</div>
                    </td>
                    <td>
                        <?php echo defined("__TIMEZONE__") ? Utils::getTimeZonesController(__TIMEZONE__) : Utils::getTimeZonesController(null); ?>
                    </td>
                </tr>
                <?php echo "<input type='hidden' id='language' name='language' value='" . __LANGUAGE__ . "'/>"; ?>
                <tr>
                    <td>User friendly product name
                        <div class="settingDesc">Product name that will be used in emails subject.</div>
                    </td>
                    <td>
                        <input type="text" class="form-control" name="productName" value="<?php echo sval('productName', __PRODUCT_NAME__); ?>"
                               title="Product name that will be used in emails subject"/>
                    </td>
                </tr>
                <tr>
                    <td>Deployment URL
                        <div class="settingDesc">The URL where the webhelp is installed on.</div>
                    </td>
                    <td>
                        <input type="text" class="form-control" name="baseUrl" onfocus="this.blur()" readonly="readonly"
                               value="<?php echo sval('baseUrl', $baseUrl); ?>" title="The URL where the webhelp is installed on"/>
                        <input type="hidden" name="basePath" value="<?php echo sval('basePath', __BASE_PATH__); ?>"/>
                    </td>
                </tr>
                <tr>
                    <td>SMTP server
                        <div class="settingDesc">This can be changed by altering your PHP Runtime Configuration, usually located in "php.ini" file</div>
                    </td>
                    <td>
                        <input type="text" class="form-control" name="smtp" onfocus="this.blur()" readonly="readonly"
                               value="<?php echo ini_get("SMTP") . " : " . ini_get("smtp_port") ?>" title=" The email server used "/>
                    </td>
                </tr>
                <tr>
                    <td>WebHelp E-mail address
                        <div class="settingDesc">This e-mail address is used as the 'From' address in e-mails.</div>
                    </td>
                    <td><input type="text" class="form-control" name="email" value="<?php echo sval('email', __EMAIL__); ?>"
                               title="Email address to be used as From in sent emails"/></td>
                </tr>
                <tr>
                    <td>
                        Comment system is moderated
                        <div class="settingDesc">If the system is moderated each post must be confirmed by moderator.</div>
                    </td>
                    <td>
                        <div class="checkbox">
                            <label>
                            <input id="ckModerate" type="checkbox" name="moderated" <?php
                                if (__MODERATE__ == "true") {
                                    echo "checked=checked";
                                } ?> title="If the system is moderated each post must be confirmed by moderator"/>
                                <?php check('ckModerate', 'moderated'); ?>
                            </label>
                        </div>
                    </td>
                </tr>
                <tr>
                    <td>Session lifetime (sec)
                        <div class="settingDesc">User session lifetime in seconds, by default is 7 days.</div>
                    </td>
                    <td>
                        <input type="text" class="form-control" name="sesLifeTime" value="<?php echo sval('sesLifeTime', __SESSION_LIFETIME__); ?>"
                               title="User session lifetime in seconds, by default is 7 days"/>
                    </td>
                </tr>
                <tr>
                    <td>Allow posts as 'Anonymous'
                        <div class="settingDesc">This allows the unauthenticated user to post comments.</div>
                    </td>
                    <td>
                        <div class="checkbox">
                            <label>
                                <input id="ckAnonPost" type="checkbox" name="anonymousPost" <?php
                                if (__GUEST_POST__ == "true") {
                                    echo "checked=checked";
                                } ?> title="Is unauthenticated user allowed to post comments"/>
                                <?php check('ckAnonPost', 'anonymousPost'); ?>
                            </label>
                        </div>

                    </td>
                </tr>
                <tr>
                    <td>Enable LDAP Authentication
                        <div class="settingDesc">If checked, enable LDAP authentication.</div>
                    </td>
                    <td>
                        <div class="checkbox">
                            <label>
                                <input id="enableLdap" type="checkbox" name="enableLdap"
                                    <?php
                                    if (LDAP_AUTH == "true") {
                                        echo "checked=checked";
                                    }
                                    ?> title="Enable LDAP Authentication"/>
                            </label>
                        </div>

                    </td>
                </tr>
            </table>
        </div>

        <div class="panel" id="ldapPanel" style="display:none;">
            <div class="title">LDAP Server Settings</div>
            <div class="desc">Please contact your system administrator for LDAP server settings.</div>
            <table>
                <tr>
                    <td>Server Hostname
                        <div class="settingDesc">LDAP server hostname</div>
                    </td>
                    <td>
                        <input type="text" class="form-control" id="ldapHost" name="ldapHost" value="<?php echo sval('ldapHost', LDAP_SERVER); ?>"
                               title="IP address or host name of LDAP server"/>
                    </td>
                </tr>
                <tr>
                    <td>Server Port
                        <div class="settingDesc">LDAP server port (389 by default)</div>
                    </td>
                    <td>
                        <input type="text" class="form-control" id="ldapPort" name="ldapPort" value="<?php echo sval('ldapPort', LDAP_PORT); ?>"
                               title="The LDAP server port"/>
                    </td>
                </tr>
                <tr>
                    <td>SSL Verify
                        <div class="settingDesc">By default, require certificate to be verified for ldaps:// style URL. Uncheck to skip the verification
                        </div>
                    </td>
                    <td>
                        <div class="checkbox">
                            <label>
                                <input id="ldapSslVerify" type="checkbox" name="ldapSslVerify" title="LDAP SSL Verify"
                                    <?php
                                    if (LDAP_SSL_VERIFY == "true") {
                                        echo "checked=checked";
                                    }
                                    ?> />
                                <?php check('ldapSslVerify', 'ldapSslVerify'); ?>
                            </label>
                        </div>
                    </td>
                </tr>
                <tr>
                    <td>LDAP Start TLS Support
                        <div class="settingDesc">Enable LDAP START_TLS</div>
                    </td>
                    <td>
                        <div class="checkbox">
                            <label>
                                <input id="ldapStartTls" type="checkbox" name="ldapStartTls" title="LDAP Start TLS" <?php
                                if (LDAP_START_TLS == "true") {
                                    echo "checked=checked";
                                }
                                ?> />
                                <?php check('ldapStartTls', 'ldapStartTls'); ?>
                            </label>
                        </div>
                    </td>
                </tr>
                <tr>
                    <td>Bind Type
                        <div class="settingDesc">LDAP bind type: "anonymous", "user" (use the given user/password from the form) and "proxy" (a specific
                            user to browse the LDAP directory)
                        </div>
                    </td>
                    <td>
                        <select id="bindType" class="form-control" name="bindType" title="LDAP Bind Type">
                            <option value="anonymous" <?php if (LDAP_BIND_TYPE == 'anonymous') {
                                echo 'selected="selected"';
                            } ?>>anonymous
                            </option>
                            <option value="user" <?php if (LDAP_BIND_TYPE == 'user') {
                                echo 'selected="selected"';
                            } ?>>user
                            </option>
                            <option value="proxy" <?php if (LDAP_BIND_TYPE == 'proxy') {
                                echo 'selected="selected"';
                            } ?>>proxy
                            </option>
                        </select>
                    </td>
                </tr>
                <tbody id="ldapCredentials" style="display: none">
                <tr>
                    <td>Username
                        <div class="settingDesc">LDAP username to connect with. null for anonymous bind (by default).<br/>Or for user bind type, you can
                            use a pattern: %s@kanboard.local
                        </div>
                    </td>
                    <td>
                        <input type="text" class="form-control" id="ldapUser" name="ldapUser" value="<?php echo sval('ldapUser', LDAP_USERNAME); ?>"
                               title="LDAP Username"/>
                    </td>
                </tr>
                <tr>
                    <td>Password
                        <div class="settingDesc">LDAP password to connect with. null for anonymous bind (by default).</div>
                    </td>
                    <td>
                        <input type="password" class="form-control" id="ldapPass" name="ldapPass" value="<?php echo sval('ldapPass', LDAP_PASSWORD); ?>"
                               title="The Password for LDAP query"/>
                    </td>
                </tr>
                </tbody>
                <tr>
                    <td>Account Base
                        <div class="settingDesc">LDAP account base, i.e. root of all user account<br/>Example: ou=People,dc=example,dc=com</div>
                    </td>
                    <td>
                        <input type="text" class="form-control" id="accBase" name="accBase" value="<?php echo sval('accBase', LDAP_ACCOUNT_BASE); ?>"
                               title="LDAP Account Base"/>
                    </td>
                </tr>
                <tr>
                    <td>Scope
                        <div class="settingDesc">Scope used when searching LDAP</div>
                    </td>
                    <td>
                        <select id="bindScope" class="form-control" name="bindScope" title="LDAP Search Scope">
                            <option value="LDAP_SCOPE_ONELEVEL" <?php if (LDAP_BIND_SCOPE == 'LDAP_SCOPE_ONELEVEL') {
                                echo 'selected="selected"';
                            }
                            ?>>One level
                            </option>
                            <option value="LDAP_SCOPE_SUBTREE" <?php if (LDAP_BIND_SCOPE == 'LDAP_SCOPE_SUBTREE') {
                                echo 'selected="selected"';
                            } ?>>Tree
                            </option>
                        </select>
                    </td>
                </tr>
                <tr>
                    <td>User Pattern
                        <div class="settingDesc">LDAP query pattern to use when searching for a user account<br/>Example for ActiveDirectory:
                            '(&(objectClass=user)(sAMAccountName=%s))'<br/>Example for OpenLDAP: 'uid=%s'
                        </div>
                    </td>
                    <td>
                        <input type="text" class="form-control" id="userPattern" name="userPattern" value="<?php echo sval('userPattern', LDAP_USER_PATTERN); ?>"
                               title="LDAP User Pattern"/>
                    </td>
                </tr>
                <tr>
                    <td>Account Full Name
                        <div class="settingDesc">Name of an attribute of the user account object which should be used as the full name of the user</div>
                    </td>
                    <td>
                        <input type="text" class="form-control" id="accFullName" name="accFullName" value="<?php echo sval('accFullName', LDAP_ACCOUNT_FULLNAME); ?>"
                               title="LDAP Account Full Name"/>
                    </td>
                </tr>
                <tr>
                    <td>Account Email
                        <div class="settingDesc">Name of an attribute of the user account object which should be used as the email of the user</div>
                    </td>
                    <td>
                        <input type="text" class="form-control" id="accEmail" name="accEmail" value="<?php echo sval('accEmail', LDAP_ACCOUNT_EMAIL); ?>"
                               title="LDAP Account Email"/>
                    </td>
                </tr>

            </table>
        </div>

        <div class="panel" id="dbPanel" style="display:none;">
            <div class="title">MySql Database Connection Settings</div>
            <div class="desc">If your database is not setup yet, please contact your system administrator. He should create an empty MySQL database, and a
                user with full rights on that database.
            </div>
            <table>
                <tr>
                    <td>Create new database structure
                        <div class="settingDesc">If checked, all database tables will be created. Note that if you checked it and you already have tables
                            in place, data in these tables will be lost!
                        </div>
                    </td>
                    <td>
                        <div class="checkbox">
                            <label>
                                <input id="createDb" type="checkbox" name="createDb" title="Overwrite database if exists!"/>
                                <?php check('createDb', 'createDb'); ?>
                            </label>
                        </div>
                    </td>
                </tr>
                <tr>
                    <td>Database Host Name
                        <div class="settingDesc"></div>
                    </td>
                    <td>
                        <input type="text" class="form-control" id="dbhost" name="dbhost" value="<?php echo sval('dbhost', $dbConnectionInfo['dbHost']); ?>"
                               title="The Name of the Host the Database Server is installed on"/>
                    </td>
                </tr>
                <tr>
                    <td>Database Name
                        <div class="settingDesc"></div>
                    </td>
                    <td>
                        <input type="text" class="form-control" id="dbname" name="dbname" value="<?php echo sval('dbname', $dbConnectionInfo['dbName']); ?>"
                               title="The Name of the Database Weh Help will use and/or install"/>
                    </td>
                </tr>
                <tr>
                    <td>Database Username
                        <div class="settingDesc"></div>
                    </td>
                    <td>
                        <input type="text" class="form-control" id="dbuser" name="dbuser" value="<?php echo sval('dbuser', $dbConnectionInfo['dbUser']); ?>"
                               title="The Database User that Web Help uses for Database Connection"/>
                    </td>
                </tr>
                <tr>
                    <td>Database User Password
                        <div class="settingDesc"></div>
                    </td>
                    <td>
                        <input type="password" class="form-control" id="dbpass" name="dbpass" value="<?php echo sval('dbpass', $dbConnectionInfo['dbPassword']); ?>"
                               title="The Password according to the above User."/>
                    </td>
                </tr>
                <tr>
                    <td>Display comments from other products
                        <div class="settingDesc">If checked, on this product pages will be visible also comments from other specified products!</div>
                    </td>
                    <td>
                        <div class="checkbox">
                            <label>
                                <input id="shareComments" type="checkbox" name="shareComments" title="Share comments from!"/>
                            </label>
                            <?php check('shareComments', 'shareComments'); ?>
                        </div>
                        <div id="preload" style="display:none">
                            <img alt="loading" src="img/loading.gif">
                            <span>Checking connectivity ...</span>
                        </div>
                    </td>
                </tr>
            </table>
        </div>

        <div class="panel" id="adminPanel" style="display:none;">
            <div class="title">Create Webhelp Administrator Account</div>
            <div class="desc">The administrator has full control over the WebHelp system. Make sure you provide a
                strong password.
            </div>
            <table>
                <tbody id="LDAPLookup" class="disabled">
                <tr>
                    <td>Select LDAP user</td>
                    <td>
                        <div class="checkbox">
                            <label>
                                <input id="selectLdapAdmin" type="checkbox" name="selectLdapAdmin" disabled="disabled"
                                       title="Select administrator username from LDAP users"/>
                            </label>
                        </div>
                        <?php check('selectLdapAdmin', 'selectLdapAdmin'); ?>
                        <div id="preload" style="display:none">
                            <img alt="loading" src="img/loading.gif">
                            <span>Loading LDAP users ...</span>
                        </div>
                    </td>
                </tr>
                </tbody>
                <tbody id="ldapAdminUser" style="display: none">
                <tr>
                    <td colspan="2">
                        <div id="ldapUsers">
                            <table>
                                <thead>
                                <tr>
                                    <td> #</td>
                                    <td> Username</td>
                                    <td> Full Name</td>
                                    <td> Email</td>
                                </tr>
                                </thead>
                                <tbody>

                                </tbody>
                            </table>
                        </div>
                    </td>
                </tr>
                </tbody>
                <tbody id="localAdminUser">
                <tr>
                    <td>Username</td>
                    <td>
                        <input type="text" class="form-control" name="adminUserName"
                               value="<?php echo sval('adminUserName', 'administrator'); ?>"
                               title="The administrator username."/>
                    </td>
                </tr>
                <tr>
                    <td>E-mail</td>
                    <td>
                        <input id="aEmail" type="text" class="form-control" name="adminEmail"
                               value="<?php echo sval('adminEmail', (defined('__ADMIN_EMAIL__') ? __ADMIN_EMAIL__ : "")); ?>"
                               title="Email address to be notified when error occur"/>
                    </td>
                </tr>
                <tr>
                    <td>Password</td>
                    <td>
                        <input id="aPass" type="password" class="form-control" name="adminPasswd"
                               title="Initial word."
                               value="<?php echo sval('adminPasswd', ''); ?>"/>
                    </td>
                </tr>
                <tr>
                    <td>Confirm Password</td>
                    <td>
                        <input id="cPass" type="password" class="form-control" name="cadminPasswd"
                               title="Confirm initial administrator password."
                               value="<?php echo sval('cadminPasswd', ''); ?>"/>
                    </td>
                </tr>
                </tbody>
                <tr>
                    <td>Send Errors to System Administrator
                        <div class="settingDesc">If checked, the web help system error reports are forwarded to the
                            administrator email address.
                        </div>
                    </td>
                    <td>
                        <div class="checkbox">
                            <label>
                            <input id="ckSendErr" type="checkbox" name="sendErrors" <?php
                            if (__SEND_ERRORS__ == "true") {
                                echo "checked=checked";
                            } ?> title="Send errors to system administartor"/>
                            <?php check('ckSendErr', 'sendErrors'); ?>
                            </label>
                        </div>
                    </td>
                </tr>
            </table>
        </div>

        <div class="panel" id="shareWithPanel" style="display:none;">
        </div>

        <div class="btn-group-lg text-right" style="margin-bottom: 4em">
            <div onclick="window.location.href ='index.php';" class="btn btn-primary">Back</div>
            <button type="submit" class="btn btn-primary">Next Step</button>
        </div>

    </div>
</form>
<script src="../resources/bootstrap/js/bootstrap.min.js"></script>
<script>
    function validateEmail(email) {
        var re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        return re.test(email);
    }

    $("#doInstallData").submit(function () {
        if ($('#createDb').is(':checked') && !$('#selectLdapAdmin').is(':checked')) {
            if ($("#aPass").val().length < 5) {
                alert('Administrator password must have at least 5 characters !');
                return false;
            } else if ($("#aEmail").val().length == 0 || !validateEmail($("#aEmail").val())) {
                alert('Please insert a valid administrator email!');
                return false;
            } else {
                if ($("#aPass").val() != $("#cPass").val()) {
                    alert('Please confirm administrator password correctly!');
                    return false;
                } else {
                    return true;
                }
            }
        }
    });
    $('#ck_OverWrite').change(function () {
        if ($(this).is(':checked')) {
            $('#dbPanel').show();
            $('#cfgPanel').show();
            $('#ldapPanel').show();
        } else {
            $('#dbPanel').hide();
            $('#cfgPanel').hide();
            $('#ldapPanel').hide();
        }
    });

    if (($('#ck_OverWriteHid').val() == 'on') || ($('#ck_OverWrite').is(':checked'))) {
        $('#dbPanel').show();
        $('#cfgPanel').show();
        //$('#createDb').attr('checked', true);
    }

    if ($('#createDb').is(':checked')) {
        $('#adminPanel').show();
    }

    $('#createDb').change(function () {
        if ($(this).is(':checked')) {
            $('#adminPanel').show();
            if ($('#enableLdap').is(':checked') && $('#enableLdap').is(':visible')) {
                $('#LDAPLookup').removeClass('disabled');
                $('#selectLdapAdmin').removeAttr('disabled');
            }
            alert("WARNING !! \n By selecting this option the contents of the specified \n database will be dropped,\n and a new table structure will be created!");
        } else {
            $('#aPass').val("");
            $('#cPass').val("");
            $('#adminPanel').hide();
        }
    });

    if ($('#enableLdap').is(':checked') && $('#enableLdap').is(':visible')) {
        $('#ldapPanel').show();
    }

    $('#enableLdap').change(function () {
        $('#localAdminUser').show();
        $('#ldapPanel').slideToggle('slow',function(){
            if ($('#enableLdap').is(':checked')) {
                $('#LDAPLookup').removeClass('disabled');
                $('#selectLdapAdmin').removeAttr('disabled').trigger('change');
            } else {
                $('#selectLdapAdmin').attr('disabled', 'disabled').removeAttr('checked').trigger('change');
                $('#LDAPLookup').addClass('disabled');
            }
        });
    });

    if ($('#selectLdapAdmin').is(':checked')) {
        $('#ldapAdminUser').show();
        $('#localAdminUser').hide();
    }


    $('#selectLdapAdmin').change(function () {
        if ( $(this).is(':checked') ) {
            // List all users from LDAP
            $('#ldapAdminUser').show();
            $('#localAdminUser').hide();

            var query = {
                accEmail: $('#accEmail').val(),
                accFullName: $('#accFullName').val(),
                accBase: $('#accBase').val(),
                bindScope: $('#bindScope').val(),
                userPattern: $('#userPattern').val(),
                ldapHost: $('#ldapHost').val(),
                ldapPort: $('#ldapPort').val(),
                ldapSslVerify: $('#ldapSslVerify').is(':checked'),
                ldapStartTls: $('#ldapStartTls').is(':checked'),
                bindType: $('#bindType').val(),
                ldapUser: $('#ldapUser').val(),
                ldapPass: $('#ldapPass').val()
            }
            var result = retrieveLdapUsers(query);

            $('#ldapAdminUser tbody').html( result );
            $('#ldapUsers tr').click(function (event) {
                if (event.target.type !== 'checkbox') {
                    $(':checkbox', this).trigger('click');
                }
            });
        } else {
            // Show form to create local administrator account
            $('#ldapAdminUser').hide();
            $('#localAdminUser').show();
            $('#ldapAdminUser tbody').html('');
        }
    });

    if ($('#bindType').val() != 'anonymous') {
        $('#ldapCredentials').show();
        $('#ldapUser').val('<?php echo LDAP_USERNAME; ?>');
        $('#ldapPass').val('<?php echo LDAP_PASSWORD; ?>');
    } else {
        $('#ldapCredentials').hide();
        $('#ldapUser').val('null');
        $('#ldapPass').val('null');
    }

    $('#bindType').change(function () {
        if ($(this).val() != 'anonymous') {
            $('#ldapCredentials').show();
            $('#ldapUser').val('<?php echo LDAP_USERNAME; ?>');
            $('#ldapPass').val('<?php echo LDAP_PASSWORD; ?>');
        } else {
            $('#ldapCredentials').hide();
            $('#ldapUser').val('null');
            $('#ldapPass').val('null');
        }
    });

    /**
     * Retrieve all users from domain controller using LDAP connection
     * Returns information about all LDAP users in HTML format
     *
     * @param Object data JSON Object with LDAP connection details used to query LDAP server
     * @return {boolean}
     */
    function retrieveLdapUsers(data) {
        var result = false;
        $.ajax({
            type: "POST",
            url: "../resources/php/ldap.php",
            data: data,
            async: false,
            success: function (data_response) {
                result = data_response;
                $('#preload').hide();
            },
            error: function () {

            }
        });

        return result;
    }


    function retriveShare() {
        $('#preload').show();
        var data = "host=" + $('#dbhost').val()
            + "&user=" + $('#dbuser').val()
            + "&passwd=" + $('#dbpass').val()
            + "&db=" + $('#dbname').val();
        $.ajax({
            type: "POST",
            url: "share.php",
            data: data,
            async: false,
            success: function (data_response) {
                $('#shareWithPanel').html(data_response);
                $('#preload').hide();
            }
        });
        $('#preload').hide();
    }

    $('#shareComments').change(function () {
        if ($(this).is(':checked')) {
            retriveShare();
            $('#shareWithPanel').show();
        } else {
            $('#shareWithPanel').hide();
        }
    });


    if ($('#shareComments').is(':checked')) {
        retriveShare();
        $('#shareWithPanel').show();
    }


</script>
</body>
</html>
