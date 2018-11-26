<?php 
	require_once("../includes/initialize.php");
	header('Content-Type: text/html; charset=utf-8');
	date_default_timezone_set('Asia/Hong_Kong');
	$input 		= json_decode(file_get_contents('php://input'), true);
	$request 	= Request::instantiate($input);
	$api 		= new API();
	$api->handle_command($request->cmd);
	$request->create();
	class API {
		function handle_command($cmd) {
			if (IS_DEVELOPMENT_MODE) sleep(1);
			switch ($cmd) {
				case 'signup'		: $this->signup(); 	return;
				case 'login'		: $this->login(); 	return;
				case 'logout'		: $this->logout(); 	return;
				case 'cPass'		: $this->cPass(); 	return;

				case 'enter'		: $this->enter_app(); 	return;
				case 'sync'			: $this->sync(); 	return;
				case 'exit'			: $this->exit_app(); 	return;

				case 'create'		: $this->create(); 	return;
				case 'update'		: $this->update(); 	return;
				case 'delete'		: $this->delete(); 	return;
			}
		}

		function signup() {
			global $request;
			$request->userID = $request->data["userID"];
			if (User::find_by_userID($request->data["userID"])) {
				$request->err = 1;
				$request->log = "userID exists";
			} else {
				$user = User::instantiate();
				$user->userID = $request->data["userID"];

				$user->hashed_password 	= User::password_encrypt($request->data["password"]);
				$user->create();

				$items = $request->data['items'];
				$this->pushArray($items);
				$request->data = Item::find_for_userID($request->userID);
				$request->err = 0;
				$request->log = "Signup success.";
				$request->userID = $user->userID;
			}
			$request->json_response();
		}

		function pushArray($arr) {
			global $request;
			foreach ($arr as $item) {
				$db_row = Item::find_by_id($item["id"]);
				if ($item["id"] == 0 || !$db_row) {
					$db_row = Item::instantiate($item);
					$db_row->userID = $request->userID;
					$db_row->deleted = 0;
					$db_row->created = $request->time_stamp;
					$db_row->create();
				} else if ($db_row->lastModified <= $item["lastModified"]) {
					$db_row = Item::instantiate($item);
					$db_row->userID = $request->userID;
					$db_row->deleted = 0;
					$db_row->lastModified = $request->time_stamp;
					$db_row->update();
				}
			}
		}

		function login() {
			global $request;
			$request->userID = $request->data["userID"];
			$user = User::find_by_userID($request->data["userID"]);
			if ($user) {
				if ($user->password_check($request->data["password"], $user->hashed_password)) {
					$request->log .= "Login success. ";
					$request->data = Item::find_for_userID($user->userID);
					$request->err = 0;
					$request->userID = $user->userID;
				} else {
					$request->log .= "Password incorrect. ";
					$request->err = 1;
				} 
			} else {
				$request->log .= "Account does not exist. ";
				$request->err = 2;
			}
			
			$session = Session::find_by_installationID($request->installationID);
			if ($session) {
				$session->userID = $request->userID;
			$session->update();
			}

			$request->json_response();
		}

		function logout() {
			global $request;
			$request->err = 0;
			$request->log = "User logout.";
			$request->json_response();
		}

		function cPass() {
			global $request;
			$user = User::find_by_userID($request->userID);
			$user->change_password($request->data["passNew"]);
			$user->update();
			$request->log = "Changed password.";
			$request->err = 0;
			$request->json_response();
		}

		function sync() {
			global $request;

			$items = $request->data;
			
			$this->pushArray($items);

			$request->data = Item::find_for_userID($request->userID);
			$request->log .= "Became active.";
			$request->err = 0;
			$request->json_response();
		}

		function enter_app() {
			global $request;
			$session = Session::instantiate();
			$session->installationID = $request->installationID;
			$session->userID = $request->userID;
			$session->start = $request->time_stamp;
			$session->create();

			$request->sessionID = $session->id;
			$request->log = "Became active.";
			$request->err = 0;
		}

		function exit_app() {
			global $request;
			$session = Session::find_by_installationID($request->installationID);
			$session->end = $request->time_stamp;
			$session->update();
			$request->log = "Resign active.";
			$request->err = 0;
		}

		function create() {
			global $request;
			$instance = Item::instantiate($request->data);
			$instance->userID = $request->userID;
			$instance->deleted = 0;
			$instance->created = $request->time_stamp;
			$instance->create();

			$arr [] = $instance->stripped_array();
			$request->data = $arr;
			$request->log = "Inserted item.";
			$request->err = 0;
			$request->json_response();
		}

		function update() {
			global $request;
			$instance = Item::instantiate($request->data);
			$instance->userID = $request->userID;
			$instance->deleted = 0;
			$instance->lastModified = $request->time_stamp;
			$instance->update();
			$request->log = "Updated item.";
			$request->err = 0;
			$request->json_response();
		}

		function delete() {
			global $request;
			$instance = Item::find_by_id($request->data["id"]);
			$instance->lastModified = $request->time_stamp;
			$instance->delete();
			$request->log = "Deleted item.";
			$request->err = 0;
			$request->json_response();
		}
	}
?>