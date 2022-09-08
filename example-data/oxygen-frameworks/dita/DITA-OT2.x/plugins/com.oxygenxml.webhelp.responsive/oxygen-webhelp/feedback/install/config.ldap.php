<?php
// Enable LDAP authentication (true by default)
define('LDAP_AUTH', true);

// LDAP server hostname
define('LDAP_SERVER', 'hostname');

// LDAP server port (389 by default)
define('LDAP_PORT', 389);

// By default, require certificate to be verified for ldaps:// style URL. Set to false to skip the verification.
define('LDAP_SSL_VERIFY', true);

// Enable LDAP START_TLS
define('LDAP_START_TLS', false);

// LDAP bind type: "anonymous", "user" (use the given user/password from the form) and "proxy" (a specific user to browse the LDAP directory)
define('LDAP_BIND_TYPE', 'anonymous');

// LDAP username to connect with. null for anonymous bind (by default).
// Or for user bind type, you can use a pattern: %s@kanboard.local
define('LDAP_USERNAME', null);

// LDAP password to connect with. null for anonymous bind (by default).
define('LDAP_PASSWORD', null);

// LDAP account base, i.e. root of all user account
// Example: ou=People,dc=example,dc=com
define('LDAP_ACCOUNT_BASE', 'ou=people,dc=example,dc=com');

// LDAP query pattern to use when searching for a user account
// Example for ActiveDirectory: '(&(objectClass=user)(sAMAccountName=%s))'
// Example for OpenLDAP: 'uid=%s'
define('LDAP_USER_PATTERN', 'uid=%s');

// Name of an attribute of the user account object which should be used as the full name of the user.
define('LDAP_ACCOUNT_FULLNAME', 'cn');

// Name of an attribute of the user account object which should be used as the email of the user.
define('LDAP_ACCOUNT_EMAIL', 'mail');

// Name of an attribute of the user account object which should be used as the email of the user.
define('LDAP_BIND_SCOPE', 'LDAP_SCOPE_ONELEVEL');