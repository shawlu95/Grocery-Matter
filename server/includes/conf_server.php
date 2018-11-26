<?php
defined('DS') ? null : define('DS', DIRECTORY_SEPARATOR);

// local server, Xiao's Mac
// defined('SITE_ROOT') ? null : define('SITE_ROOT', DS.'Applications'.DS.'MAMP'.DS.'htdocs'.DS.'grocery');

// remote server, Alicloud
// defined('SITE_ROOT') ? null : define('SITE_ROOT', DS.'alidata'.DS.'www'.DS.'default'.DS.'grocery');

// remote server, AWS
defined('SITE_ROOT') ? null : define('SITE_ROOT', DS.'var'.DS.'www'.DS.'html'.DS.'server'.DS.'grocery');

define('IS_DEVELOPMENT_MODE', true);
defined('LIB_PATH') ? null : define('LIB_PATH', SITE_ROOT.DS.'includes');
?>