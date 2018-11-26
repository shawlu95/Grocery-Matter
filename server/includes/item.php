<?php require_once("initialize.php"); 

header('Content-Type: text/html; charset=utf-8');

Class Item {
	protected static $table_name="items";
	protected static $db_fields = array('id', 'userID', 'name', 'type', 'count', 'price', 'time', 'created', 'lastModified', 'deleted');

	public $id;
	public $userID;
	public $name;
	public $type;
	public $count;
	public $price;
	public $time;
	public $created;
	public $lastModified;
	public $deleted;

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

	public function delete() {
		global $database;
		$this->lastModified = date("Y-m-d H:i:s");
		$this->deleted = 1;
		$this->update();
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

	public function exist() {
		$result_array = self::find_by_id($this->id);
		return !empty($result_array) ? true : false;
	}

	
	public static function find_for_userID($userID) {
		return self::find_by_sql("SELECT * FROM ".self::$table_name." WHERE userID='{$userID}';");
	}
	// public function exist() {
	// 	$name = $this->name;
	// 	$count = $this->count;
	// 	$price = $this->price;
	// 	$time = $this->time;

	// 	$query   = "SELECT * ";
	// 	$query 	.= "FROM ".self::$table_name." ";
	// 	$query 		.= " WHERE name='{$name}'";
	// 	$query 		.= " AND count='{$count}'";
	// 	$query 		.= " AND price='{$price}'";
	// 	$query 		.= " AND time='{$time}' LIMIT 1;";

	// 	$result_array = self::find_by_sql($query);
	// 	return !empty($result_array) ? true : false;
	// }
	// reusable methods end 
}
?>