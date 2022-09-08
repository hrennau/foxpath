<?php

/*

Oxygen WebHelp Plugin
Copyright (c) 1998-2017 Syncro Soft SRL, Romania.  All rights reserved.

*/

class User
{
    /**
     * DB Connection info  set in the configuration file
     *
     * @var array storring 'dbName', 'dbUser', 'dbPassword', 'dbHost'
     */
    private $dbConnectionInfo;
    /**
     * Validated User info from database
     *
     * @var array ['userName','userId','name','company','email','accessLevel','msg', ldapUser];
     */
    private $info;

    /**
     * Ldap Object to query LDAP server.
     *
     * @var Ldap|null
     */
    private $ldap = null;

    /**
     * Constructor
     *
     * @param array $dbConnectionInfo db connection info
     */
    function __construct($dbConnectionInfo)
    {
        $this->dbConnectionInfo = $dbConnectionInfo;
        if (LDAP_AUTH) {
            $this->ldap = new Ldap();
        }
        $this->info = array();
        $this->info['isAnonymous'] = 'false';
    }

    /**
     * When system is in guest mode post there must be one generic user to post
     *
     * @return true if is validated the anonymous user in db
     */
    function initAnonymous()
    {
        $this->info['isAnonymous'] = 'true';
        return $this->validate('anonymous', '97968c7aedaba6d6d08a3626b23bd9a1');
    }

    /**
     * Insert new user into database
     *
     * @param array $info containing 'username','name','password','email'
     * @param bool $ldap TRUE for LDAP user
     * @return JsonResponse {"msg","msgType","errorCode"}
     * @throws Exception
     */
    function insertNewUser($info, $ldap = false)
    {
        $this->info['msg'] = "user::false";
        $response = new JsonResponse();
        $response->set("msgType", "error");
        $response->set("error", "true");

        $db = new RecordSet($this->dbConnectionInfo);
        $username = $db->sanitize($info['username']);
        $name = $db->sanitize($info['name']);
        $email = $db->sanitize($info['email']);
        if ($this->isUqFieldViolated('userName', $username)) {
            $response->set("msg", "User name is already taken!");
            $response->set("errorCode", "4");
        } else {
            if ($this->isUqFieldViolated('email', $email) && trim($email) != '') {
                $response->set("msg", "Email is already in the database!");
                $response->set("errorCode", "5");
            } else {
                if (!$this->checkEmail($email) && !$ldap) {
                    $response->set("msg", "Invalid e-mail address!");
                    $response->set("errorCode", "3");
                } else {
                    if (strlen(trim($info['password'])) < 5 && !$ldap) {
                        $response->set("msg", "Password is too short!");
                        $response->set("errorCode", "1");
                    } else {
                        if ($db->sanitize($info['password']) != $info['password']) {
                            $response->set("msg", "Invalid password!");
                            $response->set("errorCode", "2");
                        } else {
                            if (!$ldap) {
                                $password = MD5($db->sanitize($info['password']));
                                $status = 'created';
                            } else {
                                $password = '';
                                $status = 'validated';
                            }
                            $date = date("Y-m-d H:i:s");
                            $sql = "INSERT INTO  users (userId ,userName ,email ,name ,company ,password ,date ,level ,status,notifyAll,notifyReply,notifyPage) VALUES (NULL,'" . $username . "','" . $email . "','" . $name . "','noCompany','" . $password . "','" . $date . "','user','" . $status . "','no','yes','yes');";
                            $rows = $db->Run($sql);
                            $this->info['msg'] = "user::rows::" . $rows;
                            // 			$toReturn=$sql;
                            if ($rows <= 0) {
                                $response->set("msg", $db->m_DBErrorNumber . $db->m_DBErrorMessage . $sql);
                                $response->set("errorCode", "10");
                            } else {
                                $response->set("error", "false");
                                $response->set("errorCode", "0");
                                $this->validate($username, $info['password'], $status);
                            }

                            $db->Close();
                        }
                    }
                }
            }
        }
        return $response;
    }

