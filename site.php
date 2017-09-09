<?php
use \Hcode\Page; //tem que ser declarado o namespace no inicio da página que esta a classe no caso é namespace Page no arquivo Page;
use \Hcode\Model\Product;
//rotas referêntes ao site aberto

$app->get('/', function(){ //aqui mostra qual rota estou chamando
    $products = Product::listAll();
    
    $page = new Page();
    
    $page->setTpl("index", [
        'products'=>Product::checkList($products)
    ]);
    
    //aqui já chama o método destruct limpando a memória como footer
});
?>