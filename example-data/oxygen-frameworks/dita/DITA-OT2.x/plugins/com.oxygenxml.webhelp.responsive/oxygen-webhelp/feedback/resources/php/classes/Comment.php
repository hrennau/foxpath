<?php

/*

Oxygen WebHelp Plugin
Copyright (c) 1998-2017 Syncro Soft SRL, Romania.  All rights reserved.

*/

class Comment
{
    /**
     * DB Connection info  set in the configuration file
     *
     * @var array storring 'dbName', 'dbUser', 'dbPassword', 'dbHost'
     */
    private $dbConnectionInfo;
    /**
     * CSS class name
     *
     * @var String
     */
    private $cssClass;
    /**
     * Full user name form session
     *
     * @var String
     */
    private $fullUser;

    /**
     * Constructor
     *
     * @param array $dbConnectionInfo db connection info
     * @param String $styleClass css class for output <ul>
     */
    function __construct($dbConnectionInfo, $styleClass = "", $fullUser = "")
    {
        $this->dbConnectionInfo = $dbConnectionInfo;
        $this->cssClass = $styleClass;
        $this->fullUser = $fullUser;
    }

    /**
     * Check if is a logged user with moderation rights in order to update comments
     * @param string $product product specified in comment
     * @param string $product version specified in comment
     * @param int $cmtUser userId from comment - if is the same user as the logged one then it will be administrator for that comment
     * @return true if there is a logged user found in session
     */
    function isLoggedModerator($cmtUser = -2)
    {
        $ses = Session::getInstance();
        $fullUser = $this->fullUser;
        $toReturn = false;
        if (isset($ses->$fullUser) && $ses->$fullUser instanceof User) {
            if (($ses->$fullUser->isAnonymous != 'true') && (($ses->$fullUser->level != 'user' || $ses->$fullUser->userId == $cmtUser))) {
                $toReturn = true;
            }
        }
        return $toReturn;
    }

    /**
     * Moderate a specified comment
     *
     * @param commentId $id
     * @param string $state state to be updated to 'new', 'approved', 'rejected', 'suspended'
     *
     * @return array 'page','oldState'
     */
    function moderate($id, $state)
    {
        //approved
        $adminPage = "../admin.html";
        $toReturn = array();
        $toReturn['page'] = $adminPage . "?a=login";
        $toReturn['oldState'] = "";
        $db = new RecordSet($this->dbConnectionInfo);
        $query = "SELECT * FROM comments WHERE commentId=$id;";
        if ($db->Open($query) > 0) {
            $db->MoveNext();
            $product = $db->Field("product");
            $cmtUser = $db->Field("userId");
            $toReturn['page'] = $db->Field("page") . "?l=login";
            if ($this->isLoggedModerator($cmtUser) && ($state == 'deleted')) {
                $toReturn['page'] = $db->Field("page");
                $toReturn['oldState'] = $db->Field("state");
// 				$query0="DELETE FROM comments WHERE commentId=$id OR referedComment=$id;";
// 				$db->Run($query0);
                $this->deleteRecursive(array($id));
            }
            if ($this->isLoggedModerator() && ($state != 'deleted')) {
                $toReturn['page'] = $db->Field("page");
                $toReturn['oldState'] = $db->Field("state");
                $query0 = "UPDATE comments SET date=date,state='" . $state . "' WHERE commentId=$id";
                $db->Run($query0);
            }
        }
        $db->Close();
        return $toReturn;
    }

    /**
     * Delete all comments with specified ids
     * @param string $ids enumeration as "0,1,2"
     */
    function deleteComments($ids)
    {
        $toDelete = preg_split('/,/', $ids);
        $toReturn = false;
        $this->deleteRecursive($toDelete);
        return $toReturn;
    }

    /**
     * Approve all comments on the specified page
     *
     * @param unknown_type $page
     * @return array of comments approved for the page
     */
    function approveAll($page)
    {
        $toReturn = array();
        $db = new RecordSet($this->dbConnectionInfo);
        $query = "SELECT commentId FROM comments WHERE page='" . $db->sanitize($page) . "' AND (state='new' OR state='suspended');";
        if ($db->Open($query)) {
            while ($db->MoveNext()) {
                $id = $db->Field('commentId');
                $toReturn[] = $id;
                $this->moderate($id, 'approved');
            }
        }
        return $toReturn;
    }

