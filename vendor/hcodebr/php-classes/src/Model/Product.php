<?php
namespace Hcode\Model;

use \Hcode\DB\Sql;
use \Hcode\Model;
use \Hcode\Mailer;

class Product extends Model{
    public static function listAll(){
        $sql = new Sql();
        
        return $sql->select("SELECT * FROM tb_products ORDER BY desproduct");
    }
    //lista de produtos na home
    public static function checkList($list){
        foreach($list as &$row){ //por causa do & alterou dentro do array list
            $p = new Product();
            $p->setData($row);
            $row = $p->getValues();
        }
        return $list;
    }
    
    public function save(){
        $sql = new Sql();
        
        $results = $sql->select("CALL sp_products_save(:idproduct, :desproduct, :vlprice, :vlwidth, :vlheight, :vllength, :vlweight, :desurl)", array( //chamada da procedure
            ":idproduct"=>$this->getidproduct(),
            ":desproduct"=>$this->getdesproduct(),
            ":vlprice"=>$this->getvlprice(),
            ":vlwidth"=>$this->getvlwidth(),
            ":vlheight"=>$this->getvlheight(),
            ":vllength"=>$this->getvllength(),
            ":vlweight"=>$this->getvlweight(),
            ":desurl"=>$this->getdesurl()
        ));
        
        $this->setData($results[0]);
    }
    
    public function get($idproduct){
        $sql = new Sql();
        
        $results = $sql->select("SELECT * FROM tb_products WHERE idproduct = :idproduct", [
            ':idproduct'=>$idproduct
        ]);
        
        $this->setData($results[0]);
    }
    
    public function delete(){
        $sql = new Sql();
        
        $sql->query("DELETE FROM tb_products WHERE idproduct = :idproduct", [
            ':idproduct'=>$this->getidproduct()
        ]);
    }
    
    public function checkPhoto(){
        if(file_exists(
            $_SERVER['DOCUMENT_ROOT'].DIRECTORY_SEPARATOR.
            "res".DIRECTORY_SEPARATOR.
            "site".DIRECTORY_SEPARATOR.
            "img".DIRECTORY_SEPARATOR.
            "products".DIRECTORY_SEPARATOR.
            $this->getidproduct().".jpg"
            ))
        {
            $url = "/res/site/img/products/".$this->getidproduct().".jpg";
        }else{
            $url = "/res/site/img/product.jpg";
        }
        
        return $this->setdesphoto($url);
    }
    
    public function getValues(){
        $this->checkPhoto();
        
        $values = parent::getValues(); //parente pegando da classe pai
        
        return $values;
    }
    //upload da imagem
    public function setPhoto($file){
        $extension = explode('.', $file['name']); //explode transforma string em array
        $extension = end($extension);
        
        switch($extension){
            case "jpg";
            case "jpeg";
            $image = imagecreatefromjpeg($file["tmp_name"]);
            break;
            
            case "gif";
            $image = imagecreatefromgif($file["tmp_name"]);
            break;
            
            case "png";
            $image = imagecreatefrompng($file["tmp_name"]);
            break;
        }
        $dist = $_SERVER['DOCUMENT_ROOT'].DIRECTORY_SEPARATOR.
            "res".DIRECTORY_SEPARATOR.
            "site".DIRECTORY_SEPARATOR.
            "img".DIRECTORY_SEPARATOR.
            "products".DIRECTORY_SEPARATOR.
            $this->getidproduct().".jpg";
        
        imagejpeg($image, $dist);
        
        imagedestroy($image);
        
        $this->checkPhoto();
    }
    //detalhes do produto
    public function getFromUrl($desurl){
        $sql = new Sql();
        
        $rows = $sql->select("SELECT * FROM tb_products WHERE desurl = :desurl LIMIT 1", [
            ':desurl'=>$desurl //bind
        ]);
        
        $this->setData($rows[0]);
    }
    
    public function getCategories(){
        $sql = new Sql();
        
        return $sql->select("SELECT * FROM tb_categories a INNER JOIN tb_productscategories b ON a.idcategory = b.idcategory WHERE b.idproduct = :idproduct", [
            ':idproduct'=>$this->getidproduct()
        ]);
    }
}
?>
