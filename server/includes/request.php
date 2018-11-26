<?php require_once("initialize.php"); 

header('Content-Type: text/html; charset=utf-8');

Class Request {
	protected static $table_name="requests";
	protected static $db_fields = array('id', 'cmd', 'err', 'data', 'time_stamp', 'userID', 'log', 'installationID', 'sessionID');

	public $id;
	public $cmd;
	public $err;
	public $data;
	public $time_stamp;
	public $userID;
	public $log;
	public $installationID;
	public $sessionID;

	public static function instantiate($record) {
		$request = new self;
		$request->cmd = $record["cmd"];
		$request->data = $record["data"];
		$request->userID = $record["userID"];
		$request->time_stamp = date("Y-m-d H:i:s");
		$request->installationID = $record["installationID"];

		$current_session = Session::find_by_installationID($request->installationID);
		$request->sessionID = $current_session->id;
		return $request;
	}

	private function has_attribute($attribute) {
	  // We don't care about the value, we just want to know if the key exists
	  // Will return true or false
	  return array_key_exists($attribute, $this->attributes());
	}

	protected function non_null_attributes() {
		$non_null_attributes = array();
		foreach($this->sanitized_attributes() as $key => $value){
			// Only add atrtibute if the value exists, otherwise, phpMyAdmin applies default attribute
			if ($value) {
				$non_null_attributes[$key] = $value;
			}
		}
		return $non_null_attributes;
	}

	protected function attributes() { 
		// return an array of attribute names and their values
		$attributes = array();
		foreach(self::$db_fields as $field) {
			if(property_exists($this, $field)) {
				$attributes[$field] = $this->$field;
			}
		}
		return $attributes;
	}

	protected function sanitized_attributes() {
		global $database;
		$clean_attributes = array();
		// sanitize the values before submitting
		// Note: does not alter the actual value of each attribute
		foreach($this->attributes() as $key => $value){
			$clean_attributes[$key] = $database->escape_value($value);
		}
		return $clean_attributes;
	}

	public static function find_by_sql($sql="") {
		global $database;
		$result_set = $database->query($sql);
		$object_array = array();
		while ($row = $database->fetch_array($result_set)) {
			$object_array[] = self::instantiate($row);
		}
		return $object_array;
	}

	// By using "non_null_attributes", only attribuets with values are saved,
	// attribtues with no values are set to default values.
	public function create () {
		global $database;
		unset($this->data);
		$attributes = $this->non_null_attributes();
		$sql = "INSERT INTO ".self::$table_name." (";
		$sql .= join(", ", array_keys($attributes));
		$sql .= ") VALUES ('";
		$sql .= join("', '", array_values($attributes));
		$sql .= "')";
		if($database->query($sql)) {
			$this->id = $database->insert_id();
			return true;
		} else {
			return false;
		}
	}

	// By using "non_null_attributes", only attribuets with values are saved,
	// this ensure that attribteus with defaults values are not erased.
	public function update() {
		global $database;
		$attribute_pairs = array();
		$attributes = $this->non_null_attributes();
		foreach($attributes as $key => $value) {
			$attribute_pairs[] = "{$key}='{$value}'";
		}
		$sql = "UPDATE ".self::$table_name." SET ";
		$sql .= join(", ", $attribute_pairs);
		$sql .= " WHERE id=". $database->escape_value($this->id);
		$database->query($sql);
		return ($database->affected_rows() == 1) ? true : false;
	}

	// Prepare the obejct as a JSON representation, with null attribuet removed,
	// in order to minimize the size of the response body.
	public function stripped_array() {
		$array = array();
		$attributes = $this->non_null_attributes();
		foreach($attributes as $key => $value) {
			$array[$key] = $value;
		}
		return $array;
	}

	public static function find_by_id($id) {
	    $result_array = self::find_by_sql("SELECT * FROM ".self::$table_name." WHERE id={$id} LIMIT 1");
		return !empty($result_array) ? array_shift($result_array) : false;
	}
	// reusable methods end 

	public function json_response() {
		global $database;

		unset($this->user);
		unset($this->id);
		$this->time_stamp = date("Y-m-d H:i:s");
		if (!IS_DEVELOPMENT_MODE) {
			unset($this->log);
		}
		echo json_encode((array)$this);
	}
}
?>