    /**
     * Insert comment into database
     *
     * @param array $info containing 'page','text','referedComment','sessionUser'
     * @return array containing int no of rows affected, and commnetId of the new inserted comment
     */
    function insert($info)
    {
        $toReturn = array();
        $db = new RecordSet($this->dbConnectionInfo);
        $page = $db->sanitize($info['page']);
        $text = $db->sanitize(Utils::strip_html_tags($info['text']));
        $userName = $info['sessionUserName'];
        $product = $db->sanitize($info['product']);
        $version = $db->sanitize($info['version']);

        $refCom = $db->sanitize($info['referedComment']);
        $toReturn['rows'] = -1;
        $ses = Session::getInstance();
        if (isset($ses->$userName)) {
            $user = $ses->$userName;
            $state = ($user->level != 'user' ? "approved" : "new");
            if (defined('__MODERATE__') && !__MODERATE__) {
                $state = "approved";
            }
            $userId = $user->userId;
            $date = date("Y-m-d H:i:s");
            $sql = "INSERT INTO comments(text,page,userId,date,referedComment,state,product,version,visible) VALUES ('$text','$page',$userId,'$date','$refCom','$state','$product','$version','true');";
            $toReturn['rows'] = $db->Run($sql);
            $db->open("SELECT commentId FROM comments WHERE text='" . $text . "' AND date='" . $date . "' AND userId='" . $userId . "'");
            $db->MoveNext();
            $toReturn['id'] = $db->Field("commentId");
            $db->Close();
        }
        $this->updateProductPath($product, $version);
        return $toReturn;
    }

    private function updateProductPath($product, $version)
    {
        global $productId, $productVersion;
        $db = new RecordSet($this->dbConnectionInfo, false, true);
        $product = $db->sanitize($product);
        $version = $db->sanitize($version);
        $db->run("UPDATE webhelp SET value='" . addslashes(__BASE_URL__) . "' WHERE parameter='path' AND product='" . $product . "' AND version='" . $version . "';");
        $db->run("UPDATE webhelp SET value='" . addslashes(__BASE_DIR__) . "' WHERE parameter='dir' AND product='" . $product . "' AND version='" . $version . "';");
        $db->run("UPDATE webhelp SET value='" . addslashes(__PRODUCT_NAME__) . "' WHERE parameter='name' AND product='" . $product . "' AND version='" . $version . "';");
        $db->Close();
    }

    /**
     * Update comment into database
     *
     * @param array $info containing 'page','text','referedComment','sessionUser','editedId'
     * @return array containing int no of rows affected, and commnetId of the new inserted comment
     */
    function update($info)
    {
        $toReturn = array();
        $db = new RecordSet($this->dbConnectionInfo);
        $commentId = (isset($info['editedId']) && (strlen(trim($info['editedId'])) > 0) ? trim($info['editedId']) : -1);
        $query = "SELECT * FROM comments WHERE commentId=$commentId;";
        $toReturn['rows'] = -1;
        if ($db->Open($query) > 0) {
            $db->MoveNext();
            $product = $db->Field("product");
            $version = $db->Field("version");
            $cmtUser = $db->Field("userId");
            if ($this->isLoggedModerator($cmtUser)) {
                $text = $db->sanitize(Utils::strip_html_tags($info['text']));
                $sql = "UPDATE comments SET date=date, text = '" . $text . "' WHERE commentId = " . $commentId . ";";
                $toReturn['rows'] = $db->Run($sql);
                $toReturn['id'] = $commentId;
            }
        }
        $db->Close();
        return $toReturn;
    }

    function isAnonymous($idUser)
    {
        return ($idUser == 1);
    }


    public function getMinimVersion($product, $version)
    {
        $db = new RecordSet($this->dbConnectionInfo);
        $paramVersion = -1;
        $product = $db->sanitize($product);
        if ($db->Open("SELECT value FROM webhelp WHERE parameter='minVisibleVersion' AND product='" . $product . "' AND version ='" . $version . "';")) {
            $db->MoveNext();
            $paramVersion = $db->Field("value");
        } else if ($db->Open("SELECT value FROM webhelp WHERE parameter='minVisibleVersion' AND product='" . $product . "' AND version='';")) {
            $db->MoveNext();
            $paramVersion = $db->Field("value");
        } else if ($db->Open("SELECT version FROM webhelp WHERE product='" . $product . "' ORDER BY version LIMIT 1;")) {
            $db->MoveNext();
            $paramVersion = $db->Field("version");
        }
        $db->close();
        return $paramVersion;
    }

