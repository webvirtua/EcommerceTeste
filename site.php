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
    $category = new Category();
    
    $category->get((int)$idcategory);
    
    $page = new Page();
    
    $page->setTpl("category", [
        'category'=>$category->getValues(),
        'products'=>Product::checkList($category->getProducts())
    ]);
});
?>