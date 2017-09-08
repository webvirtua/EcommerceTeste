<?php
use \Hcode\Page; //tem que ser declarado o namespace no inicio da página que esta a classe no caso é namespace Page no arquivo Page;

//rotas referêntes ao site aberto

$app->get('/', function(){ //aqui mostra qual rota estou chamando
    $page = new Page();
    
    $page->setTpl("index");
    
    //aqui jÃ¡ chama o mÃ©todo destruct limpando a memÃ©ria como footer
});
?>