    /**
     * Check if entered password match the password registered in DB.
     * Used when user try to edit account
     *
     * @param $oldPassword Entered password
     * @return bool TRUE if password is valid
     * @throws Exception
     */
    private function isValidPassword($oldPassword)
    {
        $toReturn = false;
        $db = new RecordSet($this->dbConnectionInfo);
        $sql = "SELECT userId FROM users WHERE userId='" . $this->info['userId'] . "' AND password='" . md5($oldPassword) . "';";
        $ids = $db->open($sql);
        if ($ids == 1) {
            $toReturn = true;
        } else {
            // Try to authenticate using LDAP
            if ($this->ldap instanceof Ldap) {
                $toReturn = $this->ldap->authenticate($this->info['userName'], $oldPassword);
            }
        }
        $db->Close();

        return $toReturn;
    }

    /**
     * Update current user profile data
     *
     * @param array $profileInfo contains "password" or "name","e-mail","notifyPage","notifyAll","notifyReply"
     * @return string message after update
     */
    function updateProfile($profileInfo)
    {
        $toReturn = "";
        $db = new RecordSet($this->dbConnectionInfo, false, true);
        if (!$profileInfo['editByAdmin']) {
            if (isset($profileInfo['oldPassword']) && !$this->isValidPassword($profileInfo['oldPassword'])) {
                $toReturn = Utils::translate('msg.secureOldPass');
            } else {
                $toReturn = $this->updateProf($db, $profileInfo);
            }
        } else {
            // Modified from admin panel
            // Insert LDAP user into local DB
            if (strpos($profileInfo['userId'], 'ldap_') === 0) {
                error_log('Need to insert LDAP user to local DB...');
                $userName = substr($profileInfo['userId'], 5);
                $user['username'] = $userName;
                $user['email'] = $profileInfo['email'];
                $user['name'] = $profileInfo['name'];
                $user['company'] = $profileInfo['company'];
                $user['password'] = "";
                $user['level'] = $profileInfo['level'];
                $user['status'] = $profileInfo['status'];
                $user['notifyAll'] = $profileInfo['notifyAll'];
                $user['notifyReply'] = $profileInfo['notifyReply'];
                $user['notifyPage'] = $profileInfo['notifyPage'];

                $result = new JsonResponse();
                $result = $this->insertNewUser($user, true);
                $toReturn = $result->error == "false" ? true : false;

                // Update inserted user
                if ($toReturn) {
                    $query = "SELECT userId FROM users WHERE userName='" . $userName . "'";
                    $db->Open($query);
                    $db->MoveNext();
                    $profileInfo['userId'] = $db->Field('userId');

                    $toReturn = $this->updateProf($db, $profileInfo);
                }
            } else {
                // Update user from admin panel
                $toReturn = $this->updateProf($db, $profileInfo);
            }
        }
        $db->Close();
        return $toReturn;
    }

    /**
     * Clean db for unconfirmed users
     * @param $days Delete users older than $days that are not confirmed
     * @return number of deleted users
     * @throws Exception
     */
    function cleanUsers($days)
    {
        $toReturn = -1;
        if ($days < 0) {
            $db = new RecordSet($this->dbConnectionInfo, false, true);
            $query = "DELETE FROM users WHERE date<'" . date('Y-m-d H:i:s', strtotime($days . ' day')) . "' AND status='created';";
            $toReturn = $db->Run($query);
            $db->Close();
        } else {
            throw new Exception("Invalid days to clean users!");
        }
        return $toReturn;
    }