    /**
     * List all commments for a specified page
     *
     * @param array $info containing the page, product, version, userId
     * @param int $refId referenced comment
     * @param boolean $isForAdmin
     * @return String html output
     *
     */
    function listForPage($info, $refId = -1, $isForAdmin = false)
    {
        $toReturn = "";
        $db = new RecordSet($this->dbConnectionInfo);
        $page = $info['page'];
        $product = $db->sanitize($info['product']);
        $version = $db->sanitize($info['version']);
        $idUser = $info['userId'];

        $paramVersion = $db->sanitize($this->getMinimVersion($product, $version));

        $isAnonimous = $this->isAnonymous($idUser);

        $sql = "SELECT c.*, u.userName name, u.name displayName
			FROM comments c, users u 
			WHERE c.visible='true' 
			AND u.userId=c.userId 
			AND c.version<='" . $version . "'
			AND c.version>='$paramVersion'";
        // Get only approved messages
        if ($isAnonimous) {
            $sql .= " AND c.state='approved'";
        }
        if ($refId > 0) {
            $sql .= " AND referedComment=$refId";
        } else {
            if (defined('__SHARE_WITH__')) {
                $productSelect = "(product='$product' OR product in (";
                $shareArray = explode(",", __SHARE_WITH__);
                foreach ($shareArray as $key => $value) {
                    $productSelect .= "'" . $db->sanitize($value) . "', ";
                }
                $productSelect = substr($productSelect, 0, -2) . "))";
            } else {
                $productSelect = "product='$product'";
            }
            $sql .= " AND page='$page' AND $productSelect AND referedComment=0";
        }
        $sql .= " ORDER BY date ASC";

        if ($db->Open($sql)) {
            $toReturn .= "<ul class='$this->cssClass'>";
            while ($db->MoveNext()) {
                $parent = $db->Field('commentId');
                $state = $db->Field('state');

                if (($db->Field('userId') == $idUser && $state == 'new') || $isForAdmin || $state == 'approved') {
                    $toReturn .= "<li id=\"" . $parent . "\"><a name=\"$parent\"></a>";
                    $query = "SELECT * FROM comments WHERE visible='true' AND referedComment=$parent AND version<='" . $version . "' AND version>='$paramVersion' ";

                    $mustModerate = false;
                    $toReturn .= "<div id=\"c_" . $parent . "\" class=\"liContent\">";
                    if ($idUser == $db->Field('userId') && $state == 'new' && !$isForAdmin) {
                        $mustModerate = true;
                        $toReturn .= "<div class=\"mustBeModerate\">";
                    }

                    if ($state == 'suspended') {
                        $toReturn .= "<div class=\"suspended\">";
                    }
                    $toReturn .= "<div class=\"head\">";
                    $db1 = new RecordSet($this->dbConnectionInfo);
                    $drill = false;
                    if ($state == 'approved') {
                        if ($db1->Open($query)) {
                            $drill = true;
                            $toReturn .= "<span class=\"minus\" id=\"toggle_$parent\" onclick='toggleReply($parent);'/>";
                        }
                    }

                    $toReturn .= "<div class='name'>";
                    $toReturn .= $db->Field('displayName') ? $db->Field('displayName') : $db->Field('name');
                    $toReturn .= "</div>";
                    if ($isForAdmin) {
                        $toReturn .= "<div class='bt_admin'>";
                        $toReturn .= "<span class='commentState'>";
                        $toReturn .= Utils::translate($state);
                        $toReturn .= "</span>";
                        $toReturn .= "<div class=\"actions\">";
                        if ($state != "approved") {
                            $toReturn .= "<button type='button' class='btn btn-default btn-sm bt_delete' title='" . Utils::translate("delete") . "' onclick='showConfirmDeleteDialog(" . $parent . ")'>" . Utils::translate("delete") . "</button>";
                            $toReturn .= "<button type='button' class='btn btn-default btn-sm bt_edit' title='" . Utils::translate("edit") . "' onclick='editPost(" . $parent . ")'>" . Utils::translate("edit") . "</button>";
                            $toReturn .= "<button type='button' class='btn btn-default btn-sm bt_approve' title='" . Utils::translate("approve") . "' onclick='moderatePost(" . $parent . ",\"approved\")'>" . Utils::translate("approve") . "</button>";
                        } else {
                            if ($state == "approved") {
                                $toReturn .= "<button type='button' class='btn btn-default btn-sm bt_delete' title='" . Utils::translate("delete") . "' onclick='showConfirmDeleteDialog(" . $parent . ")'>" . Utils::translate("delete") . "</button>";
                                $toReturn .= "<button type='button' class='btn btn-default btn-sm bt_edit' title='" . Utils::translate("edit") . "' onclick='editPost(" . $parent . ")'>" . Utils::translate("edit") . "</button>";
                                //$toReturn.="<span class='bt_suspend' title='".Utils::translate("suspend")."' onclick='moderatePost(".$parent.",\"suspended\")'>".Utils::translate("suspend")."</span>";
                            }
                        }
                        $toReturn .= "</div>";
                        $toReturn .= "</div>";
                        $toReturn .= "<div class='version'>(v&nbsp;" . $db->Field('version') . ")</div>";
                        $toReturn .= "<div class='product'>" . $db->Field('product') . "</div>";
                    }

                    $time = new \DateTime('now', new DateTimeZone(__TIMEZONE__));
                    $timezoneOffset = $time->format('P');

                    $toReturn .= "<div class='date'>" . $db->Field('date') . " GMT" . $timezoneOffset . " " . "</div>";
                    $toReturn .= "</div>";
                    if ($this->isAnonymous($idUser) && $mustModerate) {
                        $toReturn .= "<div class=\"content\" id=\"cmt_text_" . $parent . "\">" . Utils::translate('unavailableTextTillApproved') . "</div>";
                    } else {
                        $toReturn .= "<div class=\"content\" id=\"cmt_text_" . $parent . "\">" . $db->Field('text') . "</div>";
                    }

                    // moved from top of a comment
                    if ((($idUser == $db->Field('userId') && $state == 'new') && !$isForAdmin) || ($state == 'approved' && !$isForAdmin))
                    {
                        if (!$this->isAnonymous($idUser) && $idUser == $db->Field('userId')) {
                            $toReturn .= "<div class=\"actions\">";
                            $toReturn .= "<button type='button' class='bt_delete btn btn-default btn-sm' title='" . Utils::translate("delete") . "' onclick='showConfirmDeleteDialog(" . $parent . ")'>" . Utils::translate("delete") . "</button>";
                            $toReturn .= "<button type='button' class='bt_edit btn btn-default btn-sm' title='" . Utils::translate("edit") . "' onclick='editPost(" . $parent . ")'>" . Utils::translate("edit") . "</button>";
                            $toReturn .= "</div>";
                        }
                    }

                    if ($state == "approved") {
                        $toReturn .= "<div class=\"content\" id='bt_reply_" . $parent . "'>";
                        $toReturn .= "<span class='bt_reply' onclick='reply(this," . $parent . ")'>" . Utils::translate("reply") . "</span>";
                        $toReturn .= "</div>";
                    }
                    if ($mustModerate) {
                        $toReturn .= "<div class=\"moderationInfo\"><span class=\"glyphicon glyphicon-exclamation-sign\"></span>";
                        $toReturn .= Utils::translate("comment.moderate.info");
                        $toReturn .= "</div>";
                        $toReturn .= "</div>";
                    }
                    if ($state == 'suspended') {
                        $toReturn .= "</div>";
                    }
                    $toReturn .= "</div>";
                    if ($drill) {
                        $toReturn .= $this->listForPage($info, $parent, $isForAdmin);
                    }
                    if ($db1->m_DBErrorNumber) {
                        error_log($db1->m_DBErrorNumber . ": " . $db1->m_DBErrorMessage);
                    }
                    $db1->Close();
                    $toReturn .= "</li>";
                }
            }
            $toReturn .= "</ul>";
        } else {
            $toReturn = "";
        }
        if ($db->m_DBErrorNumber) {
            error_log($db->m_DBErrorNumber . ": " . $db->m_DBErrorMessage);
        }
        $db->Close();
        return $toReturn;
    }

