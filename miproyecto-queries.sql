-- Mostrar los nombres de los clubes que han participado en  al menos una regata en la que se haya competido en modalidad "Infantil".
SELECT c.Nombre_club
FROM clubes c
INNER JOIN barcos b ON c.Nombre_club = b.Nombre_club
INNER JOIN remeros r ON b.Nombre_club = r.Nombre_club
INNER JOIN clasificacion cl ON b.Nombre_club = cl.Nombre_club
INNER JOIN mangas m ON cl.Cod_regata = m.Cod_regata
WHERE m.modalidad = 'Infantil'
GROUP BY c.Nombre_club;

-- Mostrar los nombres y apellidos de los remeros que pertenecen a un barco que ha competido en la la primera manga de una regata
SELECT concat( Nombre,' ', Apellidos) as Nombre
FROM remeros
WHERE (Nombre_club, Cod_barco) IN
(SELECT Nombre_club, Cod_barco
FROM clasificacion
WHERE orden = 1);





-- Mostrar el nombre del club, el nombre de la regata y la cantidad de remeros que han participado en cada regata del río "Ebro".
SELECT c.Nombre_club, rg.Nombre_competicion, COUNT(*) as num_remeros
FROM remeros r
INNER JOIN barcos b ON r.Nombre_club = b.Nombre_club
INNER JOIN clasificacion cl ON b.Nombre_club = cl.Nombre_club
INNER JOIN regata rg ON cl.Cod_regata = rg.Cod_regata
INNER JOIN clubes c ON r.Nombre_club = c.Nombre_club
WHERE rg.Rio = 'Ebro'
GROUP BY c.Nombre_club, rg.Nombre_competicion;





-- Cuenta el numero de remeros que han participado en todas las regatas del año 2021.
SELECT count(r2.DNI_remero) as Numero_Remeros
FROM remeros r2
WHERE EXISTS (
SELECT r.Cod_regata
FROM regata r
WHERE YEAR(r.Fecha_regata) = 2021
);



-- Mostrar el nombre del club y el codigo de barco con mejor hora de llagada de la regata con codigo 15
SELECT c.Nombre_club, b.Cod_barco, cl.hora_llegada
FROM clasificacion cl
INNER JOIN barcos b ON cl.Nombre_club = b.Nombre_club AND cl.Cod_barco = b.Cod_barco
INNER JOIN clubes c ON b.Nombre_club = c.Nombre_club
WHERE cl.hora_llegada = (SELECT MIN(hora_llegada) FROM clasificacion WHERE Cod_regata = 25);



-- Primera vista: “vista_remeros_por_rio”

CREATE VIEW vista_remeros_por_rio AS
SELECT c.Nombre_club, rg.Nombre_competicion, COUNT(*) as num_remeros
FROM remeros r
INNER JOIN barcos b ON r.Nombre_club = b.Nombre_club
INNER JOIN clasificacion cl ON b.Nombre_club = cl.Nombre_club
INNER JOIN regata rg ON cl.Cod_regata = rg.Cod_regata
INNER JOIN clubes c ON r.Nombre_club = c.Nombre_club
WHERE rg.Rio = 'Ebro'
GROUP BY c.Nombre_club, rg.Nombre_competicion;

-- Segunda vista: “vista_remeros_por_rio_orden”
CREATE VIEW vista_remeros_por_rio_orden AS
SELECT *
FROM vista_remeros_por_rio
ORDER BY Nombre_competicion, num_remeros DESC;






-- Función "cantidad_remeros_club" que recibe como parámetro el nombre de un club y devuelve la cantidad de remeros que pertenecen a ese club. 

drop function if exists cantidad_remeros_club;
DELIMITER $$
CREATE FUNCTION cantidad_remeros_club (p_club VARCHAR(50))
RETURNS INT
BEGIN
DECLARE num_remeros INT;
SELECT COUNT(*) INTO num_remeros
FROM remeros
WHERE Nombre_club = p_club;
RETURN num_remeros;
END $$
DELIMITER ;
SELECT cantidad_remeros_club('CLUB NAUTICO SEVILLA');