    /**
     * Update password
     *
     * @param RecordSet $db db connection
     * @param array $info info to be updated with keys
     *         "name","email","notifyPage","notifyAll","notifyReply" as fields in database
     * @return string "" when success otherwise error message
     * @throws Exception
     */
    private function updateProf($db, $info)
    {
//        error_log("updateProf info" . print_r($info, true));
        $toReturn = "";
        global $translate;
        $newArray = $db->sanitizeArray($info);
        $invalidInput = "";
        $dataToUpdate = "";
        $adminUserId = -1;
        foreach ($newArray as $key => $val) {
            if ($info[$key] != $val) {
                $translateKey = 'user.' . $key . ".label";
                $invalidInput .= Utils::translate($translateKey) . ", ";
            } else {
                if ($key == "email") {
                    if (!$this->checkEmail($info["email"])) {
                        if (strlen($invalidInput) > 0) {
                            $invalidInput .= ", ";
                        }
                        $invalidInput .= Utils::translate("user.email.label");
                    }
                }
            }
            if ($key != "userId") {
                if (isset($info['password']) && $key == "password") {
                    $password = $info['password'];
                    $newPass = $db->sanitize($password);
                    if ($newPass != $password) {
                        $invalidInput .= Utils::translate('pwd.invalidCharacters');
                    } else {
                        if (strlen(trim($password)) < 5) {
                            $invalidInput .= Utils::translate('pwd.tooShort');
                        } else {
                            $dataToUpdate .= $key . " = '" . md5($password) . "' ,";
                        }
                    }
                } else {
                    if ($key != 'oldPassword' && $key != 'editByAdmin') {
                        $dataToUpdate .= $key . " = '" . $val . "' ,";
                    }
                }
            } else {
                $adminUserId = $info["userId"];
            }
        }

        $dataToUpdate = substr($dataToUpdate, 0, -2);

        if ($invalidInput == "") {
            if ($this->isUqFieldViolated('email', $info['email'], ($adminUserId > 0 ? $adminUserId : $this->info["userId"]))) {
                $toReturn = Utils::translate('email.duplicate');
            } else {
                $query = "UPDATE users SET " . $dataToUpdate . " WHERE userId=";
                if ($adminUserId > 0) {
                    $query .= $adminUserId . ";";
                } else {
                    $query .= $this->info["userId"] . ";";
                }
                // 			$toReturn=$query;
                $toReturn = "";
                try {
                    $rows = $db->Run($query);
                } catch (Exception $e) {
                    $toReturn = $e->getMessage();
                    if ($this->isUqViolated($toReturn, "email")) {
                        $toReturn = Utils::translate('email.duplicate');
                    } else {
                        if ($this->isUqViolated($toReturn, "userName")) {
                            $toReturn = Utils::translate('username.duplicate');
                        } else {
                            throw $e;
                        }
                    }
                }
            }


            if ($toReturn == "") {
                $myrs = new RecordSet($this->dbConnectionInfo);

                $query = "SELECT * FROM users WHERE userId=" . $this->info["userId"] . ";";
                if ($myrs->Open($query) > 0 && $myrs->m_IsValid) {
                    $myrs->MoveNext();
                    $this->info['userName'] = $myrs->Field('userName');
                    $this->info['userId'] = $myrs->Field('userId');
                    $this->info['name'] = $myrs->Field('name');
                    $this->info['level'] = $myrs->Field('level');
                    $this->info['company'] = $myrs->Field('company');
                    $this->info['email'] = $myrs->Field('email');
                    $this->info['date'] = $myrs->Field('date');
                    $this->info['notifyAll'] = $myrs->Field('notifyAll');
                    $this->info['notifyReply'] = $myrs->Field('notifyReply');
                    $this->info['notifyPage'] = $myrs->Field('notifyPage');
                }
                $myrs->close();
            }
        } else {
            if (substr($invalidInput, -2) == ", ") {
                $invalidInput = substr($invalidInput, 0, -2);
            }
            $toReturn = Utils::translate('input.invalid') . $invalidInput;
        }
        return $toReturn;
    }

    /**
     * Check if the 'email' is a valid email address
     *
     * @param String $email Email address to be checked
     * @return  bool TRUE if it is a valid email
     */
    function checkEmail($email)
    {
        if (preg_match("/^([a-zA-Z0-9])+([a-zA-Z0-9\._-])*@([a-zA-Z0-9_-])+([a-zA-Z0-9\._-]+)+$/",
            $email)) {
            return true;
        }
        return false;
    }

    /**
     * Check if 'userName' is LDAP user or not
     *
     * @param string $userName Check that given 'userName' is a LDAP user or not
     * @return bool TRUE if 'userName' is from LDAP
     * @throws Exception
     */
    private function isLdapUser($userName)
    {
        $toReturn = false;

        $db = new RecordSet($this->dbConnectionInfo);
        $query = "SELECT  password FROM users WHERE userName = '" . $userName . "'";
        $db->Open($query);
        if ($db->m_RowsCount == 1) {
            $db->MoveNext();
            if ($db->Field('password') == '') {
                $toReturn = true;
            }
        }

        return $toReturn;
    }


    /**
     * Get all modetators email to be notified when a new comment is added
     *
     * @return array emails
     */
    public function getModeratorsEmails()
    {
        $toReturn = array();
        $db = new RecordSet($this->dbConnectionInfo);
        $dbAux = new RecordSet($this->dbConnectionInfo);

        $query = "SELECT  userName FROM users WHERE level='moderator' OR level='admin'";
        $db->Open($query);

        while ($db->MoveNext()) {
            if (!$this->isLdapUser($db->Field('userName'))) {
                $query = "SELECT  concat(name,' <',email,'> ') adrs FROM users WHERE userName='" . $db->Field('userName') . "'";
                $dbAux->Open($query);

                $dbAux->MoveNext();
                $toReturn[] = $dbAux->Field("adrs");
            } else {
                $mail = $this->getUserInformation($db->Field('userName'), LDAP_ACCOUNT_EMAIL);
                $name = $this->getUserInformation($db->Field('userName'), LDAP_ACCOUNT_FULLNAME);
                $toReturn[] = $name . ' <' . $mail . '> ';
            }
        }

        $db->Close();
        return $toReturn;
    }

