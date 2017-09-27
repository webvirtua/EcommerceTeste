-- phpMyAdmin SQL Dump
-- version 4.7.0
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: 22-Set-2017 às 23:57
-- Versão do servidor: 10.1.26-MariaDB
-- PHP Version: 7.1.8

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `db_ecommerce`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_addresses_save` (`pidaddress` INT(11), `pidperson` INT(11), `pdesaddress` VARCHAR(128), `pdescomplement` VARCHAR(32), `pdescity` VARCHAR(32), `pdesstate` VARCHAR(32), `pdescountry` VARCHAR(32), `pdeszipcode` CHAR(8), `pdesdistrict` VARCHAR(32))  BEGIN

	IF pidaddress > 0 THEN
		
		UPDATE tb_addresses
        SET
			idperson = pidperson,
            desaddress = pdesaddress,
            descomplement = pdescomplement,
            descity = pdescity,
            desstate = pdesstate,
            descountry = pdescountry,
            deszipcode = pdeszipcode, 
            desdistrict = pdesdistrict
		WHERE idaddress = pidaddress;
        
    ELSE
		
		INSERT INTO tb_addresses (idperson, desaddress, descomplement, descity, desstate, descountry, deszipcode, desdistrict)
        VALUES(pidperson, pdesaddress, pdescomplement, pdescity, pdesstate, pdescountry, pdeszipcode, pdesdistrict);
        
        SET pidaddress = LAST_INSERT_ID();
        
    END IF;
    
    SELECT * FROM tb_addresses WHERE idaddress = pidaddress;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_carts_save` (`pidcart` INT, `pdessessionid` VARCHAR(64), `piduser` INT, `pdeszipcode` CHAR(8), `pvlfreight` DECIMAL(10,2), `pnrdays` INT)  BEGIN

    IF pidcart > 0 THEN
        
        UPDATE tb_carts
        SET
            dessessionid = pdessessionid,
            iduser = piduser,
            deszipcode = pdeszipcode,
            vlfreight = pvlfreight,
            nrdays = pnrdays
        WHERE idcart = pidcart;
        
    ELSE
        
        INSERT INTO tb_carts (dessessionid, iduser, deszipcode, vlfreight, nrdays)
        VALUES(pdessessionid, piduser, pdeszipcode, pvlfreight, pnrdays);
        
        SET pidcart = LAST_INSERT_ID();
        
    END IF;
    
    SELECT * FROM tb_carts WHERE idcart = pidcart;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_categories_save` (`pidcategory` INT, `pdescategory` VARCHAR(64))  BEGIN
	
	IF pidcategory > 0 THEN
		
		UPDATE tb_categories
        SET descategory = pdescategory
        WHERE idcategory = pidcategory;
        
    ELSE
		
		INSERT INTO tb_categories (descategory) VALUES(pdescategory);
        
        SET pidcategory = LAST_INSERT_ID();
        
    END IF;
    
    SELECT * FROM tb_categories WHERE idcategory = pidcategory;
    
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_orders_save` (`pidorder` INT, `pidcart` INT(11), `piduser` INT(11), `pidstatus` INT(11), `pidaddress` INT(11), `pvltotal` DECIMAL(10,2))  BEGIN
	
	IF pidorder > 0 THEN
		
		UPDATE tb_orders
        SET
			idcart = pidcart,
            iduser = piduser,
            idstatus = pidstatus,
            idaddress = pidaddress,
            vltotal = pvltotal
		WHERE idorder = pidorder;
        
    ELSE
    
		INSERT INTO tb_orders (idcart, iduser, idstatus, idaddress, vltotal)
        VALUES(pidcart, piduser, pidstatus, pidaddress, pvltotal);
		
		SET pidorder = LAST_INSERT_ID();
        
    END IF;
    
    SELECT * 
    FROM tb_orders a
    INNER JOIN tb_ordersstatus b USING(idstatus)
    INNER JOIN tb_carts c USING(idcart)
    INNER JOIN tb_users d ON d.iduser = a.iduser
    INNER JOIN tb_addresses e USING(idaddress)
    WHERE idorder = pidorder;
    
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_products_save` (`pidproduct` INT(11), `pdesproduct` VARCHAR(64), `pvlprice` DECIMAL(10,2), `pvlwidth` DECIMAL(10,2), `pvlheight` DECIMAL(10,2), `pvllength` DECIMAL(10,2), `pvlweight` DECIMAL(10,2), `pdesurl` VARCHAR(128))  BEGIN
	
	IF pidproduct > 0 THEN
		
		UPDATE tb_products
        SET 
			desproduct = pdesproduct,
            vlprice = pvlprice,
            vlwidth = pvlwidth,
            vlheight = pvlheight,
            vllength = pvllength,
            vlweight = pvlweight,
            desurl = pdesurl
        WHERE idproduct = pidproduct;
        
    ELSE
		
		INSERT INTO tb_products (desproduct, vlprice, vlwidth, vlheight, vllength, vlweight, desurl) 
        VALUES(pdesproduct, pvlprice, pvlwidth, pvlheight, pvllength, pvlweight, pdesurl);
        
        SET pidproduct = LAST_INSERT_ID();
        
    END IF;
    
    SELECT * FROM tb_products WHERE idproduct = pidproduct;
    
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_userspasswordsrecoveries_create` (`piduser` INT, `pdesip` VARCHAR(45))  BEGIN
	
	INSERT INTO tb_userspasswordsrecoveries (iduser, desip)
    VALUES(piduser, pdesip);
    
    SELECT * FROM tb_userspasswordsrecoveries
    WHERE idrecovery = LAST_INSERT_ID();
    
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_usersupdate_save` (`piduser` INT, `pdesperson` VARCHAR(64), `pdeslogin` VARCHAR(64), `pdespassword` VARCHAR(256), `pdesemail` VARCHAR(128), `pnrphone` BIGINT, `pinadmin` TINYINT)  BEGIN
	
    DECLARE vidperson INT;
    
	SELECT idperson INTO vidperson
    FROM tb_users
    WHERE iduser = piduser;
    
    UPDATE tb_persons
    SET 
		desperson = pdesperson,
        desemail = pdesemail,
        nrphone = pnrphone
	WHERE idperson = vidperson;
    
    UPDATE tb_users
    SET
		deslogin = pdeslogin,
        despassword = pdespassword,
        inadmin = pinadmin
	WHERE iduser = piduser;
    
    SELECT * FROM tb_users a INNER JOIN tb_persons b USING(idperson) WHERE a.iduser = piduser;
    
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_users_delete` (`piduser` INT)  BEGIN
	
    DECLARE vidperson INT;
    
	SELECT idperson INTO vidperson
    FROM tb_users
    WHERE iduser = piduser;
    
    DELETE FROM tb_users WHERE iduser = piduser;
    DELETE FROM tb_persons WHERE idperson = vidperson;
    
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_users_save` (`pdesperson` VARCHAR(64), `pdeslogin` VARCHAR(64), `pdespassword` VARCHAR(256), `pdesemail` VARCHAR(128), `pnrphone` BIGINT, `pinadmin` TINYINT)  BEGIN
	
    DECLARE vidperson INT;
    
	INSERT INTO tb_persons (desperson, desemail, nrphone)
    VALUES(pdesperson, pdesemail, pnrphone);
    
    SET vidperson = LAST_INSERT_ID();
    
    INSERT INTO tb_users (idperson, deslogin, despassword, inadmin)
    VALUES(vidperson, pdeslogin, pdespassword, pinadmin);
    
    SELECT * FROM tb_users a INNER JOIN tb_persons b USING(idperson) WHERE a.iduser = LAST_INSERT_ID();
    
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura da tabela `tb_addresses`
--

CREATE TABLE `tb_addresses` (
  `idaddress` int(11) NOT NULL,
  `idperson` int(11) NOT NULL,
  `desaddress` varchar(128) NOT NULL,
  `descomplement` varchar(32) DEFAULT NULL,
  `descity` varchar(32) NOT NULL,
  `desstate` varchar(32) NOT NULL,
  `descountry` varchar(32) NOT NULL,
  `deszipcode` char(8) NOT NULL,
  `desdistrict` varchar(32) NOT NULL,
  `dtregister` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Extraindo dados da tabela `tb_addresses`
--

INSERT INTO `tb_addresses` (`idaddress`, `idperson`, `desaddress`, `descomplement`, `descity`, `desstate`, `descountry`, `deszipcode`, `desdistrict`, `dtregister`) VALUES
(1, 18, 'Rua Ceará', 'Qd 5, lt 10', 'Uberlândia', 'MG', 'Brasil', '38405240', 'Custódio Pereira', '2017-09-18 13:16:26'),
(11, 18, 'Avenida Paulista', 'de 612 a 1510 - lado par', 'São Paulo', 'SP', 'Brasil', '01310100', 'Bela Vista', '2017-09-18 15:20:52'),
(13, 18, 'Rua Irmã Alice Bitar', 'Qd 5, lt 10', 'Goiânia', 'GO', 'Brasil', '74494745', 'Jardim São José', '2017-09-18 15:24:30'),
(16, 18, 'Avenida Paulista', 'de 612 a 1510 - lado par', 'São Paulo', 'SP', 'Brasil', '01310100', 'Bela Vista', '2017-09-18 20:38:21'),
(17, 18, 'Avenida Paulista', 'de 612 a 1510 - lado par', 'São Paulo', 'SP', 'Brasil', '01310100', 'Bela Vista', '2017-09-18 21:32:14'),
(18, 18, 'Avenida Paulista', 'de 612 a 1510 - lado par', 'São Paulo', 'SP', 'Brasil', '01310100', 'Bela Vista', '2017-09-18 21:33:52'),
(19, 18, 'Avenida Paulista', 'de 612 a 1510 - lado par', 'São Paulo', 'SP', 'Brasil', '01310100', 'Bela Vista', '2017-09-18 23:13:19'),
(20, 18, 'Rua Ceará', 'Qd 5, lt 10', 'Uberlândia', 'MG', 'Brasil', '38405240', 'Custódio Pereira', '2017-09-19 11:41:02'),
(21, 18, 'Rua Irmã Alice Bitar', 'Qd 5, lt 10', 'Goiânia', 'GO', 'Brasil', '74494745', 'Jardim São José', '2017-09-19 11:47:22'),
(22, 18, 'Rua Irmã Alice Bitar', 'Qd 5, lt 10', 'Goiânia', 'GO', 'Brasil', '74494745', 'Jardim São José', '2017-09-19 11:49:16'),
(23, 18, 'Avenida Paulista', 'de 612 a 1510 - lado par', 'São Paulo', 'SP', 'Brasil', '01310100', 'Bela Vista', '2017-09-19 11:50:56'),
(24, 18, 'Rua Ceará', 'Qd 5, lt 10', 'Uberlândia', 'MG', 'Brasil', '38405240', 'Custódio Pereira', '2017-09-19 11:52:40'),
(25, 18, 'Rua Irmã Alice Bitar', 'Qd. 41, Lt. 24', 'Goiânia', 'GO', 'Brasil', '74494745', 'Jardim São José', '2017-09-19 11:53:29'),
(26, 18, 'Avenida Central', 'Qd 5, lt 10', 'Goiânia', 'GO', 'Brasil', '74465100', 'Jardim Nova Esperança', '2017-09-19 11:54:53'),
(27, 18, 'Rua 29-A', 'rua 20', 'Goiânia', 'GO', 'Brasil', '74015060', 'Setor Central', '2017-09-19 11:55:42'),
(28, 18, 'Rua Pedro II', 'Qd 5, lt 10', 'Goiânia', 'GO', 'Brasil', '74483460', 'Parque João Braz - Cidade Indust', '2017-09-19 11:57:05');

-- --------------------------------------------------------

--
-- Estrutura da tabela `tb_carts`
--

CREATE TABLE `tb_carts` (
  `idcart` int(11) NOT NULL,
  `dessessionid` varchar(64) NOT NULL,
  `iduser` int(11) DEFAULT NULL,
  `deszipcode` char(8) DEFAULT NULL,
  `vlfreight` decimal(10,2) DEFAULT NULL,
  `nrdays` int(11) DEFAULT NULL,
  `dtregister` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Extraindo dados da tabela `tb_carts`
--

INSERT INTO `tb_carts` (`idcart`, `dessessionid`, `iduser`, `deszipcode`, `vlfreight`, `nrdays`, `dtregister`) VALUES
(1, 'uv528k0hbu0cq7dl2hqp9lr443', NULL, NULL, NULL, NULL, '2017-09-11 21:12:40'),
(2, '639sb7irt99p3822p9060ep7tc', NULL, NULL, NULL, NULL, '2017-09-12 11:54:21'),
(3, 'jo4ko9q98j6dh5n2ovfini5nt7', NULL, NULL, NULL, NULL, '2017-09-13 17:35:18'),
(4, 'efusvq9gdt2sb4n2agvfvpol9b', NULL, NULL, NULL, NULL, '2017-09-14 10:50:45'),
(5, 'theb0s79epajnutmepdlq1hqrb', NULL, '74494745', '0.00', 0, '2017-09-14 11:18:40'),
(6, 'rph1a2o2qa7q9hstnhku1rulsg', NULL, NULL, NULL, NULL, '2017-09-14 14:57:12'),
(7, 'vqn58rm4v4svo3skvc64nc7b0n', NULL, '74494745', '96.91', 2, '2017-09-14 14:59:33'),
(8, 'pltgja8r795i4nm1f4chmt6gbe', NULL, '74494745', '0.00', 0, '2017-09-14 15:28:15'),
(9, '2sdeeje5aqe7c7ut80v63fdg9r', NULL, '22041080', '79.24', 2, '2017-09-14 18:19:04'),
(10, 'rd7m4o8m9jndilp9q0kb7hfb8l', NULL, '74494745', '53.28', 2, '2017-09-14 18:36:44'),
(11, 'n33op62p5h64ol7tfms9fqt1bs', NULL, '74494745', '72.51', 2, '2017-09-15 11:27:56'),
(12, '3gkbvv0mcqvre2n8dejinbhk8o', NULL, '74494745', '56.65', 2, '2017-09-15 13:08:07'),
(13, '7rvg07dug1ebqthdv8ib1uc9r7', 18, '74494745', '125.22', 2, '2017-09-15 22:24:20'),
(14, 'uo8934uk3b1vprhibm626a6gsl', 18, '74494745', '64.57', 2, '2017-09-16 11:16:57'),
(15, 'q2j9ma40rchln08pjho9reofe2', NULL, '74494745', '78.33', 2, '2017-09-16 12:37:05'),
(16, '4tl7lfs8k5diq2jo3r8vhb8nja', 18, '74494745', '92.88', 2, '2017-09-18 13:08:57'),
(17, '6jgauqcn2sums19a0cumnh5npn', 18, '01310100', '67.44', 1, '2017-09-18 20:37:28'),
(18, 'hslloh8ai5ndahi49ilg8cgsfg', NULL, '74483460', '93.91', 2, '2017-09-19 11:40:17'),
(19, '0r2lmjvbq4frujlihj9dgrncps', NULL, NULL, NULL, NULL, '2017-09-19 12:40:57'),
(20, 'g839s45pur7urr0qp4d7qj6i2n', NULL, NULL, NULL, NULL, '2017-09-22 00:37:57'),
(21, 'o3cuo0vcrrbv9tvvtm0o3j2vst', NULL, NULL, NULL, NULL, '2017-09-22 19:48:41');

-- --------------------------------------------------------

--
-- Estrutura da tabela `tb_cartsproducts`
--

CREATE TABLE `tb_cartsproducts` (
  `idcartproduct` int(11) NOT NULL,
  `idcart` int(11) NOT NULL,
  `idproduct` int(11) NOT NULL,
  `dtremoved` datetime DEFAULT NULL,
  `dtregister` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Extraindo dados da tabela `tb_cartsproducts`
--

INSERT INTO `tb_cartsproducts` (`idcartproduct`, `idcart`, `idproduct`, `dtremoved`, `dtregister`) VALUES
(1, 2, 6, '0000-00-00 00:00:00', '2017-09-13 14:07:39'),
(2, 2, 8, '0000-00-00 00:00:00', '2017-09-13 14:08:17'),
(3, 2, 9, NULL, '2017-09-13 14:12:05'),
(4, 2, 5, NULL, '2017-09-13 14:24:33'),
(5, 2, 9, NULL, '2017-09-13 15:27:53'),
(6, 2, 9, NULL, '2017-09-13 15:27:53'),
(7, 2, 9, NULL, '2017-09-13 15:27:54'),
(8, 3, 9, NULL, '2017-09-13 20:40:58'),
(9, 3, 9, NULL, '2017-09-13 20:41:01'),
(10, 3, 9, NULL, '2017-09-13 20:41:04'),
(11, 3, 7, NULL, '2017-09-13 20:41:16'),
(12, 3, 7, NULL, '2017-09-13 20:41:16'),
(13, 3, 7, NULL, '2017-09-13 20:41:16'),
(14, 3, 7, NULL, '2017-09-13 20:41:16'),
(15, 5, 6, NULL, '2017-09-14 13:02:53'),
(16, 5, 6, NULL, '2017-09-14 13:03:47'),
(17, 5, 6, NULL, '2017-09-14 13:04:16'),
(18, 5, 6, NULL, '2017-09-14 13:04:18'),
(19, 5, 6, NULL, '2017-09-14 13:04:21'),
(20, 5, 6, NULL, '2017-09-14 14:35:35'),
(21, 5, 6, NULL, '2017-09-14 14:41:15'),
(22, 5, 6, NULL, '2017-09-14 14:41:17'),
(23, 5, 6, NULL, '2017-09-14 14:42:44'),
(24, 5, 6, NULL, '2017-09-14 14:42:46'),
(25, 5, 6, NULL, '2017-09-14 14:42:49'),
(26, 5, 6, NULL, '2017-09-14 14:55:32'),
(27, 5, 6, NULL, '2017-09-14 14:55:33'),
(28, 6, 9, NULL, '2017-09-14 14:57:57'),
(29, 7, 7, NULL, '2017-09-14 14:59:42'),
(30, 7, 7, NULL, '2017-09-14 14:59:45'),
(31, 7, 7, NULL, '2017-09-14 14:59:47'),
(32, 7, 7, NULL, '2017-09-14 15:22:55'),
(33, 7, 7, NULL, '2017-09-14 15:22:56'),
(34, 7, 7, NULL, '2017-09-14 15:22:57'),
(35, 7, 7, NULL, '2017-09-14 15:22:57'),
(36, 7, 7, NULL, '2017-09-14 15:23:23'),
(37, 7, 7, NULL, '2017-09-14 15:23:25'),
(38, 8, 9, NULL, '2017-09-14 15:28:22'),
(39, 8, 9, NULL, '2017-09-14 15:28:32'),
(40, 8, 9, NULL, '2017-09-14 15:28:37'),
(41, 8, 9, NULL, '2017-09-14 15:37:58'),
(42, 8, 9, NULL, '2017-09-14 15:48:07'),
(43, 8, 9, NULL, '2017-09-14 15:48:09'),
(44, 8, 9, NULL, '2017-09-14 18:18:09'),
(45, 8, 9, NULL, '2017-09-14 18:18:14'),
(46, 9, 9, NULL, '2017-09-14 18:19:04'),
(47, 9, 9, NULL, '2017-09-14 18:19:04'),
(48, 9, 9, NULL, '2017-09-14 18:25:02'),
(49, 9, 9, NULL, '2017-09-14 18:25:04'),
(50, 10, 5, NULL, '2017-09-14 18:44:54'),
(51, 11, 5, '2017-09-15 08:33:30', '2017-09-15 11:33:27'),
(52, 11, 5, '2017-09-15 08:33:33', '2017-09-15 11:33:27'),
(53, 11, 5, '2017-09-15 08:33:33', '2017-09-15 11:33:29'),
(54, 11, 5, '2017-09-15 08:37:11', '2017-09-15 11:34:27'),
(55, 11, 5, NULL, '2017-09-15 11:37:06'),
(56, 11, 5, NULL, '2017-09-15 11:37:09'),
(57, 12, 9, '2017-09-15 16:39:05', '2017-09-15 19:39:01'),
(58, 12, 9, NULL, '2017-09-15 19:39:03'),
(59, 12, 9, NULL, '2017-09-15 19:39:06'),
(60, 13, 7, NULL, '2017-09-15 23:19:28'),
(61, 13, 7, NULL, '2017-09-15 23:47:34'),
(62, 13, 7, NULL, '2017-09-15 23:47:36'),
(63, 13, 6, NULL, '2017-09-15 23:51:10'),
(64, 14, 6, NULL, '2017-09-16 11:24:30'),
(65, 15, 7, NULL, '2017-09-16 12:37:31'),
(66, 15, 9, NULL, '2017-09-16 12:57:34'),
(67, 15, 9, NULL, '2017-09-16 12:57:34'),
(68, 16, 6, NULL, '2017-09-18 13:09:26'),
(69, 16, 6, NULL, '2017-09-18 14:30:54'),
(70, 17, 9, NULL, '2017-09-18 20:37:35'),
(71, 17, 9, NULL, '2017-09-18 21:32:01'),
(72, 17, 9, NULL, '2017-09-18 21:32:08'),
(73, 17, 9, NULL, '2017-09-18 22:55:48'),
(74, 18, 9, '2017-09-19 08:46:31', '2017-09-19 11:40:35'),
(75, 18, 9, '2017-09-19 08:46:32', '2017-09-19 11:46:29'),
(76, 18, 9, NULL, '2017-09-19 11:46:29'),
(77, 18, 9, NULL, '2017-09-19 11:46:29'),
(78, 18, 6, NULL, '2017-09-19 11:46:40'),
(79, 18, 4, NULL, '2017-09-19 11:46:53');

-- --------------------------------------------------------

--
-- Estrutura da tabela `tb_categories`
--

CREATE TABLE `tb_categories` (
  `idcategory` int(11) NOT NULL,
  `descategory` varchar(32) NOT NULL,
  `dtregister` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Extraindo dados da tabela `tb_categories`
--

INSERT INTO `tb_categories` (`idcategory`, `descategory`, `dtregister`) VALUES
(1, 'Android', '2017-09-07 13:49:40'),
(5, 'Aplle', '2017-09-07 14:37:57'),
(6, 'Motorola', '2017-09-07 14:38:02'),
(7, 'Samsung', '2017-09-07 14:38:15'),
(8, 'Teste 2', '2017-09-14 18:23:16');

-- --------------------------------------------------------

--
-- Estrutura da tabela `tb_orders`
--

CREATE TABLE `tb_orders` (
  `idorder` int(11) NOT NULL,
  `idcart` int(11) NOT NULL,
  `iduser` int(11) NOT NULL,
  `idstatus` int(11) NOT NULL,
  `idaddress` int(11) NOT NULL,
  `vltotal` decimal(10,2) NOT NULL,
  `dtregister` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Extraindo dados da tabela `tb_orders`
--

INSERT INTO `tb_orders` (`idorder`, `idcart`, `iduser`, `idstatus`, `idaddress`, `vltotal`, `dtregister`) VALUES
(1, 17, 18, 3, 16, '35.75', '2017-09-18 20:38:21'),
(2, 17, 18, 1, 17, '2096.95', '2017-09-18 21:32:14'),
(3, 17, 18, 1, 18, '2096.95', '2017-09-18 21:33:53'),
(4, 17, 18, 1, 19, '2787.04', '2017-09-18 23:13:19'),
(5, 18, 18, 1, 20, '738.35', '2017-09-19 11:41:02'),
(6, 18, 18, 1, 21, '3791.49', '2017-09-19 11:47:22'),
(7, 18, 18, 1, 22, '3791.49', '2017-09-19 11:49:16'),
(8, 18, 18, 1, 23, '3779.69', '2017-09-19 11:50:57'),
(9, 18, 18, 1, 24, '3803.49', '2017-09-19 11:52:40'),
(10, 18, 18, 1, 25, '3791.49', '2017-09-19 11:53:29'),
(11, 18, 18, 1, 26, '3791.49', '2017-09-19 11:54:53'),
(12, 18, 18, 1, 27, '3791.49', '2017-09-19 11:55:42'),
(13, 18, 18, 1, 28, '3791.49', '2017-09-19 11:57:06');

-- --------------------------------------------------------

--
-- Estrutura da tabela `tb_ordersstatus`
--

CREATE TABLE `tb_ordersstatus` (
  `idstatus` int(11) NOT NULL,
  `desstatus` varchar(32) NOT NULL,
  `dtregister` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Extraindo dados da tabela `tb_ordersstatus`
--

INSERT INTO `tb_ordersstatus` (`idstatus`, `desstatus`, `dtregister`) VALUES
(1, 'Em Aberto', '2017-03-13 03:00:00'),
(2, 'Aguardando Pagamento', '2017-03-13 03:00:00'),
(3, 'Pago', '2017-03-13 03:00:00'),
(4, 'Entregue', '2017-03-13 03:00:00');

-- --------------------------------------------------------

--
-- Estrutura da tabela `tb_persons`
--

CREATE TABLE `tb_persons` (
  `idperson` int(11) NOT NULL,
  `desperson` varchar(64) NOT NULL,
  `desemail` varchar(128) DEFAULT NULL,
  `nrphone` bigint(20) DEFAULT NULL,
  `dtregister` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Extraindo dados da tabela `tb_persons`
--

INSERT INTO `tb_persons` (`idperson`, `desperson`, `desemail`, `nrphone`, `dtregister`) VALUES
(1, 'João Rangel', 'suporte@hcode.com.br', 2147483647, '2017-03-01 03:00:00'),
(7, 'Suporte', 'sup@gmail.com', 1112345678, '2017-03-15 16:10:27'),
(8, 'Luiz Rodrigues dos Santos', 'atende@galeria.com.br', 6299999999, '2017-09-05 17:20:38'),
(9, 'Júlia Rodrigues', 'ga@gmail.com', 6288888888, '2017-09-05 17:21:30'),
(12, 'Luiz', 'atende@galeria.com.br', 0, '2017-09-15 18:16:47'),
(13, 'Luiz', 'gogo@galeria.com.br', 0, '2017-09-15 18:18:11'),
(14, 'Manel', 'go@galeria.com.br', 45845, '2017-09-15 18:23:54'),
(15, 'Manel', 'go5@galeria.com.br', 45845, '2017-09-15 19:09:34'),
(16, 'Luiz Rodrigues', 'bob_smallville@hotmail.com', 45845, '2017-09-15 19:58:01'),
(17, 'Luiz Rico', 'ccc@hotmail.com', 45845, '2017-09-15 20:28:47'),
(18, 'JÃºlia Rodrigues', 'galerias2099@gmail.com', 45845, '2017-09-15 20:34:48'),
(19, 'JÃºlia Rodrigues Beda', 'galerias2099@gmail.com', 45845, '2017-09-15 22:21:28'),
(20, 'JÃºlia Rodrigues Beda', 'galerias2099@gmail.com', 45845, '2017-09-15 22:25:01');

-- --------------------------------------------------------

--
-- Estrutura da tabela `tb_products`
--

CREATE TABLE `tb_products` (
  `idproduct` int(11) NOT NULL,
  `desproduct` varchar(64) NOT NULL,
  `vlprice` decimal(10,2) NOT NULL,
  `vlwidth` decimal(10,2) NOT NULL,
  `vlheight` decimal(10,2) NOT NULL,
  `vllength` decimal(10,2) NOT NULL,
  `vlweight` decimal(10,2) NOT NULL,
  `desurl` varchar(128) NOT NULL,
  `dtregister` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Extraindo dados da tabela `tb_products`
--

INSERT INTO `tb_products` (`idproduct`, `desproduct`, `vlprice`, `vlwidth`, `vlheight`, `vllength`, `vlweight`, `desurl`, `dtregister`) VALUES
(4, 'Tablet Samsung Galaxy Tab E T113 8GB', '450.00', '17.00', '0.75', '10.25', '0.47', 'Tablet-Samsung-Galaxy', '2017-09-08 21:13:45'),
(5, 'Smartphone Motorola Moto G5 Plus', '1135.23', '15.20', '7.40', '0.70', '0.16', 'smartphone-motorola-moto-g5-plus', '2017-09-08 23:44:57'),
(6, 'Smartphone Moto Z Play', '1887.78', '14.10', '0.90', '1.16', '0.13', 'smartphone-moto-z-play', '2017-09-08 23:44:57'),
(7, 'Smartphone Samsung Galaxy J5 Pro', '1299.00', '14.60', '7.10', '0.80', '0.16', 'smartphone-samsung-galaxy-j5', '2017-09-08 23:44:57'),
(8, 'Smartphone Samsung Galaxy J7 Prime', '1149.00', '15.10', '7.50', '0.80', '0.16', 'smartphone-samsung-galaxy-j7', '2017-09-08 23:44:57'),
(9, 'Smartphone Samsung Galaxy J3 Dual', '679.90', '14.20', '7.10', '0.70', '0.14', 'smartphone-samsung-galaxy-j3', '2017-09-08 23:44:57');

-- --------------------------------------------------------

--
-- Estrutura da tabela `tb_productscategories`
--

CREATE TABLE `tb_productscategories` (
  `idcategory` int(11) NOT NULL,
  `idproduct` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Extraindo dados da tabela `tb_productscategories`
--

INSERT INTO `tb_productscategories` (`idcategory`, `idproduct`) VALUES
(5, 4),
(5, 5),
(5, 6),
(5, 8),
(6, 5),
(6, 6),
(7, 4),
(7, 7),
(7, 8),
(7, 9),
(8, 4),
(8, 5),
(8, 8);

-- --------------------------------------------------------

--
-- Estrutura da tabela `tb_users`
--

CREATE TABLE `tb_users` (
  `iduser` int(11) NOT NULL,
  `idperson` int(11) NOT NULL,
  `deslogin` varchar(64) NOT NULL,
  `despassword` varchar(256) NOT NULL,
  `inadmin` tinyint(4) NOT NULL DEFAULT '0',
  `dtregister` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Extraindo dados da tabela `tb_users`
--

INSERT INTO `tb_users` (`iduser`, `idperson`, `deslogin`, `despassword`, `inadmin`, `dtregister`) VALUES
(1, 1, 'admin', '$2y$12$YlooCyNvyTji8bPRcrfNfOKnVMmZA9ViM2A3IpFjmrpIbp5ovNmga', 1, '2017-03-13 03:00:00'),
(7, 7, 'suporte', '$2y$08$B31GYL0xbr4WhTrQfUKA2.iAK5T0U8Zi2w.9LRDlupgRpt3oXBiC.', 1, '2017-03-15 16:10:27'),
(8, 8, 'Luiz', '123456', 1, '2017-09-05 17:20:38'),
(9, 9, 'Julia', 'dfasdfa', 1, '2017-09-05 17:21:30'),
(12, 12, 'atende@galeria.com.br', '$2y$08$xbF/NPTiVgox5MxnWJQQXOo284UZvLAm/DZM.ikwu0tKqywGgkH/S', 0, '2017-09-15 18:16:47'),
(13, 13, 'gogo@galeria.com.br', '$2y$08$ZSApP5AkpQl4/hqQXnGy4.xlvPsjf93GCcQpZDPjlZHPDjSJ6I4f.', 0, '2017-09-15 18:18:11'),
(14, 14, 'go@galeria.com.br', '$2y$08$zUG/BHOxXy4FFTy9/drnz.JcCilOWVX4xoKwpNF.WQY6ZD8bIwNuO', 0, '2017-09-15 18:23:54'),
(15, 15, 'go5@galeria.com.br', '$2y$08$HyCVnc6onOTZqh7Oc0fQzeRwaf0lKuuCvZkDz6MrKtLrP8sN01v6C', 0, '2017-09-15 19:09:34'),
(16, 16, 'bob_smallville@hotmail.com', '$2y$08$ZyUCoYdjW2/SOIgEosd0TOioS6eRgGg3hes7va.mC0FAxCj5FLH3W', 0, '2017-09-15 19:58:01'),
(17, 17, 'ccc@hotmail.com', '$2y$08$2vNtSBLjk2W0LVT1kK/FtOJOIXN6zJRDj/Iri2yYNSX4qmw7SV4v6', 0, '2017-09-15 20:28:47'),
(18, 18, 'galerias2099@gmail.com', '$2y$08$on4zKkIGCQIqM2oBi8BHL.kjmHpQE1VMAtZ7Y2i1nOcvMqu6dhMFa', 0, '2017-09-15 20:34:48'),
(19, 19, 'galerias2099@gmail.com', '$2y$08$pTXksG.ClCwe0UxX5oX8ouxzLZnluHxZg.X0DQ.JUjMdYuhRw.lBW', 0, '2017-09-15 22:21:28'),
(20, 20, 'galerias2099@gmail.com', '$2y$08$RDXjhGR6YMnWqCb5x7dM3.IbVrQ6xjwQkzrPHqKf0wDYdxoZiES5e', 0, '2017-09-15 22:25:01');

-- --------------------------------------------------------

--
-- Estrutura da tabela `tb_userslogs`
--

CREATE TABLE `tb_userslogs` (
  `idlog` int(11) NOT NULL,
  `iduser` int(11) NOT NULL,
  `deslog` varchar(128) NOT NULL,
  `desip` varchar(45) NOT NULL,
  `desuseragent` varchar(128) NOT NULL,
  `dessessionid` varchar(64) NOT NULL,
  `desurl` varchar(128) NOT NULL,
  `dtregister` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Estrutura da tabela `tb_userspasswordsrecoveries`
--

CREATE TABLE `tb_userspasswordsrecoveries` (
  `idrecovery` int(11) NOT NULL,
  `iduser` int(11) NOT NULL,
  `desip` varchar(45) NOT NULL,
  `dtrecovery` datetime DEFAULT NULL,
  `dtregister` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Extraindo dados da tabela `tb_userspasswordsrecoveries`
--

INSERT INTO `tb_userspasswordsrecoveries` (`idrecovery`, `iduser`, `desip`, `dtrecovery`, `dtregister`) VALUES
(1, 7, '127.0.0.1', NULL, '2017-03-15 16:10:59'),
(2, 7, '127.0.0.1', '2017-03-15 13:33:45', '2017-03-15 16:11:18'),
(3, 7, '127.0.0.1', '2017-03-15 13:37:35', '2017-03-15 16:37:12'),
(4, 8, '127.0.0.1', NULL, '2017-09-06 19:54:57'),
(5, 8, '127.0.0.1', NULL, '2017-09-06 19:55:53'),
(6, 8, '127.0.0.1', NULL, '2017-09-06 19:56:44'),
(7, 8, '127.0.0.1', NULL, '2017-09-06 19:58:44'),
(8, 8, '127.0.0.1', NULL, '2017-09-06 19:58:52'),
(9, 8, '127.0.0.1', NULL, '2017-09-06 20:00:10'),
(10, 8, '127.0.0.1', NULL, '2017-09-06 20:01:06'),
(11, 8, '127.0.0.1', NULL, '2017-09-06 20:03:51'),
(12, 8, '127.0.0.1', NULL, '2017-09-06 20:03:58'),
(13, 8, '127.0.0.1', NULL, '2017-09-06 20:08:59'),
(14, 8, '127.0.0.1', NULL, '2017-09-06 20:19:42'),
(15, 8, '127.0.0.1', NULL, '2017-09-06 20:26:05'),
(16, 8, '127.0.0.1', NULL, '2017-09-06 20:29:35'),
(17, 8, '127.0.0.1', NULL, '2017-09-06 21:00:15'),
(18, 8, '127.0.0.1', NULL, '2017-09-06 21:01:48'),
(19, 8, '127.0.0.1', NULL, '2017-09-06 21:07:27'),
(20, 8, '127.0.0.1', NULL, '2017-09-06 21:09:27'),
(21, 8, '127.0.0.1', NULL, '2017-09-06 21:15:11'),
(22, 8, '127.0.0.1', NULL, '2017-09-06 21:15:30'),
(23, 8, '127.0.0.1', NULL, '2017-09-06 21:15:48'),
(24, 8, '127.0.0.1', NULL, '2017-09-06 21:17:10'),
(25, 8, '127.0.0.1', NULL, '2017-09-06 21:17:38'),
(26, 8, '127.0.0.1', NULL, '2017-09-06 21:58:17'),
(27, 8, '127.0.0.1', NULL, '2017-09-06 22:09:33'),
(28, 8, '127.0.0.1', NULL, '2017-09-06 22:10:46'),
(29, 8, '127.0.0.1', NULL, '2017-09-06 22:12:53'),
(30, 9, '127.0.0.1', NULL, '2017-09-06 22:14:58'),
(31, 1, '127.0.0.1', NULL, '2017-09-07 00:03:03'),
(32, 7, '127.0.0.1', '2017-09-06 21:54:35', '2017-09-07 00:53:06'),
(33, 7, '127.0.0.1', '2017-09-06 22:04:38', '2017-09-07 01:02:58'),
(34, 8, '127.0.0.1', NULL, '2017-09-15 19:42:31'),
(35, 8, '127.0.0.1', NULL, '2017-09-15 19:45:30'),
(36, 8, '127.0.0.1', NULL, '2017-09-15 19:46:07'),
(37, 8, '127.0.0.1', NULL, '2017-09-15 19:46:41'),
(38, 8, '127.0.0.1', NULL, '2017-09-15 19:48:25'),
(39, 8, '127.0.0.1', NULL, '2017-09-15 19:55:24'),
(40, 7, '127.0.0.1', NULL, '2017-09-15 20:01:53'),
(41, 7, '127.0.0.1', '2017-09-15 17:10:49', '2017-09-15 20:08:17'),
(42, 18, '127.0.0.1', '2017-09-15 17:39:16', '2017-09-15 20:35:34');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `tb_addresses`
--
ALTER TABLE `tb_addresses`
  ADD PRIMARY KEY (`idaddress`),
  ADD KEY `fk_addresses_persons_idx` (`idperson`);

--
-- Indexes for table `tb_carts`
--
ALTER TABLE `tb_carts`
  ADD PRIMARY KEY (`idcart`),
  ADD KEY `FK_carts_users_idx` (`iduser`);

--
-- Indexes for table `tb_cartsproducts`
--
ALTER TABLE `tb_cartsproducts`
  ADD PRIMARY KEY (`idcartproduct`),
  ADD KEY `FK_cartsproducts_carts_idx` (`idcart`),
  ADD KEY `FK_cartsproducts_products_idx` (`idproduct`);

--
-- Indexes for table `tb_categories`
--
ALTER TABLE `tb_categories`
  ADD PRIMARY KEY (`idcategory`);

--
-- Indexes for table `tb_orders`
--
ALTER TABLE `tb_orders`
  ADD PRIMARY KEY (`idorder`),
  ADD KEY `FK_orders_users_idx` (`iduser`),
  ADD KEY `fk_orders_ordersstatus_idx` (`idstatus`),
  ADD KEY `fk_orders_carts_idx` (`idcart`),
  ADD KEY `fk_orders_addresses_idx` (`idaddress`);

--
-- Indexes for table `tb_ordersstatus`
--
ALTER TABLE `tb_ordersstatus`
  ADD PRIMARY KEY (`idstatus`);

--
-- Indexes for table `tb_persons`
--
ALTER TABLE `tb_persons`
  ADD PRIMARY KEY (`idperson`);

--
-- Indexes for table `tb_products`
--
ALTER TABLE `tb_products`
  ADD PRIMARY KEY (`idproduct`);

--
-- Indexes for table `tb_productscategories`
--
ALTER TABLE `tb_productscategories`
  ADD PRIMARY KEY (`idcategory`,`idproduct`),
  ADD KEY `fk_productscategories_products_idx` (`idproduct`);

--
-- Indexes for table `tb_users`
--
ALTER TABLE `tb_users`
  ADD PRIMARY KEY (`iduser`),
  ADD KEY `FK_users_persons_idx` (`idperson`);

--
-- Indexes for table `tb_userslogs`
--
ALTER TABLE `tb_userslogs`
  ADD PRIMARY KEY (`idlog`),
  ADD KEY `fk_userslogs_users_idx` (`iduser`);

--
-- Indexes for table `tb_userspasswordsrecoveries`
--
ALTER TABLE `tb_userspasswordsrecoveries`
  ADD PRIMARY KEY (`idrecovery`),
  ADD KEY `fk_userspasswordsrecoveries_users_idx` (`iduser`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `tb_addresses`
--
ALTER TABLE `tb_addresses`
  MODIFY `idaddress` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=29;
--
-- AUTO_INCREMENT for table `tb_carts`
--
ALTER TABLE `tb_carts`
  MODIFY `idcart` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;
--
-- AUTO_INCREMENT for table `tb_cartsproducts`
--
ALTER TABLE `tb_cartsproducts`
  MODIFY `idcartproduct` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=80;
--
-- AUTO_INCREMENT for table `tb_categories`
--
ALTER TABLE `tb_categories`
  MODIFY `idcategory` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;
--
-- AUTO_INCREMENT for table `tb_orders`
--
ALTER TABLE `tb_orders`
  MODIFY `idorder` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;
--
-- AUTO_INCREMENT for table `tb_ordersstatus`
--
ALTER TABLE `tb_ordersstatus`
  MODIFY `idstatus` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;
--
-- AUTO_INCREMENT for table `tb_persons`
--
ALTER TABLE `tb_persons`
  MODIFY `idperson` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;
--
-- AUTO_INCREMENT for table `tb_products`
--
ALTER TABLE `tb_products`
  MODIFY `idproduct` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;
--
-- AUTO_INCREMENT for table `tb_users`
--
ALTER TABLE `tb_users`
  MODIFY `iduser` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;
--
-- AUTO_INCREMENT for table `tb_userslogs`
--
ALTER TABLE `tb_userslogs`
  MODIFY `idlog` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `tb_userspasswordsrecoveries`
--
ALTER TABLE `tb_userspasswordsrecoveries`
  MODIFY `idrecovery` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=43;
--
-- Constraints for dumped tables
--

--
-- Limitadores para a tabela `tb_addresses`
--
ALTER TABLE `tb_addresses`
  ADD CONSTRAINT `fk_addresses_persons` FOREIGN KEY (`idperson`) REFERENCES `tb_persons` (`idperson`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Limitadores para a tabela `tb_carts`
--
ALTER TABLE `tb_carts`
  ADD CONSTRAINT `fk_carts_users` FOREIGN KEY (`iduser`) REFERENCES `tb_users` (`iduser`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Limitadores para a tabela `tb_cartsproducts`
--
ALTER TABLE `tb_cartsproducts`
  ADD CONSTRAINT `fk_cartsproducts_carts` FOREIGN KEY (`idcart`) REFERENCES `tb_carts` (`idcart`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_cartsproducts_products` FOREIGN KEY (`idproduct`) REFERENCES `tb_products` (`idproduct`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Limitadores para a tabela `tb_orders`
--
ALTER TABLE `tb_orders`
  ADD CONSTRAINT `fk_orders_addresses` FOREIGN KEY (`idaddress`) REFERENCES `tb_addresses` (`idaddress`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_orders_carts` FOREIGN KEY (`idcart`) REFERENCES `tb_carts` (`idcart`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_orders_ordersstatus` FOREIGN KEY (`idstatus`) REFERENCES `tb_ordersstatus` (`idstatus`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_orders_users` FOREIGN KEY (`iduser`) REFERENCES `tb_users` (`iduser`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Limitadores para a tabela `tb_productscategories`
--
ALTER TABLE `tb_productscategories`
  ADD CONSTRAINT `fk_productscategories_categories` FOREIGN KEY (`idcategory`) REFERENCES `tb_categories` (`idcategory`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_productscategories_products` FOREIGN KEY (`idproduct`) REFERENCES `tb_products` (`idproduct`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Limitadores para a tabela `tb_users`
--
ALTER TABLE `tb_users`
  ADD CONSTRAINT `fk_users_persons` FOREIGN KEY (`idperson`) REFERENCES `tb_persons` (`idperson`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Limitadores para a tabela `tb_userslogs`
--
ALTER TABLE `tb_userslogs`
  ADD CONSTRAINT `fk_userslogs_users` FOREIGN KEY (`iduser`) REFERENCES `tb_users` (`iduser`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Limitadores para a tabela `tb_userspasswordsrecoveries`
--
ALTER TABLE `tb_userspasswordsrecoveries`
  ADD CONSTRAINT `fk_userspasswordsrecoveries_users` FOREIGN KEY (`iduser`) REFERENCES `tb_users` (`iduser`) ON DELETE NO ACTION ON UPDATE NO ACTION;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