    /**
     * export Comments for a specified page
     * @param array $info exporting information
     * @param IExporter $exporter exporter to be used
     */
    function exportForPage($info, $exporter, $fields = null)
    {
        $toReturn = "";
        $db = new RecordSet($this->dbConnectionInfo);
        $whereClause = " WHERE ";
        if ($info["filter_version"] != "" && $info["filter_product"] != "") {
            $whereClause .= " version='" . $db->sanitize($info["filter_version"]) . "' AND product='" . $db->sanitize($info["filter_product"]) . "'";
        } else {
            $whereClause = "";
        }
        if ($this->isLoggedModerator()) {
            $select = "*";
            if ($fields != null) {
                $select = Utils::arrayToString($fields, ",");
            }
            $sql = "SELECT " . $select . " FROM comments " . $whereClause . " ORDER BY date DESC";

            if ($db->Open($sql)) {
                $rowArray = $db->getAssoc();
                while ($rowArray) {
                    if (is_array($rowArray)) {
                        $exporter->exportRow($rowArray);
                    }
                    $rowArray = $db->getAssoc();
                }
            }
            $db->Close();
        } else {
            $exporter->exportRow(array('ERROR' => 'Your user rights do not permit this operation!'));
        }
    }

    /**
     * Obtain coment info by provided id
     *
     * @param int $id
     * @return array containing 'text','name'
     */
    function getInfo($id)
    {
        $toReturn = array();
        $db = new RecordSet($this->dbConnectionInfo);
        $sql = "SELECT c.*,u.name name,u.userName userName FROM comments c,users u WHERE u.userId=c.userId AND commentId='" . $id . "';";
        $rows = $db->Open($sql);
        if ($rows > 0) {
            $db->MoveNext();
            $toReturn['text'] = $db->Field("text");
            $toReturn['name'] = $db->Field("name");
            $toReturn['product'] = $db->Field("product");
            $toReturn['userName'] = $db->Field("userName");
        }
        $db->Close();
        return $toReturn;
    }

