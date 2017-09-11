<?php
namespace Hcode\Model;

use \Hcode\DB\Sql;
use \Hcode\Model;
use \Hcode\Mailer;

class User extends Model{
	const SESSION = "User"; //criada sessão com nome User
	const SECRET = "HcodePhp7_Secret"; //chave para descriptografar as senhas
	
	public static function getFromSession(){
	    $user = new User();
	    
	    if(isset($_SESSION[User::SESSION]) && (int)$_SESSION[User::SESSION]['iduser'] > 0){
	        $user->setData($_SESSION[User::SESSION]);
	    }
	    
	    return $user;
	}
	
	public static function checkLogin($inadmin = true){
	    if(
	        !isset($_SESSION[User::SESSION])
	        || !$_SESSION[User::SESSION]
	        || !(int)$_SESSION[User::SESSION]["iduser"] > 0
	    )
	    {
	        return false; //n�o esta logado
	    }else{
	        //chegando rota da administra��o
	        if($inadmin === true && (bool)$_SESSION[User::SESSION]['inadmin'] === true){
	            return true;
	        }else if($inadmin ===  false){
	            return true;
	        }else{
	            return false;
	        }
	    }
	}

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
		if(User::checkLogin($inadmin)){ //se a sessão não for definida
			header("Location: /admin/login");
			exit();
		}
	}

	public static function logout(){
		$_SESSION[User::SESSION] = NULL;
	}

	public static function listAll(){
		$sql = new Sql();

		return $sql->select("SELECT * FROM tb_users a INNER JOIN tb_persons b USING(idperson) ORDER BY b.desperson");
	}

	//método para salvar no banco USANDO UMA PROCEDURE
	public function save(){
		$sql = new Sql();

		$results = $sql->select("CALL sp_users_save(:desperson, :deslogin, :despassword, :desemail, :nrphone, :inadmin)", array( //chamada da procedure
			":desperson"=>$this->getdesperson(),
			":deslogin"=>$this->getdeslogin(),
			":despassword"=>$this->getdespassword(),
			":desemail"=>$this->getdesemail(),
			":nrphone"=>$this->getnrphone(),
			":inadmin"=>$this->getinadmin()
		));

		$this->setData($results[0]);
	}

	public function get($iduser){
		$sql = new Sql();

		$results = $sql->select("SELECT * FROM tb_users a INNER JOIN tb_persons b USING(idperson) WHERE a.iduser = :iduser", array(
			":iduser"=>$iduser
		));

		$this->setData($results[0]);
	}

	public function update(){
		$sql = new Sql();

		$results = $sql->select("CALL sp_usersupdate_save(:iduser, :desperson, :deslogin, :despassword, :desemail, :nrphone, :inadmin)", array( //chamada da procedure
			":iduser"=>$this->getiduser(),
			":desperson"=>$this->getdesperson(),
			":deslogin"=>$this->getdeslogin(),
			":despassword"=>$this->getdespassword(),
			":desemail"=>$this->getdesemail(),
			":nrphone"=>$this->getnrphone(),
			":inadmin"=>$this->getinadmin()
		));

		$this->setData($results[0]);
	}

	public function delete(){
		$sql = new Sql();

		$sql->query("CALL sp_users_delete(:iduser)", array(
			":iduser"=>$this->getiduser()
		));
	}
	
	public static function getForgot($email){    
	    $sql = new Sql();
	    
	    $results = $sql->select("SELECT * FROM tb_persons a INNER JOIN tb_users b USING(idperson) WHERE a.desemail = :email;", array(
	        ":email"=>$email //validando o email e verificando se existe
	    ));
	    
	    if(count($results) === 0){
	        throw new \Exception("N�o foi poss�vel recuperar a senha.");
	    }else{
	        $data = $results[0];
	        
	        $results2 = $sql->select("CALL sp_userspasswordsrecoveries_create(:iduser, :desip)", array(
	            ":iduser"=>$data["iduser"],
	            ":desip"=>$_SERVER["REMOTE_ADDR"] //pega o ip do usu�rio
	        ));
	        
	        if(count($results2) === 0){
	            throw new \Exception("N�o foi poss�vel recuperar a senha.");
	        }else{
	            //PARTE DA CRIPTOGRAFIA DA SENHA
	            $dataRecovery = $results2[0];
	            //encriptando
	            $code = base64_encode(mcrypt_encrypt(MCRYPT_RIJNDAEL_128, User::SECRET, $dataRecovery["idrecovery"], MCRYPT_MODE_ECB));
	            
	            //link, endere�o que vai ser enviado o codigo e link do email
	            $link = "http://www.hcodecommerce.com.br/admin/forgot/reset?code=$code";
	            
	            $mailer = new Mailer($data["desemail"], $data["desperson"], "Redefinir Senha Hcode", "forgot", array(
	                "name"=>$data["desperson"],
	                "link"=>$link
	            ));
	            //enviando o email
	            $mailer->send();
	            
	            return $data;
	        }
	    }
	}
	//valida��o do c�digo do email quando clica no link
	public static function validForgotDecrypt($code){
	    $idrecovery = mcrypt_decrypt(MCRYPT_RIJNDAEL_128, User::SECRET, base64_decode($code), MCRYPT_MODE_ECB);
	    
	    $sql = new Sql();
	    
	    $results = $sql->select("
            SELECT * FROM tb_userspasswordsrecoveries a 
            INNER JOIN tb_users b USING(iduser)
            INNER JOIN tb_persons c USING(idperson)
            WHERE 
            	a.idrecovery = :idrecovery 
                AND a.dtrecovery IS NULL
                AND DATE_ADD(a.dtregister, INTERVAL 5 HOUR) >= NOW();
	    ", array(
	        ":idrecovery"=>$idrecovery
	    ));
	    
	    if(count($results) === 0){
	        throw new \Exception("N�o foi poss�vel recuperar a senha");
	    }else{
	        return $results[0];
	    }
	}
	//m�todo vai verificar se a recupera��o de senha foi usada e n�o deixar usar de novo se j� foi
	public static function setForgotUsed($idrecovery){
        $sql = new Sql();
        
        $sql->query("UPDATE tb_userspasswordsrecoveries SET dtrecovery = NOW() WHERE idrecovery = :idrecovery", array(
            ":idrecovery"=>$idrecovery
        ));
	}
	
	public function setPassword($password){
	    $sql = new Sql();
	    
	    $sql->query("UPDATE tb_users SET despassword = :password WHERE iduser = :iduser", array(
	        ":password"=>$password,
	        ":iduser"=>$this->getiduser()
	    ));
	}
}
?>