<?php
session_start();
require_once("vendor/autoload.php");

use \Slim\Slim; //namespaces está escolhendo as classes 
use \Hcode\Page; //tem que ser declarado o namespace no inicio da página que esta a classe no caso é namespace Page no arquivo Page;
use \Hcode\PageAdmin;
use \Hcode\Model\User;

$app = new Slim();

$app->config('debug', true);

$app->get('/', function(){ //aqui mostra qual rota estou chamando
    $page = new Page();
    
    $page->setTpl("index");
    
    //aqui já chama o método destruct limpando a meméria como footer
});

$app->get('/admin', function(){ //rota para o admin no modo produção usar nome diferente de admin
    //verifica se o usuário está logado
    User::verifyLogin();

    $page = new PageAdmin();
    
    $page->setTpl("index");
});

$app->get('/admin/login', function(){ //rota para o login
    $page = new PageAdmin([ //para desabilitar o header e o footer
		"header"=>false,
		"footer"=>false
	]); 
    
    $page->setTpl("login");
});

//método posto do formulário de login
$app->post('/admin/login', function(){ //rota para o validação do formulário de login
    User::login($_POST["login"], $_POST["password"]);

    header("Location: /admin");
    exit; //pra parar a execução aqui
});

//rota pra fazer logout
$app->get('/admin/logout', function(){
    User::logout();

    header("Location: /admin/login");
    exit();
});

$app->run(); //tudo carregado? roda o código
?>


