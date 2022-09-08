<?php
/*
    
Oxygen WebHelp Plugin
Copyright (c) 1998-2017 Syncro Soft SRL, Romania.  All rights reserved.

*/


@include_once 'classes/Ldap.php';
@include_once '../../install/config.ldap.php';

$ldap_account_email = $_POST['accEmail'];
$ldap_account_full_name = $_POST['accFullName'];
$ldap_account_base = $_POST['accBase'];
$ldap_user_pattern = $_POST['userPattern'];
$ldap_server = $_POST['ldapHost'];
$ldap_port = $_POST['ldapPort'];
$ldap_ssl_verify = $_POST['ldapSslVerify'] == 'true' ? true : false;
$ldap_start_tls = $_POST['ldapStartTls'] == 'true' ? true : false;
$ldap_bind_type = $_POST['bindType'];
$ldap_bind_scope = $_POST['bindScope'];
$ldap_password = (isset($_POST['ldapPass']) && trim($_POST['ldapPass']) != '') ? $_POST['ldapPass'] : null;
$ldap_username = (isset($_POST['ldapUser']) && trim($_POST['ldapUser']) != '') ? $_POST['ldapUser'] : null;

$auth = new Ldap();
$auth->setLdapAccountBase($ldap_account_base);
$auth->setLdapAccountEmail($ldap_account_email);
$auth->setLdapAccountFullname($ldap_account_full_name);
$auth->setLdapBindType($ldap_bind_type);
$auth->setLdapBindScope($ldap_bind_scope);
$auth->setLdapPassword($ldap_password);
$auth->setLdapUsername($ldap_username);
$auth->setLdapPort($ldap_port);
$auth->setLdapServer($ldap_server);
$auth->setLdapSslVerify($ldap_ssl_verify);
$auth->setLdapStartTls($ldap_start_tls);
$auth->setLdapUserPattern($ldap_user_pattern);

try {
    $username = $auth->getLdapUserAttribute();
    $info = $auth->listAllUsers(array($auth->getLdapUserAttribute(), $ldap_account_full_name, $ldap_account_email), 0);

    if (is_array($info)) {
        for ($i = 0; $i < $info['count']; $i++) {
            $user = @$info[$i][$username][0];
            echo '<tr>';
            echo '<td><input type="checkbox" name="ldapAdminUser[]" value="' . $user . '" /></td>';
            echo '<td>' . $user . '</td>';
            echo '<td>' . @$info[$i][$ldap_account_full_name][0] . '</td>';
            echo '<td>' . @$info[$i][$ldap_account_email][0] . '</td>';
            echo '</tr>';
        }
    }
} catch (Exception $e) {
    error_log($e->getMessage());
    echo '<tr>';
    echo '<td colspan="4">' . $e->getMessage() . '</td>';
    echo '</tr>';
}

$auth->close();