    /**
     * Set the minimal version to show comments for
     *
     * @param String product to set comments version
     * @param String minVersion to set as minimal comments version
     *
     * @return boolean true if set has been succeded
     */
    function setMinimalVisibleVersion($product, $minVersion, $version)
    {
        $db = new RecordSet($this->dbConnectionInfo);

        $toReturn = true;
        if ($this->isLoggedModerator()) {
            $selectQ = "SELECT value FROM webhelp WHERE parameter='minVisibleVersion' AND product='" . $db->sanitize($product) . "' AND version='" . $version . "';";
            if ($db->Run($selectQ) > 0) {
                $query = "UPDATE webhelp SET value = '$minVersion' WHERE parameter='minVisibleVersion' AND product='" . $db->sanitize($product) . "' AND version='" . $version . "';";
                $db->Run($query);
            } else {
                $query = "INSERT INTO webhelp (parameter, value, product, version) VALUES ('minVisibleVersion', '" . $db->sanitize($minVersion) . "', '" . $db->sanitize($product) . "', '" . $version . "')";
                $db->Run($query);
            }
        } else {
            $toReturn = false;
        }


        $db->Close();
        return $toReturn;
    }

    /**
     * Query all versions for a specified product
     *
     * @param $product product to query versions for
     * @param $version current product version
     * @return array String:Strign
     * @throws Exception
     */
    function queryVersions($product, $version)
    {
        $toReturn = array();
        $db = new RecordSet($this->dbConnectionInfo);
        $query = "SELECT version,visible FROM comments WHERE product='" . $db->sanitize($product) . "' AND version<='" . $version . "' ORDER by version;";
        if ($db->Open($query) > 0) {
            while ($db->MoveNext()) {
                $toReturn[$db->Field('version')] = $db->Field('visible');
            }
        }
        $db->Close();
        return $toReturn;
    }

    /**
     * Query all products and versions for existing comments
     */
    function queryInfo()
    {
        $toReturn = array();
        $db = new RecordSet($this->dbConnectionInfo);
        $query = "SELECT DISTINCT product,version FROM comments ORDER BY product;";
        if ($db->Open($query) > 0) {
            while ($db->MoveNext()) {
                $toReturn[$db->Field('product')][] = $db->Field('version');
            }
        }
        $db->Close();
        return $toReturn;
    }

    function deleteRecursive($ids)
    {
        if (count($ids) > 0) {
            $db = new RecordSet($this->dbConnectionInfo, false, true);
            $toDelete = array();
            $idsS = implode(", ", $ids);
            $db->open("SELECT commentId FROM comments WHERE referedComment in (" . $idsS . ");");
            while ($db->MoveNext()) {
                $toDelete[] = $db->Field("commentId");
            }

            $query = "DELETE FROM comments WHERE commentId in (" . $idsS . ");";
            $toReturn = $db->Run($query);

            $db->close();
            if (count($toDelete) > 0) {
                $this->deleteRecursive($toDelete);
            }
        }
    }

}

?>