    /**
     * Check if a error message contains info about duplicate key for username
     *
     * @param String $message Message that will be checked
     * @param String $field Field that will be checked for duplicate key
     * @return bool TRUE if 'message' contains duplicate key for 'field'
     */
    private function isUqViolated($message, $field)
    {
        $toReturn = false;
        if (strpos($message, "Duplicate entry") === false) {
            $toReturn = false;
        } else {
            if (strpos($message, "Duplicate entry") >= 0) {
                if (strpos($message, $field) === false) {
                    $toReturn = false;
                } else {
                    if (strpos($message, $field) >= 0) {
                        $toReturn = true;
                    }
                }
            }
        }
        return $toReturn;
    }

    /**
     * Confirm user from email
     *
     * @param int $id User id to be confirmed
     * @return boolean true if the user is validated
     */
    function confirmUser($id)
    {
        $toReturn = false;
        $this->info['msg'] = "User not updated!";

        $db = new RecordSet($this->dbConnectionInfo);
        $query = "UPDATE users SET status='validated' WHERE userId=$id AND status='created'";
        $rows = $db->Run($query);
        if ($rows > 0) {
            $toReturn = true;
            $this->info['msg'] = "";
            $db1 = new RecordSet($this->dbConnectionInfo);
            $rows1 = $db1->Open("SELECT * FROM users WHERE userId=" . $id . ";");
            if ($rows1 == 1) {
                $db1->MoveNext();
                $this->loadData($db1);
                $this->info['msg'] = Utils::translate("signUp.confirmUsr");
            }
            $db1->close();
        } else {
            $query = "SELECT userId FROM users WHERE status='validated' AND userId=" . $id . ";";
            if ($db->Open($query) > 0) {
                $this->info['msg'] = Utils::translate("signUp.userConfirmed");
            } else {
                $this->info['msg'] = Utils::translate("signUp.invalidUsr");
            }
            $db->Close();
        }
        $db->Close();
        return $toReturn;
    }

    /**
     * Check if field is violating unique constraint
     * @param String $field Field to be checked
     * @param String $value Value to be checked
     * @param int $id id to be excluded
     * @return bool
     */
    private function isUqFieldViolated($field, $value, $id = null)
    {
        $toReturn = false;
        $db = new RecordSet($this->dbConnectionInfo);
        $query = "SELECT userId FROM users WHERE " . $field . "='" . $value . "'";
        if ($id != null) {
            $query .= " AND userId<>" . $id . ";";
        }
        $rows = $db->Run($query);
        if ($rows > 0) {
            $toReturn = true;
        }
        $db->close();
        return $toReturn;
    }

    /**
     * Validate a username and a password
     *
     * @param String $userName 'userName' that will be checked
     * @param String $password 'password' for the given 'userName'
     * @param String $status 'created','validated','suspended'
     * @return boolean validation status
     */
    public function validate($userName, $password, $status = 'validated')
    {
        $toReturn = $this->checkUser($userName, $password, $status);

        return $toReturn;
    }

