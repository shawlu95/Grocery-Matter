<?php require_once("initialize.php"); 

header('Content-Type: text/html; charset=utf-8');

Class Session {
	protected static $table_name="sessions";
	protected static $db_fields = array('id', 'userID', 'installationID', 'start', 'end');

	public $id;
	public $userID;
	public $installationID;
	public $start;
	public $end;

	public static function instantiate($record) {
		$object = new self;
		foreach($record as $attribute=>$value){
			if($object->has_attribute($attribute)) {
				$object->$attribute = $value;
			}
		}
		return $object;
	}

	private function has_attribute($attribute) {
	  // We don't care about the value, we just want to know if the key exists
	  // Will return true or false
	  return array_key_exists($attribute, $this->attributes());
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
		$attributes = $this->attributes();
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
		$attributes = $this->attributes();
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
		$attributes = $this->attributes();
		foreach($attributes as $key => $value) {
			$array[$key] = $value;
		}
		return $array;
	}

	public static function find_by_id($id) {
	    $result_array = self::find_by_sql("SELECT * FROM ".self::$table_name." WHERE id={$id} LIMIT 1;");
		return !empty($result_array) ? array_shift($result_array) : false;
	}

	// reusable methods end 
	public static function find_by_installationID($installationID) {
	    $result_array = self::find_by_sql("SELECT * FROM ".self::$table_name." WHERE installationID='{$installationID}' ORDER BY start DESC LIMIT 1");
		$user = !empty($result_array) ? array_shift($result_array) : false;
		return $user;
	}
}
?>