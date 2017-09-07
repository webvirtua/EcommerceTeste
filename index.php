<?php
session_start();
require_once("vendor/autoload.php");

use \Slim\Slim; //namespaces está escolhendo as classes 
use \Hcode\Page; //tem que ser declarado o namespace no inicio da página que esta a classe no caso é namespace Page no arquivo Page;
use \Hcode\PageAdmin;
use \Hcode\Model\User;
use \Hcode\Model\Category;

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

//criando as rotas do crud de usuário
//essa tela lista todos os usuário
$app->get('/admin/users', function(){
    User::verifyLogin();

    $users = User::listAll(); //lista todos os usuários

    $page = new PageAdmin(); 
    
    $page->setTpl("users", array(
        "users"=>$users
    ));
});

$app->get('/admin/users/create', function(){
    User::verifyLogin();
    
    $page = new PageAdmin(); 
    
    $page->setTpl("users-create");
});

//deletar precisa ser colocado antes
$app->get('/admin/users/:iduser/delete', function($iduser){ //vai salvar de fato
    User::verifyLogin();

    $user = new User();

    $user->get((int)$iduser);

    $user->delete();

    header("Location: /admin/users");
    exit();
});
//alterar
$app->get('/admin/users/:iduser', function($iduser){ //o valor que vier aqui $iduser vai receber :iduser
    User::verifyLogin();

    $user = new User();

    $user->get((int)$iduser);
    
    $page = new PageAdmin(); 
    
    $page->setTpl("users-update", array(
        "user"=>$user->getValues()
    ));
});

//se acessar via get vai responder com HTML se via set post vai fazer o insert dos dados a diferença entre as rotas é o método
$app->post('/admin/users/create', function(){ //vai salvar de fato
    User::verifyLogin();

    $user = new User();

    //definindo a permissão do admin
    $_POST["inadmin"] = (isset($_POST["inadmin"])) ? 1 : 0; // se foi definido o valor é 1 senão o valor é 0

    $user->setData($_POST);

    $user->save();

    header("Location: /admin/users");
    exit();
});

//update
$app->post('/admin/users/:iduser', function($iduser){ 
    User::verifyLogin();

    $user = new User();

    $_POST["inadmin"] = (isset($_POST["inadmin"])) ? 1 : 0; // se foi definido o valor é 1 senão o valor é 0

    $user->get((int)$iduser);

    $user->setData($_POST);

    $user->update();

    header("Location: /admin/users");
    exit();
});

//rotas esqueceu a senha e redefini��o
$app->get("/admin/forgot", function(){
    $page = new PageAdmin([ //para desabilitar o header e o footer
        "header"=>false,
        "footer"=>false
    ]);
    
    $page->setTpl("forgot");
});

$app->post("/admin/forgot", function(){
    $user = User::getForgot($_POST["email"]);
    
    header("Location: /admin/forgot/sent");
    exit;
});

$app->get("/admin/forgot/sent", function(){
    $page = new PageAdmin([ //para desabilitar o header e o footer
        "header"=>false,
        "footer"=>false
    ]);
    
    $page->setTpl("forgot-sent");
});

$app->get("/admin/forgot/reset", function(){
    //verificando o c�digo do email enviado pra recupera��o de senha
    $user = User::validForgotDecrypt($_GET["code"]);
    
    //rota
    $page = new PageAdmin([ //para desabilitar o header e o footer
        "header"=>false,
        "footer"=>false
    ]);
    
    $page->setTpl("forgot-reset", array(
        "name"=>$user["desperson"],
        "code"=>$_GET["code"]
    ));
});

$app->post("/admin/forgot/reset", function(){
    //verificando o c�digo do email enviado pra recupera��o de senha
    $forgot = User::validForgotDecrypt($_POST["code"]);
    
    //vai falar se esse processo de recupera��o j� foi usado e pra n�o recuperar de novo
    User::setForgotUsed($forgot["idrecovery"]);
    
    //agora vai realmente mudar a senha
    $user = new User();
    
    $user->get((int)$forgot["iduser"]);
    
    //criptografando a senha http://php.net/manual/pt_BR/function.password-hash.php
    $password = password_hash($_POST["password"], PASSWORD_DEFAULT, [
        "cost"=>8 //quantidade de processamento pra gerar a senha padr�o � 12
    ]);
    
    $user->setPassword($password); //vai salvar o hash dessa senha no banco
    
    //rota
    $page = new PageAdmin([ //para desabilitar o header e o footer
        "header"=>false,
        "footer"=>false
    ]);
    
    $page->setTpl("forgot-reset-success");
});

$app->get("/admin/categories", function(){
    User::verifyLogin();
    
    $categories = Category::listAll();
    
    $page = new PageAdmin();
    
    $page->setTpl("categories", [
        'categories'=>$categories
    ]);
});

$app->get("/admin/categories/create", function(){
    User::verifyLogin();
    
    $page = new PageAdmin();
    
    $page->setTpl("categories-create");
});

$app->post("/admin/categories/create", function(){
    User::verifyLogin();
    
    $category = new Category();
    
    $category->setData($_POST);
    
    $category->save();
    
    header("Location: /admin/categories");
    exit();
});

$app->get("/admin/categories/:idcategory/delete", function($idcategory){
    User::verifyLogin();
    
    $category = new Category();
    
    $category->get((int)$idcategory); //carrega
    
    $category->delete(); //deleta
    
    header("Location: /admin/categories"); //redireciona
    exit();
});

$app->get("/admin/categories/:idcategory", function($idcategory){
    User::verifyLogin();
    
    $category = new Category();
    
    $category->get($idcategory);
    
    $page = new PageAdmin();
    
    $page->setTpl("categories-update", [
        'category'=>$category->getValues()
    ]);
});

$app->post("/admin/categories/:idcategory", function($idcategory){
    User::verifyLogin();
    
    $category = new Category();
    
    $category->get($idcategory);
    
    $page = new PageAdmin();
    
    $category->setData($_POST);
    
    $category->save();
    
    header("Location: /admin/categories"); //redireciona
    exit();
});

$app->run(); //tudo carregado? roda o c�digo
?>


