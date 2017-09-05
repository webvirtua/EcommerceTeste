<?php
namespace Hcode\Model;

use \Hcode\DB\Sql;
use \Hcode\Model;

class User extends Model{
	const SESSION = "User"; //criada sessão com nome User

	public static function login($login, $password){
		$sql = new Sql();

		$results = $sql->select("SELECT * FROM tb_users WHERE deslogin = :LOGIN", array(
			":LOGIN"=>$login //vai ser a variável que esta no método
		));

		if(count($results) === 0){
			throw new \Exception("Usuário inexistente ou senha inválida."); //contra barra é pra achar a exception principal		
		}

		$data = $results[0];

		if(password_verify($password, $data["despassword"]) === true){
			$user = new User();

			//pegar dinâmicamente || cada resultado do banco vai criar uma atributo para cada campo
			$user->setData($data);

			//criando a sessão
			$_SESSION[User::SESSION] = $user->getValues();

			return $user;
		}else{
			throw new \Exception("Usuário inexistente ou senha inválida.");
		}
	}

	//método que verifica se o usuário está logado ou não
	public static function verifyLogin($inadmin = true){
		if(
			!isset($_SESSION[User::SESSION]) 
			|| !$_SESSION[User::SESSION] 
			|| !(int)$_SESSION[User::SESSION]["iduser"] > 0 
			|| (bool)$_SESSION[User::SESSION]["inadmin"] !== $inadmin
		  )
		{ //se a sessão não for definida
			header("Location: /admin/login");
			exit();
		}
	}

	public static function logout(){
		$_SESSION[User::SESSION] = NULL;
	}
}
?>