    /**
     * Try to authenticate 'userName' using either local accounts or LDAP authentication
     *
     * @param string $userName Username to authenticate
     * @param string $password Password for given 'userName'
     * @param string $status Status of active users
     * @return bool TRUE if authentication
     * @throws Exception
     */
    public function checkUser($userName, $password, $status = 'validated')
    {
        $toReturn = false;

        $myrs = new RecordSet($this->dbConnectionInfo);
        // To protect MySQL injection
        $userName = $myrs->sanitize($userName);
        $password = $myrs->sanitize($password);

        try {
            $query = "SELECT * FROM users WHERE username ='$userName' AND password = '" . md5($password) . "' AND status='$status'";

            $this->info['msg'] = "";
            if ($myrs->Open($query) == 1 && $myrs->m_IsValid) {
                // Local user found. Load user data
                $toReturn = true;
                $myrs->MoveNext();
                $this->loadData($myrs);

                $this->info['ldapUser'] = 'false';

                return $toReturn;
            } else {
                if ($myrs->m_DBErrorNumber) {
                    $this->info['msg'] = "DBError=" . $myrs->m_DBErrorNumber . " DBMessage=" . $myrs->m_DBErrorMessage;
                }
            }
        } catch (Exception $e) {
            // ignore
        }

        if (!$toReturn && $this->ldap instanceof Ldap) {
            error_log('Try LDAP auth');
            // Local user not found. Check LDAP if enabled.

            $query = "SELECT * FROM users WHERE username = '$userName' AND password = '' AND status='$status'";
            $this->info['msg'] = "";

            if ($myrs->Open($query) == 1 && $myrs->m_IsValid) {
                error_log('User exists...');

                if ($this->ldap->authenticate($userName, $password)) {
                    $toReturn = true;
                    $myrs->MoveNext();
                    $this->loadData($myrs);
                    // Update email and name with LDAP information so that always we have latest data
                    $this->info['name'] = $this->getUserInformation($userName, LDAP_ACCOUNT_FULLNAME);
                    $this->info['email'] = $this->getUserInformation($userName, LDAP_ACCOUNT_EMAIL);
                    $this->info['ldapUser'] = 'true';

                    return $toReturn;
                }
            } else {
                // User does not exist in database
                // We need to add user to database
                error_log('New user...');

                if ($this->ldap->authenticate($userName, $password)) {

                    $userInfo = array();
                    $userInfo['username'] = $userName;
                    $userInfo['name'] = $this->getUserInformation($userName, LDAP_ACCOUNT_FULLNAME);
                    $userInfo['password'] = $password;
                    $userInfo['email'] = $this->getUserInformation($userName, LDAP_ACCOUNT_EMAIL);

                    $newUser = $this->insertNewUser($userInfo, true);
                    if ($newUser->error === 'false') {
                        $toReturn = true;

                        $this->info['ldapUser'] = 'true';
                    }
                }
            }
        }

        $myrs->close();

        return $toReturn;
    }

    /**
     * Load internal data
     *
     * @param RecordSet $mysqlDS
     */
    private function loadData($mysqlDS)
    {
        $this->info['userName'] = $mysqlDS->Field('userName');
        $this->info['userId'] = $mysqlDS->Field('userId');
        $this->info['name'] = $mysqlDS->Field('name');
        $this->info['level'] = $mysqlDS->Field('level');
        $this->info['company'] = $mysqlDS->Field('company');
        $this->info['email'] = $mysqlDS->Field('email');
        $this->info['date'] = $mysqlDS->Field('date');
        $this->info['notifyAll'] = $mysqlDS->Field('notifyAll');
        $this->info['notifyReply'] = $mysqlDS->Field('notifyReply');
        $this->info['notifyPage'] = $mysqlDS->Field('notifyPage');
    }

