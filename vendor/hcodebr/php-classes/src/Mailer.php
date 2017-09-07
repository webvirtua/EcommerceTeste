<?php
namespace Hcode;

use Rain\Tpl;
//Import the PHPMailer class into the global namespace
use PHPMailer\PHPMailer\PHPMailer;

//envia email de recuperaзгo de senha
class Mailer{
    const USERNAME = "bbb@galeria44.com.br";
    const PASSWORD = "123456789";
    const NAME_FROM = "Hcode Store";
    
    private $mail;
    
    public function __construct($toAddress, $toName, $subject, $tplName, $data = array()){ 
        // configuraзгo do template do email
        $config = array(
            "tpl_dir"   => $_SERVER["DOCUMENT_ROOT"]."/views/email/", //$_SERVER["DOCUMENT_ROOT"] vai trazer onde esta a pasta o diretуrio root
            "cache_dir" => $_SERVER["DOCUMENT_ROOT"]."/views-cache/",
            "debug"     => true // set to false to improve the speed
        );
        
        Tpl::configure($config);
        
        $tpl = new Tpl();
        
        foreach($data as $key => $value){
            $tpl->assign($key, $value);
        }
            
        $html = $tpl->draw($tplName, true); //true pra jogar na variбvel e nгo jogar na tela
        
        //SMTP needs accurate times, and the PHP time zone MUST be set
        //This should be done in your php.ini, but this is how to do it if you don't have access to that
        date_default_timezone_set('Etc/UTC');
        
        //Create a new PHPMailer instance
        $this->mail = new \PHPMailer; //PHPMailer estб no escopo principal e tem que colocar \
        //Tell PHPMailer to use SMTP
        $this->mail->isSMTP();
        //Enable SMTP debugging
        // 0 = off (for production use)
        // 1 = client messages
        // 2 = client and server messages
        $this->mail->SMTPDebug = 0; //0 nгo dб as mensagem de log do envio do email, pra aparecer todas as mensagem coloque 2
        //Set the hostname of the mail server
        $this->mail->Host = 'mail.galeria44.com.br';
        //Set the SMTP port number - likely to be 25, 465 or 587
        $this->mail->Port = 587;
        //Whether to use SMTP authentication
        $this->mail->SMTPAuth = true;
        //Username to use for SMTP authentication
        $this->mail->Username = Mailer::USERNAME; //NESTE PROJETO USAR UMA CONSTANTE pra se precisar mudar o email que й utilizado pra enviar pelo sistema
        //Password to use for SMTP authentication
        $this->mail->Password = Mailer::PASSWORD;
        //Set who the message is to be sent from
        $this->mail->setFrom(Mailer::USERNAME, Mailer::NAME_FROM); //quem envia
        //Set an alternative reply-to address
        $this->mail->addReplyTo('atende@webvirtua.com.br', 'Web Virtua'); //email que recebe a resposta
        //Set who the message is to be sent to
        $this->mail->addAddress($toAddress, $toName); //quem recebe o email
        //Set the subject line
        $this->mail->Subject = $subject; //assunto
        //Read an HTML message body from an external file, convert referenced images to embedded,
        //convert HTML into a basic plain-text alternative body
        $this->mail->msgHTML($html); //HTML a ser enviado no corpo do email
        //Replace the plain text body with one created manually
        $this->mail->AltBody = 'This is a plain-text message body';
        //Attach an image file
        $this->mail->addAttachment('images/phpmailer_mini.png');
    }
    
    public function send(){ //podemos enviar o email quando quisermos
        return $this->mail->send();
    }
}

?>