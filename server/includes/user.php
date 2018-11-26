<?php require_once("initialize.php"); 

header('Content-Type: text/html; charset=utf-8');

Class User {
	protected static $table_name="users";
	protected static $db_fields = array('id', 'userID', 'hashed_password');

	public $id;
	public $userID;
	public $hashed_password;

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

	public static function delete_by_id($id) {
		global $database;
		$query  = "DELETE FROM ";
		$query .= self::$table_name;
		$query .= " WHERE id = {$id} LIMIT 1";
		$result = $database->query($query);
	}

	public function exist() {
		$result_array = self::find_by_userID($this->userID);
		return !empty($result_array) ? true : false;
	}
	// reusable methods end 
	public static function find_by_userID($userID) {
	    $result_array = self::find_by_sql("SELECT * FROM ".self::$table_name." WHERE userID='{$userID}' LIMIT 1");
		$user = !empty($result_array) ? array_shift($result_array) : false;
		return $user;
	}

	public static function password_encrypt($password) {
	    $hash_format ="$2y$10$"; // 10 = cost parameter, the larger the slower
	    $salt_length = 22;
	    $salt = self::generate_salt($salt_length);
	    $format_and_salt = $hash_format . $salt;
	    $hash = crypt($password, $format_and_salt);
	    return $hash;
	}

	public static function generate_salt($length) {
		// Not 100% unique, not 100% random, but good enough for a salt
		// MD5 returns 32 characters
		$unique_random_string = md5(uniqid(mt_rand(), true));

		// Valid characters for a salt are [a-zA-Z0-9./]
		$base64_string = base64_encode($unique_random_string);

		// But not '+' which is valid in base64 encoding
		$modified_base64_string = str_replace('+', '.', $base64_string);

		// Truncate string to the correct length
		$salt = substr($modified_base64_string, 0, $length);

		return $salt;
	}

	public function password_check($password, $existing_hash) {
		// existing hash contains format and salt at start
		// echo $password;
		$hash = crypt($password, $existing_hash);
		// echo " ".$existing_hash;
		// echo " ".$hash;
		if ($hash === $existing_hash) {
			return true;
		} else {
			return false;
		}
	}

	public function change_password($new_password) {
		$this->hashed_password = self::password_encrypt($new_password);
	}
}
?>