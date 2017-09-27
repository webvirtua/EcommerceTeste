<?php
use \Hcode\PageAdmin;
use \Hcode\Model\User;

//rotas refer�ntes a administra��o de usu�rios

//criando as rotas do crud de usuário
//essa tela lista todos os usuário
$app->get('/admin/users', function(){
    User::verifyLogin();

    $search = (isset($_GET['search'])) ? $_GET['search'] : "";
    $page = (isset($_GET['page'])) ? (int)$_GET['page'] : 1;

    if($search != ''){
        $pagination = User::getPageSearch($search, $page); //lista 4 usuários por página
    }else{
        $pagination = User::getPage($page); //lista 4 usuários por página
    }

    $pages = [];
    for($x = 0; $x < $pagination['pages']; $x++){
        array_push($pages, [
            'href'=>'/admin/users?'.http_build_query([
                'page'=>$x+1,
                'search'=>$search
            ]),
            'text'=>$x+1
        ]);
    }
    
    $page = new PageAdmin();
    
    $page->setTpl("users", array(
        "users"=>$pagination['data'],
        "search"=>$search,
        "pages"=>$pages
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
?>