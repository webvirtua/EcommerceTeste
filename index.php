<?php /*
require_once ("vendor/autoload.php"); //traz as dependências

use DB\Sql;
use \Hcode\Page; //namespaces
use \Slim\Slim; //namespaces está escolhendo as classes

$app = new Slim(); //slim trabalha com rotas

$app->config('debug', true);

$app->get('/', function(){
    $page = new Page(); //nesse momento ele vai chamar os métodos construtores
    
    $page->setTpl("index");
    
    //aqui já chama o método destruct limpando a meméria como footer
});

$app->run(); //tudo carregado? roda o código
*/?>


<?php //funcionando
use DB\Sql;
use Hcode\Page; //namespaces
use \Slim\Slim; //namespaces está escolhendo as classes

require_once ("vendor/autoload.php");

$app = new Slim();

$app->config('debug', true);

$app->get('/', function(){
    $sql = new Sql();
    
    $results = $sql->select("SELECT * FROM tb_users");
    
    echo json_encode($results);
});

$app->run();
?>


