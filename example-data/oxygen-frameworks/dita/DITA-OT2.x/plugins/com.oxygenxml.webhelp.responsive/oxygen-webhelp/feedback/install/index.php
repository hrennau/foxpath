<!DOCTYPE html SYSTEM "about:legacy-compat">
<!-- 
/*
    
Oxygen WebHelp Plugin
Copyright (c) 1998-2017 Syncro Soft SRL, Romania.  All rights reserved.

*/
-->
<html lang="en-US">
<head>
    <title>&lt;oXygen/&gt; XML Editor - WebHelp</title>
    <meta name="Description" content="WebHelp Installer"/>
    <META HTTP-EQUIV="CONTENT-LANGUAGE" CONTENT="en-US"/>
    <link rel="stylesheet" type="text/css" href="../resources/bootstrap/css/bootstrap.min.css"/>
    <link rel="stylesheet" type="text/css" href="install.css"/>
</head>
<?php include('../config/config.php'); ?>
<body>
<div id="logo" class="text-center">
    <img src="../../resources/img/LogoOxygen100x22.png" align="middle" alt="OxygenXml Logo"/>
    WebHelp Installer
</div>
<h1 class="text-center">
    Installation Settings for
    <span class="titProduct"><?php echo __PRODUCT_NAME__; ?></span>&nbsp;<span class="titProduct"><?php echo __PRODUCT_VERSION__; ?></span>
</h1>

<form action="index1.php" method="post" name="form" id="doInstallData">
    <div class="container">
    <div class="panel"><p>Welcome to the WebHelp Installer! It will setup the
            database for WebHelp feedback system and create an appropriate config
            file. In some cases a manual installation cannot be avoided.</p>
        <p>There is an initial Check for (minimal) Requirements appended down
            below for troubleshooting. A MySql database connection must be
                available and <code>../resources/php/config.php</code> must be
            writable for the webserver!</p>
    </div>
    <?php include('check.php'); ?>
    </div>
</form>
<script src="../../resources/js/jquery-3.1.1.min.js"></script>
<script src="../resources/bootstrap/js/bootstrap.min.js"></script>
</body>
</html>
