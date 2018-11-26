<?php
// Define the core paths
// Define them as absolute paths to make sure that require_once works as expected

// DIRECTORY_SEPARATOR is a PHP pre-defined constant
// (\ for Windows, / for Unix)
require_once('conf_server.php');

// load config file first
require_once(LIB_PATH.DS."conf_db.php");
require_once(LIB_PATH.DS.'db_connection.php');

// require_once(LIB_PATH.DS.'database_object.php');

// load core objects
require_once(LIB_PATH.DS.'request.php');
require_once(LIB_PATH.DS.'user.php');
require_once(LIB_PATH.DS.'item.php');
require_once(LIB_PATH.DS.'session.php');
?>