    /**
     * List all users for moderators
     *
     */
    function listUsers()
    {
        $toReturn = "";
        $db = new RecordSet($this->dbConnectionInfo);
        // To protect MySQL injection

        $query = "SELECT * FROM users";
        $db->Open($query);
        $toReturn .= "<table id=\"usersList\" cellpadding='0' cellspacing='0'>";
        $toReturn .= "<thead>";
        $toReturn .= "<tr>";
        $toReturn .= "<td>";
        $toReturn .= Utils::translate('admin.userName.label');
        $toReturn .= "</td>";
        $toReturn .= "<td>";
        $toReturn .= Utils::translate('admin.name.label');
        $toReturn .= "</td>";
        $toReturn .= "<td>";
        $toReturn .= Utils::translate('admin.level.label');
        $toReturn .= "</td>";
        $toReturn .= "<td>";
        $toReturn .= Utils::translate('admin.company.label');
        $toReturn .= "</td>";
        $toReturn .= "<td>";
        $toReturn .= Utils::translate('admin.email.label');
        $toReturn .= "</td>";
        $toReturn .= "<td>";
        $toReturn .= Utils::translate('admin.date.label');
        $toReturn .= "</td>";
        $toReturn .= "<td>";
        $toReturn .= Utils::translate('admin.notifyAll.label');
        $toReturn .= "</td>";
        $toReturn .= "<td>";
        $toReturn .= Utils::translate('admin.notifyReply.label');
        $toReturn .= "</td>";
        $toReturn .= "<td>";
        $toReturn .= Utils::translate('admin.notifyPage.label');
        $toReturn .= "</td>";
        $toReturn .= "<td>";
        $toReturn .= Utils::translate('admin.status.label');
        $toReturn .= "</td>";
        $toReturn .= "<td>";
        $toReturn .= Utils::translate('admin.user.type');
        $toReturn .= "</td>";
        $toReturn .= "</tr>";
        $toReturn .= "</thead>";
        while ($db->MoveNext()) {
            $user['id'] = $id = $db->Field('userId');
            $user['userName'] = $db->Field('userName');
            $user['name'] = $db->Field('name');
            $user['level'] = $db->Field('level');
            $user['company'] = $db->Field('company');
            $user['email'] = $db->Field('email');
            $user['company'] = $db->Field('company');
            $user['date'] = $db->Field('date');
            $user['notifyAll'] = $db->Field('notifyAll');
            $user['notifyReply'] = $db->Field('notifyReply');
            $user['notifyPage'] = $db->Field('notifyPage');
            $user['status'] = $db->Field('status');
            $user['ldapUser'] = $this->isLdapUser($db->Field('userName')) ? 'LDAP User' : 'Local User';

            $users[] = $user;
            $userNames[] = $user['userName'];
        }

        if ($this->ldap instanceof Ldap) {
            $ldapUsers = array();
            try {
                $uAttribute = $this->ldap->getLdapUserAttribute();
                $ldapUsers = $this->ldap->listAllUsers(array($uAttribute, LDAP_ACCOUNT_EMAIL, LDAP_ACCOUNT_FULLNAME), 0);
            } catch (Exception $e) {
                error_log($e->getMessage());
            }
            $i = 0;
            foreach ($ldapUsers as $key => $user) {
                $i++;
                if ((string)$key != 'count') {
                    $un = $user[$uAttribute][0];
                    if (!in_array($un, $userNames)) {
                        $uName['id'] = 'ldap_' . $un;
                        $uName['userName'] = $un;
                        @$uName['name'] = $user[LDAP_ACCOUNT_FULLNAME][0];
                        $uName['level'] = 'user';
                        $uName['company'] = '';
                        @$uName['email'] = $user[LDAP_ACCOUNT_EMAIL][0];
                        $uName['date'] = '';
                        $uName['notifyAll'] = 'no';
                        $uName['notifyReply'] = 'no';
                        $uName['notifyPage'] = 'no';
                        $uName['status'] = 'validated';
                        $uName['ldapUser'] = 'LDAP User';

                        $users[] = $uName;
                        $userNames[] = $un;
                    }
                }
            }
        }

        foreach ($users as $user) {
            if ($user['userName'] != "anonymous" && $user['id'] != 1) {
                $toReturn .= "<tr id=\"u_" . $user['id'] . "\" onclick='editUser(\"" . $user['id'] . "\")'>";
                $toReturn .= "<td class=\"username\">";
                $toReturn .= $user['userName'];
                $toReturn .= "</td>";
                $toReturn .= "<td class=\"name\">";
                $toReturn .= $user['name'];
                $toReturn .= "</td>";
                $toReturn .= "<td class=\"level\">";
                $toReturn .= $user['level'];
                $toReturn .= "</td>";
                $toReturn .= "<td class=\"company\">";
                $toReturn .= $user['company'];
                $toReturn .= "</td>";
                $toReturn .= "<td class=\"email\">";
                $toReturn .= $user['email'];
                $toReturn .= "</td>";
                $toReturn .= "<td class=\"date\">";
                $toReturn .= $user['date'];
                $toReturn .= "</td>";
                $toReturn .= "<td class=\"notifyAll\">";
                $toReturn .= $user['notifyAll'];
                $toReturn .= "</td>";
                $toReturn .= "<td class=\"notifyReply\">";
                $toReturn .= $user['notifyReply'];
                $toReturn .= "</td>";
                $toReturn .= "<td class=\"notifyPage\">";
                $toReturn .= $user['notifyPage'];
                $toReturn .= "</td>";
                $toReturn .= "<td class=\"status\">";
                $toReturn .= $user['status'];
                $toReturn .= "</td>";
                $toReturn .= "<td class=\"type\">";
                $toReturn .= $user['ldapUser'];
                $toReturn .= "</td>";
                $toReturn .= "</tr>";
            }
        }

        $toReturn .= "</table>";
        return $toReturn;
    }

