<?php require_once("initialize.php"); 

class DatabseObject {
	public static function json_response($cmd, $err, $data = array(), $log = "") {
		$jasonArray 		= array();
		$jasonArray['cmd'] 	= $cmd;
		$jasonArray['err'] 	= $err;
		$jasonArray['data'] = $data;
		$jasonArray['log'] 	= $log;
		echo json_encode($jasonArray);
	}
}
?>