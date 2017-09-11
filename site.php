<?php
use \Hcode\Page; //tem que ser declarado o namespace no inicio da página que esta a classe no caso é namespace Page no arquivo Page;
use \Hcode\Model\Product;
use \Hcode\Model\Category;

//rotas referêntes ao site aberto

$app->get('/', function(){ //aqui mostra qual rota estou chamando
    $products = Product::listAll();
    
    $page = new Page();
    
    $page->setTpl("index", [
        'products'=>Product::checkList($products)
    ]);
    
    //aqui já chama o método destruct limpando a memória como footer
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
?>