    /**
     * Recover lost password
     *
     * @param array $info containing user email, product , version
     * @return array Information about new generated password as: the email match username or not and generated password
     */
    function generatePasswd($info)
    {
        $toReturn = array();
        $this->info['msg'] = "Password not generated!";
        $db = new RecordSet($this->dbConnectionInfo);
        $info['username'] = $db->sanitize($info['username']);
        $info['email'] = $db->sanitize($info['email']);
        $query = "SELECT userName FROM users WHERE email='" . $info['email'] . "' AND status='validated'";
        $rows = $db->Open($query);
        $toReturn['match'] = false;
        if ($rows == 1) {
            $db->MoveNext();

            if (LDAP_AUTH && $this->isLdapUser($db->Field("userName"))) {
                $toReturn['generated'] = "";
                $this->info['msg'] = Utils::translate('email.user.not.match');
            } else {
                if ($db->Field("userName") == $info['username']) {
                    $toReturn['match'] = true;
                }
                $toReturn['generated'] = Utils::generatePassword(6, true, true, false);
            }
        } else {
            $toReturn['generated'] = "";
            $this->info['msg'] = Utils::translate('email.user.not.match');
        }
        $db->Close();
        return $toReturn;
    }

    /**
     * Change password for an specified email with the specified one
     *
     * @param String $email user emai
     * @param String $password unencripted password
     * @return String user name
     */
    function changePassword($email, $password)
    {
        $toReturn = "";
        $db = new RecordSet($this->dbConnectionInfo);
        if ($password == $db->sanitize($password)) {
            $query = "UPDATE users SET password = '" . MD5($password) . "' WHERE email='" . $email . "'";
            $rows = $db->Run($query);
            if ($rows > 0) {
                $query = "SELECT userName FROM users WHERE email='" . $email . "'";
                $db->Open($query);
                $db->MoveNext();
                $toReturn = $db->Field("userName");
            }
        }
        $db->Close();
        return $toReturn;
    }

    /**
     * Get user info from internal data
     *
     * @param String $variableName variable name to be return
     * @return string
     */
    public function __get($variableName)
    {
        $toReturn = "";
        if (isset($this->info[$variableName])) {
            $toReturn = $this->info[$variableName];
        }
        return $toReturn;
    }

    /**
     * Recutrsive user email harvesting
     * @param int $commentId new inserted comment ID
     * @param array $emailArray array to collect on the emails
     * @param RecordSet $db dbconnection to be used
     * @return array
     */
    private function addUserToNotify($commentId, $emailArray, $db)
    {
        $sql = "SELECT userName from users where notifyPage='no' AND notifyAll='no'
		AND notifyReply='yes' AND status ='validated' AND userId in (SELECT userId from comments where commentId='$commentId');";

        $db->Open($sql);
        while ($db->MoveNext()) {
            $userName = $db->Field('userName');
            if ($this->isLdapUser($userName)) {
                $s_notify_local = "SELECT concat(name,' <',email,'> ') adrs FROM users WHERE userName = '" . $userName . "';";

                $db2 = new RecordSet($this->dbConnectionInfo);
                $db2->Open($s_notify_local);
                $db2->MoveNext();

                if (!in_array($db2->Field('adrs'), $emailArray)) {
                    $emailArray[] = $db2->Field('adrs');
                }

                $db2->Close();
            } else {
                $name = $this->getUserInformation($userName, LDAP_ACCOUNT_FULLNAME);
                $mail = $this->getUserInformation($userName, LDAP_ACCOUNT_EMAIL);
                $email = $name . ' <' . $mail . '> ';

                if (!in_array($email, $emailArray)) {
                    $emailArray[] = $email;
                }
            }
        }

        $db->Open("SELECT referedComment FROM comments WHERE commentId='$commentId'");
        while ($db->MoveNext()) {
            if ($db->Field('referedComment') > 0) {
                $emailArray = $this->addUserToNotify($db->Field('referedComment'), $emailArray, $db);
            }
        }
        return $emailArray;
    }

