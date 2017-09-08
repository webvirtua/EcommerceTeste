<?php
//use \Hcode\Page; //tem que ser declarado o namespace no inicio da p�gina que esta a classe no caso � namespace Page no arquivo Page;
use \Hcode\PageAdmin;
use \Hcode\Model\User;

//rotas refer�ntes a parte de administra��o

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
            
//rotas esqueceu a senha e redefini��o ============================
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
?>