<?php
namespace Hcode;
//criando geters and seters dinâmicamente
class Model{
    private $values = [];

    //função vai ser as primeiras 3 letras e ver se é guet ou set
    public function __call($name, $args){
    	$method = substr($name, 0, 3); // a partir da posição 0 traga 0,1,2 || lê as 3 primeiras letras e vê se é get ou set
    	$fildName = substr($name, 3, strlen($name)); //agora lê da posição 3 em diante até o final strlen($name) conta

    	//geters and seters dinamicos
    	switch ($method) {
    		case 'get':
    			return (isset($this->values[$fildName])) ? $this->values[$fildName] : NULL;
    		break;

    		case 'set':
    			$this->values[$fildName] = $args[0];
    		break;
    		
    		default:
    			# code...
    		break;
    	}
    }

    //mátodo que vai pegar dinâmicamente os resultados do banco de dados
    public function setData($data = array()){
    	foreach ($data as $key => $value) {
    		$this->{"set".$key}($value); //tudo dinâmico no php coloca entre chaves {}
    	}
    }

    public function getValues(){
    	return $this->values;
    }
}
?>