    /**
     * Obtaint all users to be notified when a new comment is inserted
     *
     * @param String $page page that is comment on
     * @param int $commentId new comment id
     *
     * @return array list of emails to be notified
     */
    function getUsersToNotify($page, $commentId)
    {
        $toReturn = array();
        $s_notifyAll = "SELECT userName FROM users WHERE notifyAll='yes' AND status ='validated';";

        $db = new RecordSet($this->dbConnectionInfo);
        $db->Open($s_notifyAll);

        while ($db->MoveNext()) {
            $userName = $db->Field('userName');
            if (!$this->isLdapUser($userName)) {
                $s_notify_local = "SELECT concat(name,' <',email,'> ') adrs FROM users WHERE userName = '" . $userName . "';";

                $db2 = new RecordSet($this->dbConnectionInfo);
                $db2->Open($s_notify_local);
                $db2->MoveNext();

                $toReturn[] = $db2->Field('adrs');
                $db2->Close();
            } else {
                $name = $this->getUserInformation($userName, LDAP_ACCOUNT_FULLNAME);
                $mail = $this->getUserInformation($userName, LDAP_ACCOUNT_EMAIL);

                if (strlen($mail) > 0) {
                    $toReturn[] = $name . ' <' . $mail . '> ';
                }
            }
        }

        $s_notifyPage = "SELECT userName from users where notifyPage='yes' AND notifyAll='no'
		AND status ='validated' AND userId in (SELECT userId from comments where page='$page');";
        $db->Open($s_notifyPage);

        while ($db->MoveNext()) {
            $userName = $db->Field('userName');
            if (!$this->isLdapUser($userName)) {
                $s_notify_local = "SELECT concat(name,' <',email,'> ') adrs FROM users WHERE userName = '" . $userName . "';";

                $db2 = new RecordSet($this->dbConnectionInfo);
                $db2->Open($s_notify_local);
                $db2->MoveNext();

                if (!in_array($db2->Field('adrs'), $toReturn)) {
                    $toReturn[] = $db2->Field('adrs');
                }
                $db2->Close();
            } else {
                $name = $this->getUserInformation($userName, LDAP_ACCOUNT_FULLNAME);
                $mail = $this->getUserInformation($userName, LDAP_ACCOUNT_EMAIL);
                $email = $name . ' <' . $mail . '> ';

                if (!in_array($email, $toReturn) && strlen($mail) > 0) {
                    $toReturn[] = $email;
                }
            }
        }

        $r_comment = "SELECT referedComment FROM comments WHERE commentId='$commentId'";
        $db->Open($r_comment);
        while ($db->MoveNext()) {
            if ($db->Field('referedComment') > 0) {
                $toReturn = $this->addUserToNotify($db->Field('referedComment'), $toReturn, $db);
            }
        }
        $db->Close();

        return $toReturn;
    }

    /**
     * Delete specified users
     *
     * @param array ids to be deleted
     */
    function delete($ids)
    {
        if (count($ids) > 0) {
            $db = new RecordSet($this->dbConnectionInfo, false, true);
            $query = "DELETE FROM users WHERE userId IN (" . $ids . ");";
            $toReturn = $db->Run($query);
            $db->close();
        }
    }

    /**
     * Get allproduct for witch this user is valid
     *
     * @return multitype:Strign productId=>Name
     */
    function getSharedProducts()
    {
        $toReturn = array();
        $db = new RecordSet($this->dbConnectionInfo, false, true);
        $prds = $db->Open("SELECT product,value FROM webhelp WHERE parameter='name' ;");
        if ($prds > 0) {
            while ($db->MoveNext()) {
                $product = $db->Field('product');
                $value = $db->Field('value');
                $toReturn[$product] = $value;
            }
        }
        $db->close();
        return $toReturn;
    }

    /**
     * Gather user information
     *
     * @param string $username Find information for 'username'
     * @param string $info Required attribute of the user account object
     * @return null|string User information
     * @throws Exception
     */
    public function getUserInformation($username, $info)
    {
        $toReturn = null;

        $db = new RecordSet($this->dbConnectionInfo, false, true);
        $information = $db->Open("SELECT email FROM users WHERE userName = '" . $username . "' AND password != '';");
        switch ($information) {
            case 1:
                // User found in local database
                $toReturn = $db->Field('email');
                break;
            case 0:
                // User not found in local database
                // Try to find it in LDAP
                if ($this->ldap instanceof Ldap) {
                    try {
                        $information = $this->ldap->getUserInfo($username, array($info));
                        $toReturn = @$information[0][$info][0];
                    } catch (Exception $e) {
                        throw new Exception($e->getMessage());
                    }
                }
                break;
            default:
                throw new Exception('No or more than one email address found for ' . $username);
        }

        return $toReturn;
    }

}

?>