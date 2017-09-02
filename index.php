<?php
require_once("vendor/autoload.php");

use \Slim\Slim; //namespaces está escolhendo as classes
use \Hcode\Page; //tem que ser declarado o namespace no inicio da página que esta a classe no caso é namespace Page no arquivo Page;

$app = new Slim();

$app->config('debug', true);

$app->get('/', function(){ //aqui mostra qual rota estou chamando
    $page = new Page();
    
    $page->setTpl("index");
    
    //aqui já chama o método destruct limpando a meméria como footer
});

$app->run(); //tudo carregado? roda o código
?>


