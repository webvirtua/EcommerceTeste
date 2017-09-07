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
 }
 ?>
