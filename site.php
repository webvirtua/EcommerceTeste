<?php
use \Hcode\Page; //tem que ser declarado o namespace no inicio da pï¿½gina que esta a classe no caso ï¿½ namespace Page no arquivo Page;
use \Hcode\Model\Product;
use \Hcode\Model\Category;
use \Hcode\Model\Cart;
use \Hcode\Model\Address;
use Hcode\Model\User;

//rotas referï¿½ntes ao site aberto

$app->get('/', function(){ //aqui mostra qual rota estou chamando
    $products = Product::listAll();
    
    $page = new Page();
    
    $page->setTpl("index", [
        'products'=>Product::checkList($products)
    ]);
    
    //aqui jï¿½ chama o mï¿½todo destruct limpando a memï¿½ria como footer
});

$app->get("/categories/:idcategory", function($idcategory){
    $page = (isset($_GET['page'])) ? (int)$_GET['page'] : 1;
    
    $category = new Category();
    
    $category->get((int)$idcategory);
    
    $pagination = $category->getProductsPage($page);
    
    $pages = [];
    
    for($i = 1; $i <= $pagination['pages']; $i++){
        array_push($pages, [
            'link'=>'/categories/'.$category->getidcategory().'?page='.$i,
            'page'=>$i
        ]);
    }
    
    $page = new Page();
    
    $page->setTpl("category", [
        'category'=>$category->getValues(),
        'products'=>$pagination["data"],
        'pages'=>$pages
    ]);
});

$app->get("/products/:desurl", function($desurl){
    $product = new Product();
    
    $product->getFromUrl($desurl);
    
    $page = new Page();
    
    $page->setTpl("product-detail", [
        'product'=>$product->getValues(),
        'categories'=>$product->getCategories()
    ]);
});

$app->get("/cart", function(){
    $cart = Cart::getFromSession();
    
    $page = new Page();

    $page->setTpl("cart", [
        'cart'=>$cart->getValues(),
        'products'=>$cart->getProducts(),
        'error'=>Cart::getMsgError()
    ]);
    
});

$app->get("/cart/:idproduct/add", function($idproduct){
    $product = new Product();
    
    $product->get((int)$idproduct);
    
    $cart = Cart::getFromSession();
    
    $qtd = (isset($_GET['qtd'])) ? (int)$_GET['qtd'] : 1; //add produto nos detalhes
    for($i = 0; $i < $qtd; $i++){
        $cart->addProduct($product);
    }

    header("Location: /cart");
    exit();
});

$app->get("/cart/:idproduct/minus", function($idproduct){
    $product = new Product();
    
    $product->get((int)$idproduct);
    
    $cart = Cart::getFromSession();
    
    $cart->removeProduct($product);
    
    header("Location: /cart");
    exit();
});

$app->get("/cart/:idproduct/remove", function($idproduct){
    $product = new Product();
    
    $product->get((int)$idproduct);
    
    $cart = Cart::getFromSession();
    
    $cart->removeProduct($product, true);
    
    header("Location: /cart");
    exit();
});

$app->post("/cart/freight", function(){
   $cart = Cart::getFromSession();

   $cart->setFreight($_POST['zipcode']);

   header("Location: /cart");
   exit();
});

$app->get("/checkout", function(){
    //verifica se o usuário está logado
    User::verifyLogin(false);
    
    $cart = Cart::getFromSession();
    
    $address = new Address();
    
    $page = new Page();
    
    $page->setTpl("checkout", [
        'cart'=>$cart->getValues(),
        'address'=>$address->getValues()
    ]);
});

$app->get("/login", function(){
    $page = new Page();
    
    $page->setTpl("login", [
        'error'=>User::getError()
    ]);
});

$app->post("/login", function(){
    try{
        User::login($_POST['login'], $_POST['password']);
    }catch (Exception $e){
        User::setError($e->getMessage());
    }
    
    header("Location: /checkout");
    exit();
});

$app->get("/logout", function(){
    User::logout();
    
    header("Location: /login");
    exit();
});
?>