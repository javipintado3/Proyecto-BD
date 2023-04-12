CREATE DATABASE `proyecto` /*!40100 DEFAULT CHARACTER SET latin1 */;

CREATE TABLE `barcos` (
  `Nombre_club` varchar(40) NOT NULL,
  `Cod_barco` int(11) NOT NULL,
  PRIMARY KEY (`Nombre_club`,`Cod_barco`),
  CONSTRAINT `barcos_FK` FOREIGN KEY (`Nombre_club`) REFERENCES `clubes` (`Nombre_club`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `clasificacion` (
  `id_clasificacion` int(11) NOT NULL AUTO_INCREMENT,
  `hora_llegada` time NOT NULL,
  `Cod_regata` int(11) NOT NULL,
  `Nombre_club` varchar(40) NOT NULL,
  `Cod_barco` int(11) NOT NULL,
  `orden` int(11) DEFAULT NULL,
  PRIMARY KEY (`id_clasificacion`),
  KEY `clasificacion_FK` (`Cod_regata`,`orden`),
  KEY `clasificacion_FK_1` (`Nombre_club`,`Cod_barco`),
  CONSTRAINT `clasificacion_FK` FOREIGN KEY (`Cod_regata`, `orden`) REFERENCES `mangas` (`Cod_regata`, `orden`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `clasificacion_FK_1` FOREIGN KEY (`Nombre_club`, `Cod_barco`) REFERENCES `barcos` (`Nombre_club`, `Cod_barco`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=151 DEFAULT CHARSET=latin1;

CREATE TABLE `clubes` (
  `Nombre_club` varchar(40) NOT NULL,
  PRIMARY KEY (`Nombre_club`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `mangas` (
  `hora_salida` time NOT NULL,
  `modalidad` varchar(20) DEFAULT NULL,
  `Cod_regata` int(11) NOT NULL,
  `orden` int(11) NOT NULL,
  PRIMARY KEY (`Cod_regata`,`orden`),
  CONSTRAINT `mangas_FK` FOREIGN KEY (`Cod_regata`) REFERENCES `regata` (`Cod_regata`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `regata` (
  `Cod_regata` int(11) NOT NULL,
  `Nombre_competicion` varchar(100) DEFAULT NULL,
  `Rio` varchar(30) DEFAULT NULL,
  `Fecha_regata` datetime DEFAULT NULL,
  PRIMARY KEY (`Cod_regata`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `remeros` (
  `DNI_remero` varchar(9) NOT NULL,
  `Nombre` varchar(20) DEFAULT NULL,
  `Apellidos` varchar(40) DEFAULT NULL,
  `Genero` varchar(15) DEFAULT NULL,
  `Categoria` varchar(15) DEFAULT NULL,
  `Nombre_club` varchar(130) DEFAULT NULL,
  `Cod_barco` int(11) DEFAULT NULL,
  PRIMARY KEY (`DNI_remero`),
  KEY `remeros_FK` (`Nombre_club`,`Cod_barco`),
  CONSTRAINT `remeros_FK` FOREIGN KEY (`Nombre_club`, `Cod_barco`) REFERENCES `barcos` (`Nombre_club`, `Cod_barco`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

