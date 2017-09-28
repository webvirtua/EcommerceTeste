<?php
 namespace Hcode\Model;
 
 use \Hcode\DB\Sql;
 use \Hcode\Model;
 use \Hcode\Mailer;
 
 class Category extends Model{
     public static function listAll(){
         $sql = new Sql();
         
         return $sql->select("SELECT * FROM tb_categories ORDER BY descategory");
     }  
     
     public function save(){
         $sql = new Sql();
         
         $results = $sql->select("CALL sp_categories_save(:idcategory, :descategory)", array( //chamada da procedure
             ":idcategory"=>$this->getidcategory(),
             ":descategory"=>$this->getdescategory()
         ));
         
         $this->setData($results[0]);
         
         Category::updateFile(); //quando houver um delete ele refaz o arquivo categories-menu.html
     }
     
     public function get($idcategory){
         $sql = new Sql();
         
         $results = $sql->select("SELECT * FROM tb_categories WHERE idcategory = :idcategory", [
             ':idcategory'=>$idcategory
         ]);
         
         $this->setData($results[0]);
     }
     
     public function delete(){
         $sql = new Sql();
         
         $sql->query("DELETE FROM tb_categories WHERE idcategory = :idcategory", [
             ':idcategory'=>$this->getidcategory()
         ]);
         
         Category::updateFile(); //quando houver um delete ele refaz o arquivo categories-menu.html
     }
     //atualizar as categorias quando alterar ou deletar uma categoria ele refaz o arquivo html 
     public static function updateFile(){
         $categories = Category::listAll();
         
         $html = [];
         
         foreach($categories as $row){
             array_push($html, '<li><a href="/categories/'.$row['idcategory'].'">'.$row['descategory'].'</a></li>');
         }
             
         file_put_contents($_SERVER['DOCUMENT_ROOT'].DIRECTORY_SEPARATOR."views".DIRECTORY_SEPARATOR."categories-menu.html", implode('', $html)); //implode vai trandormar a vari�vel $html que � array em string, e o explode � string pra array
     }
     
     public function getProducts($related = true){
         $sql = new Sql();
         
         if($related === true){
             return $sql->select("
                SELECT * FROM tb_products WHERE idproduct IN(
	               SELECT a.idproduct FROM tb_products a INNER JOIN tb_productscategories b ON a.idproduct = b.idproduct WHERE b.idcategory = :idcategory
                );
             ", [
                 ':idcategory'=>$this->getidcategory()
             ]);
         }else{
             return $sql->select("
                SELECT * FROM tb_products WHERE idproduct NOT IN(
	               SELECT a.idproduct FROM tb_products a INNER JOIN tb_productscategories b ON a.idproduct = b.idproduct WHERE b.idcategory = :idcategory
                );
             ", [
                 ':idcategory'=>$this->getidcategory()
             ]);
         }
     }
     //pagina��o
     public function getProductsPage($page = 1, $itemsPerPage = 3){
         $start = ($page - 1) * $itemsPerPage; //primeira pagina come�a no zero
         
         $sql = new Sql();
         
         $results = $sql->select("
            SELECT SQL_CALC_FOUND_ROWS *
            FROM tb_products a # SQL_CALC_FOUND_ROWS conta as linhas
            INNER JOIN tb_productscategories b ON a.idproduct = b.idproduct 
            INNER JOIN tb_categories c ON c.idcategory = b.idcategory 
            WHERE c.idcategory = :idcategory 
            LIMIT $start, $itemsPerPage; # usando 2 parametro no limit, primeiro a parte de que numero come�a a contar, e depois quantos resultados exibir�
         ", [
             ':idcategory'=>$this->getidcategory()
         ]);
         
         $resultTotal = $sql->select("SELECT FOUND_ROWS() AS nrtotal;");
         
         return [
             'data'=>Product::checkList($results),
             'total'=>(int)$resultTotal[0]["nrtotal"],
             'pages'=>ceil($resultTotal[0]["nrtotal"] / $itemsPerPage) //conta quantas paginas tem resultados
         ];
     }
     
     public function addProduct(Product $product){
         $sql = new Sql();
         
         $sql->query("INSERT INTO tb_productscategories (idcategory, idproduct) VALUES(:idcategory, :idproduct)", [
             ':idcategory'=>$this->getidcategory(),
             ':idproduct'=>$product->getidproduct()
         ]);
     }
     
     public function removeProduct(Product $product){
         $sql = new Sql();
         
         $sql->query("DELETE FROM tb_productscategories WHERE idcategory = :idcategory AND idproduct :idproduct", [
             ':idcategory'=>$this->getidcategory(),
             ':idproduct'=>$product->getidproduct()
         ]);
     }

     //paginação
     public static function getPage($page = 1, $itemsPerPage = 10){
         $start = ($page - 1) * $itemsPerPage; //primeira pagina come�a no zero

         $sql = new Sql();

         $results = $sql->select("
            SELECT SQL_CALC_FOUND_ROWS *
            FROM tb_categories 
            ORDER BY descategory
            LIMIT $start, $itemsPerPage;
        ");

         $resultTotal = $sql->select("SELECT FOUND_ROWS() AS nrtotal;");

         return [
             'data'=>$results,
             'total'=>(int)$resultTotal[0]["nrtotal"],
             'pages'=>ceil($resultTotal[0]["nrtotal"] / $itemsPerPage) //conta quantas paginas tem resultados
         ];
     }

     public static function getPageSearch($search, $page = 1, $itemsPerPage = 10){
         $start = ($page - 1) * $itemsPerPage; //primeira pagina come�a no zero

         $sql = new Sql();

         $results = $sql->select("
            SELECT SQL_CALC_FOUND_ROWS *
            FROM tb_categories             
            WHERE descategory LIKE :search
            ORDER BY descategory
            LIMIT $start, $itemsPerPage;
        ", [
             ':search'=>'%'.$search.'%'
         ]);

         $resultTotal = $sql->select("SELECT FOUND_ROWS() AS nrtotal;");

         return [
             'data'=>$results,
             'total'=>(int)$resultTotal[0]["nrtotal"],
             'pages'=>ceil($resultTotal[0]["nrtotal"] / $itemsPerPage) //conta quantas paginas tem resultados
         ];
     }
 }
 ?>