-- Función "hora_llegada_equipo" que recibe como parámetros el código de la regata, el orden de la manga, el nombre del club y el código del barco, y devuelve la hora de llegada de ese equipo en cuestión.

drop function if exists hora_llegada_equipo;
DELIMITER $$
CREATE FUNCTION hora_llegada_equipo(Cod_Regata INT, Orden_Manga INT, Nombre_Club VARCHAR(40), Cod_Barco INT)
RETURNS TIME
BEGIN
DECLARE Hora_Llegada TIME;
SELECT cl.hora_llegada INTO Hora_Llegada
FROM mangas m
INNER JOIN clasificacion cl ON m.Cod_Regata = cl.Cod_Regata
WHERE m.Cod_Regata = Cod_Regata AND m.orden = Orden_Manga AND cl.Nombre_Club = Nombre_Club AND cl.Cod_Barco = Cod_Barco;
RETURN Hora_Llegada;
end $$
DELIMITER ;
SELECT hora_llegada_equipo(3, 6,'ARRAUN ELKARTEA',1);




-- Procedimiento que recibe como parámetro el nombre del club y utiliza la función “cantidad_remeros_club” para obtener el número de remeros que tiene ese club y lo muestra en pantalla con un mensaje con dicha información. 

drop procedure if exists mostrar_cantidad_remeros;
DELIMITER $$
CREATE PROCEDURE mostrar_cantidad_remeros(p_club VARCHAR(50))
BEGIN
SELECT CONCAT('El club ', p_club, ' tiene ', cantidad_remeros_club(p_club), ' remeros.') AS 'Información';
END $$
DELIMITER ;
CALL mostrar_cantidad_remeros('CLUB DE REMO GUADALQUIVIR 86');




-- Procedimiento que toma dos parámetros de entrada y muestra la clasificación para la regata y manga correspondientes

drop procedure if exists mostrar_clasificacion;
DELIMITER $$
CREATE PROCEDURE `mostrar_clasificacion` (IN regata_id INT,IN manga_id INT)
BEGIN
SELECT b.Nombre_club, r.DNI_remero, r.Nombre, r.Apellidos, c.hora_llegada, c.orden
FROM clasificacion c
inner JOIN barcos b ON c.Nombre_club = b.Nombre_club
inner JOIN remeros r ON b.Nombre_club = r.Nombre_club
inner JOIN mangas m ON c.Cod_regata = m.Cod_regata
WHERE c.Cod_regata = regata_id AND m.orden = manga_id
ORDER BY c.hora_llegada ASC;
END $$
DELIMITER ;
call mostrar_clasificacion(5,3);



-- Procedimiento con cursor que recorre la tabla remeros y devuelve la suma total de los códigos de barco de los remeros de cada club:

DELIMITER $$
CREATE PROCEDURE sumaCodigosBarco()
BEGIN
DECLARE fin INT DEFAULT 0;
DECLARE nombreClub VARCHAR(40);
DECLARE codBarco INT;
DECLARE suma INT DEFAULT 0;
DECLARE cur CURSOR FOR SELECT `Nombre_club`, `Cod_barco` FROM `remeros`;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET fin = 1;
OPEN cur;
FETCH cur INTO nombreClub, codBarco;
WHILE NOT fin DO
IF nombreClub IS NOT NULL THEN
SET suma = suma + codBarco;
END IF;
FETCH cur INTO nombreClub, codBarco;
END WHILE;
SELECT `Nombre_club`, SUM(`Cod_barco`) AS `Suma_codigos_barco` FROM `	remeros` GROUP BY `Nombre_club`;
CLOSE cur;
END $$
DELIMITER ;




-- Trigger para actualizar el total de barcos por club

CREATE TRIGGER `guardar_barcos_borrados`
AFTER DELETE
ON `barcos`
FOR EACH ROW
INSERT INTO barcos_borrados (Nombre_club, Cod_barco)
VALUES (OLD.Nombre_club, OLD.Cod_barco);



-- Trigger para guardar en una tabla los datos después de borrar una fila en la tabla barcos:
CREATE TRIGGER eliminaClasificacion AFTER DELETE ON remeros
FOR EACH ROW
DELETE FROM clasificacion WHERE DNI_remero = OLD.DNI_remero;








