<?php
use \Hcode\Page; //tem que ser declarado o namespace no inicio da p�gina que esta a classe no caso � namespace Page no arquivo Page;
use \Hcode\Model\Product;
//rotas refer�ntes ao site aberto

$app->get('/', function(){ //aqui mostra qual rota estou chamando
    $products = Product::listAll();
    
    $page = new Page();
    
    $page->setTpl("index", [
        'products'=>Product::checkList($products)
    ]);
    
    //aqui j� chama o m�todo destruct limpando a mem�ria como footer
});
?>