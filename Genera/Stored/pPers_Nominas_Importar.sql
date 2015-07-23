USE [GENERA]
GO
/****** Object:  StoredProcedure [dbo].[pPers_Nominas_Importar]    Script Date: 13/07/2015 9:58:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[pPers_Nominas_Importar] (@IdImportacion int, @Retorno varchar(400) OUTPUT) AS

BEGIN TRY

DECLARE @Valores TABLE (Valor varchar(100))
DECLARE @IMPORTES TABLE (IdEmpleado int, Empleado varchar(250), Importe_Bruto float, Importe_Pago float, Importe_SS float, CuentaBruto varchar(15), CuentaPago varchar(15), CuentaSS varchar(15), IdCentroCoste varchar(50), Asiento640 int, Apunte640 int, Apunte465 int, Asiento642 int)
DECLARE @CC TABLE (IdEmpleado int, IdCentroCoste varchar(50), Porcentaje float)
DECLARE @LOSEMPLEADOS TABLE (IdEmpleado int, IdCentroCoste varchar(50))
DECLARE @APUNTES_DESCUADRADOS TABLE (Asiento int, Apunte int, Importe float, IdDoc int)
DECLARE @IdEjercicio int
DECLARE @NumDigitos smallint
DECLARE @CuentaBruto varchar(15)
DECLARE @Cuenta_G_SS  varchar(15)
DECLARE @CuentaPago varchar(15)
DECLARE @CuentaIRPF varchar(15)
DECLARE @CuentaSS varchar(15)
DECLARE @CuentaSS_EMP varchar(15)
DECLARE @TRABAJADOR varchar(100)
DECLARE @Importe_IRPF float
DECLARE @Importe_SS_TRAB float
DECLARE @Importe_SS_EMP float
DECLARE @Asiento int
DECLARE @Apunte int
DECLARE @Fecha smalldatetime
DECLARE @IdCentroCoste_Est varchar(50)

--SELECT @IdCentroCoste_Est = Valor FROM Ceesi_configuracion WHERE Parametro = 'CENTROCOSTE_LINEA_GENERICO'
------------------------------------------------------------------------------------------------------------
---- COMPROBACIONES
------------------------------------------------------------------------------------------------------------

--Miramos si el centro de coste generico esta definido
--IF IsNULL(@IdCentroCoste_Est, '') = '' BEGIN
--	RAISERROR ('DEBE CONFIGURAR UN CENTRO DE COSTE ESTRUCTURAL', 12, 1)
--END

--Miramos si la nomina que queremos contabilizar ya esta asociada a un asiento
IF (SELECT Count(1) FROM Pers_Importa_Nominas WHERE IdImportacion=@IdImportacion AND (IsNULL(IdDocApunte, 0) > 0 OR IsNULL(IdDocApunte_SS, 0) > 0)) > 0 BEGIN
	RAISERROR ('ESTA NÓMINA ESTÁ VINCULADA A UN ASIENTO CONTABLE', 12, 1)
END

-- Hacemos un left join con la tabla empleado para asegurarnos que todos los NIF que tenemos pertenecen a un empleado del ERP
-- Ponemos todos los NIF si empleado que encontramos en una tabla temporal que recogemos despues para sacar un mesage de error
IF (SELECT Count(1) FROM Pers_Importa_Nominas_Lineas P 
	LEFT JOIN Empleados_Datos E ON P.NIF = E.NIF 
	WHERE P.IdImportacion=@IdImportacion AND E.IdEmpleado Is NULL) > 0 BEGIN
		INSERT INTO @Valores (Valor)
		SELECT LEFT(P.Trabajador, 100)
		FROM Pers_Importa_Nominas_Lineas P 
		LEFT JOIN Empleados_Datos E ON P.NIF = E.NIF 
		WHERE P.IdImportacion=@IdImportacion AND E.IdEmpleado Is NULL

	WHILE (SELECT COUNT(1) FROM @Valores) > 0 BEGIN
		SELECT TOP 1 @TRABAJADOR = Valor FROM @Valores 
		IF LEN(ISNULL(@Retorno, '')) < 400 BEGIN
			SET @Retorno = ISNULL(@Retorno, '') + @TRABAJADOR + char(13)
		END
		DELETE FROM @Valores WHERE Valor = @TRABAJADOR 
	END
	RAISERROR ('EXISTEN TRABAJADORES QUE NO COINCIDEN CON EL NIF DE EMPLEADOS.', 12, 1)
END

--Miramos si existen NIF repetidos en la nomina que queremos contabilizar 
IF (SELECT Count(1) FROM Empleados_Datos WHERE NIF IN (SELECT DISTINCT NIF FROM Pers_Importa_Nominas_Lineas WHERE IdImportacion = @IdImportacion) GROUP BY NIF HAVING Count(1) > 1) > 0 BEGIN
	INSERT INTO @Valores (Valor)
	SELECT NIF FROM Empleados_Datos 
	WHERE NIF IN (SELECT DISTINCT NIF FROM Pers_Importa_Nominas_Lineas WHERE IdImportacion = @IdImportacion) 
	GROUP BY NIF HAVING Count(1) > 1

	WHILE (SELECT COUNT(1) FROM @Valores) > 0 BEGIN
		SELECT TOP 1 @TRABAJADOR = Valor FROM @Valores 
		IF LEN(ISNULL(@Retorno, '')) < 400 BEGIN
			SET @Retorno = ISNULL(@Retorno, '') + @TRABAJADOR + char(13)
		END
		DELETE FROM @Valores WHERE Valor = @TRABAJADOR 
	END
	RAISERROR ('EXISTEN NIF REPETIDOS EN FICHAS DE EMPLEADOS.', 12, 1)
END

--Esta comprobación no nos vale porque puede pasar. Hacemos el case por DNI
--IF (SELECT COunt(1) FROM Empleados_Datos E 
--	INNER JOIN Pers_Importa_Nominas_Lineas P ON E.NIF = P.NIF AND E.IdEmpleado <> CAST(P.IdEmpleado as int) 
--	WHERE E.NIF  <> '75381985Z' AND P.IdImportacion = @IdImportacion) > 0 BEGIN
	
--	INSERT INTO @Valores (Valor)
--	SELECT P.TRABAJADOR 
--	FROM Empleados_Datos E 
--	INNER JOIN Pers_Importa_Nominas_Lineas P ON E.NIF = P.NIF AND E.IdEmpleado <> CAST(P.IdEmpleado as int) 
--	WHERE E.NIF  <> '75381985Z' AND P.IdImportacion = @IdImportacion

--	WHILE (SELECT COUNT(1) FROM @Valores) > 0 BEGIN
--		SELECT TOP 1 @TRABAJADOR = Valor FROM @Valores 
--		IF LEN(ISNULL(@Retorno, '')) < 400 BEGIN
--			SET @Retorno = ISNULL(@Retorno, '') + @TRABAJADOR + char(13)
--		END
--		DELETE FROM @Valores WHERE Valor = @TRABAJADOR 
--	END
--	RAISERROR ('EXISTEN EMPLEADOS QUE NO COINCIDE EL IDEMPLEADO DE NOMINAS CON EL DE LA ERP.', 12, 1)
--END

--Recuperar el ejercicio contable activo a la fecha de importacion de la nomina
SET @IdEjercicio = -10000

SELECT @IdEjercicio = CE.IdEjercicio, @Fecha = P.Fecha 
FROM Conta_Ejercicios CE 
INNER JOIN Pers_Importa_Nominas P ON CE.IdEmpresa = P.IdEmpresa AND CONVERT(Varchar, P.Fecha, 112) BETWEEN CONVERT(Varchar, CE.FechaInicio, 112) AND CONVERT(Varchar, CE.FechaFin, 112)
WHERE P.IdImportacion = @IdImportacion 
IF IsNULL(@IdEjercicio, -10000) < 0 BEGIN
	RAISERROR ('NO SE PUDO ACCEDER AL EJERCICIO DEL APUNTE.', 12, 1)
END

------------------------------------------------------------------------------------------------------------
---- DEFINICIÓN DE CUENTAS
------------------------------------------------------------------------------------------------------------

SELECT @NumDigitos = Digitos_SubCuenta FROM Conta_Ejercicios WHERE IdEjercicio = @IdEjercicio 
SET @CuentaBruto = '640' 
SET @Cuenta_G_SS = '642' 
SET @CuentaPago = '465'
SET @CuentaIRPF = '4751' + REPLICATE('0', @NumDigitos - Len('4751'))
SET @CuentaSS = '476' + REPLICATE('0', @NumDigitos - Len('476'))
SET @CuentaSS_EMP = '476' + REPLICATE('0', @NumDigitos - Len('476'))

--Las subcuentas de SS empleado y de SS empresa no estan definidas en el ERP, hay que crearlas
IF (SELECT COUNT(1) FROM Conta_SubCuentas WHERE IdEjercicio = @IdEjercicio AND Subcuenta = @CuentaIRPF) = 0 BEGIN
	RAISERROR ('NO ESTÁ DEFINIDA LA CUENTA DE IRPF EN EL EJERCICIO CONTABLE', 12, 1)
END

IF (SELECT COUNT(1) FROM Conta_SubCuentas WHERE IdEjercicio = @IdEjercicio AND Subcuenta = @CuentaSS) = 0 BEGIN
	RAISERROR ('NO ESTÁ DEFINIDA LA CUENTA DE SEGURIDAD SOCIAL DEL EMPLEADO EN EL EJERCICIO CONTABLE', 12, 1)
END

IF (SELECT COUNT(1) FROM Conta_SubCuentas WHERE IdEjercicio = @IdEjercicio AND Subcuenta = @CuentaSS_EMP) = 0 BEGIN
	RAISERROR ('NO ESTÁ DEFINIDA LA CUENTA DE SEGURIDAD SOCIAL DE LA EMPRESA EN EL EJERCICIO CONTABLE', 12, 1)
END


------------------------------------------------------------------------------------------------------------
---- PREAPARACION DE NÓMINAS : Preparamos los importes asociados con cada subcuenta (un subcuenta por empleado)
------------------------------------------------------------------------------------------------------------

INSERT INTO @IMPORTES(IdEmpleado, Importe_Bruto, Importe_Pago, Importe_SS, Empleado, CuentaBruto, CuentaPago, CuentaSS, Apunte640)
SELECT E.IdEmpleado, ROUND(ISNULL(P.Bruto, 0), 2), ROUND(ISNULL(P.Liquido, 0), 2), ROUND(ISNULL(P.Total_Coste_SS, 0), 2), P.TRABAJADOR, 
	@CuentaBruto + RIGHT(REPLICATE('0', @NumDigitos) + CAST(E.IdEmpleado as varchar), @NumDigitos - LEn(@CuentaBruto)), 
	@CuentaPago + RIGHT(REPLICATE('0', @NumDigitos) + CAST(E.IdEmpleado as varchar), @NumDigitos - LEn(@CuentaPago)),
	@Cuenta_G_SS + RIGHT(REPLICATE('0', @NumDigitos) + CAST(E.IdEmpleado as varchar), @NumDigitos - LEn(@Cuenta_G_SS))
	, ROW_NUMBER() OVER (ORDER BY E.IdEmpleado)
FROM Pers_Importa_Nominas_Lineas P 
INNER JOIN Empleados_Datos E ON P.NIF = E.NIF 
WHERE P.IdImportacion=@IdImportacion 

SELECT @Importe_IRPF = -1 * ROUND(Sum(ISNULL(P.IRPF, 0)), 2) FROM Pers_Importa_Nominas_Lineas P WHERE P.IdImportacion = @IdImportacion 
SELECT @Importe_SS_TRAB = - 1 * ROUND(Sum(ISNULL(P.SS_Trab, 0)), 2) FROM Pers_Importa_Nominas_Lineas P WHERE P.IdImportacion = @IdImportacion 
SELECT @Importe_SS_EMP = ROUND(Sum(ISNULL(P.Total_Coste_SS, 0)), 2) FROM Pers_Importa_Nominas_Lineas P WHERE P.IdImportacion = @IdImportacion 

BEGIN TRAN

------------------------------------------------------------------------------------------------------------
---- CREACIÓN DE SUBCUCENTAS QUE NO EXISTEN YA
------------------------------------------------------------------------------------------------------------

INSERT INTO Conta_SubCuentas(IdEjercicio, SubCuenta, Descrip)
SELECT DISTINCT @IdEjercicio, P.CuentaBruto, P.Empleado 
FROM @IMPORTES P
LEFT JOIN Conta_SubCuentas C ON P.CuentaBruto = C.Subcuenta AND C.IdEjercicio = @IdEjercicio 
WHERE C.Subcuenta IS NULL 

INSERT INTO Conta_SubCuentas(IdEjercicio, SubCuenta, Descrip)
SELECT DISTINCT @IdEjercicio, P.CuentaPago, P.Empleado 
FROM @IMPORTES P
LEFT JOIN Conta_SubCuentas C ON P.CuentaPago = C.Subcuenta AND C.IdEjercicio = @IdEjercicio 
WHERE C.Subcuenta IS NULL 

INSERT INTO Conta_SubCuentas(IdEjercicio, SubCuenta, Descrip)
SELECT DISTINCT @IdEjercicio, P.CuentaSS, P.Empleado 
FROM @IMPORTES P
LEFT JOIN Conta_SubCuentas C ON P.CuentaSS = C.Subcuenta AND C.IdEjercicio = @IdEjercicio 
WHERE C.Subcuenta IS NULL 

SELECT @Asiento = MAX(Asiento) FROM Conta_Apuntes WHERE IdEjercicio = @IdEjercicio 
SET @Asiento = ISNULL(@Asiento, 0) + 1

UPDATE @IMPORTES SET Asiento640 = @Asiento 

------------------------------------------------------------------------------------------------------------
---- APUNTES CONTABLES 640
------------------------------------------------------------------------------------------------------------

INSERT INTO Conta_Apuntes(IdEjercicio, Asiento, Apunte, SubCuenta, Concepto, Documento, Tipo_DH, Debe_Euros, Haber_Euros, Fecha)
SELECT @IdEjercicio, @Asiento, P.Apunte640, P.CuentaBruto, 'IMPORTACION NÓMINA', 'Nómina mes ' + CAST(Month(@Fecha) as varchar) + ' - ' + CAST(Year(@Fecha) as varchar), 
	CASE WHEN P.Importe_Bruto >= 0 THEN 'D' ELSE 'H' END, CASE WHEN P.Importe_Bruto >= 0 THEN P.Importe_Bruto ELSE 0 END, CASE WHEN P.Importe_Bruto >= 0 THEN 0 ELSE -1 * P.Importe_Bruto END, 
	@Fecha
FROM @IMPORTES P

SELECT @Apunte = Max(Apunte) FROM Conta_Apuntes WHERE IdEjercicio = @IdEjercicio AND Asiento = @Asiento

INSERT INTO Conta_Apuntes(IdEjercicio, Asiento, Apunte, SubCuenta, Concepto, Documento, Tipo_DH, Debe_Euros, Haber_Euros, Fecha)
SELECT @IdEjercicio, @Asiento, @Apunte + 1, @CuentaIRPF, 'IMPORTACION NÓMINA', 'Nómina mes ' + CAST(Month(@Fecha) as varchar) + ' - ' + CAST(Year(@Fecha) as varchar), 
	CASE WHEN @Importe_IRPF >= 0 THEN 'H' ELSE 'D' END, CASE WHEN @Importe_IRPF >= 0 THEN 0 ELSE -1 * @Importe_IRPF END, CASE WHEN @Importe_IRPF >= 0 THEN @Importe_IRPF ELSE 0 END, @Fecha
FROM @IMPORTES P
UNION
SELECT @IdEjercicio, @Asiento, @Apunte + 2, @CuentaSS, 'IMPORTACION NÓMINA', 'Nómina mes ' + CAST(Month(@Fecha) as varchar) + ' - ' + CAST(Year(@Fecha) as varchar), 
	CASE WHEN @Importe_SS_TRAB >= 0 THEN 'H' ELSE 'D' END, CASE WHEN @Importe_SS_TRAB >= 0 THEN 0 ELSE -1 * @Importe_SS_TRAB END, CASE WHEN @Importe_SS_TRAB >= 0 THEN @Importe_SS_TRAB ELSE 0 END, @Fecha
FROM @IMPORTES P

SET @Apunte = @Apunte + 2

UPDATE @IMPORTES SET Apunte465 = Apunte640 + @Apunte

INSERT INTO Conta_Apuntes(IdEjercicio, Asiento, Apunte, SubCuenta, Concepto, Documento, Tipo_DH, Debe_Euros, Haber_Euros, Fecha)
SELECT @IdEjercicio, @Asiento, P.Apunte465, P.CuentaPago, 'IMPORTACION NÓMINA', 'Nómina mes ' + CAST(Month(@Fecha) as varchar) + ' - ' + CAST(Year(@Fecha) as varchar), 
	CASE WHEN P.Importe_Pago >= 0 THEN 'H' ELSE 'D' END, CASE WHEN P.Importe_Pago >= 0 THEN 0 ELSE P.Importe_Pago END, CASE WHEN P.Importe_Pago >= 0 THEN P.Importe_Pago ELSE 0 END, 
	@Fecha
FROM @IMPORTES P

UPDATE Pers_Importa_Nominas SET IdDocApunte = C.IdDoc
FROM Pers_Importa_Nominas P
INNER JOIN Conta_Apuntes C ON C.IdEjercicio = @IdEjercicio AND C.Asiento = @Asiento AND C.Apunte = 1
WHERE P.IdImportacion = @IdImportacion 

SELECT @Asiento = MAX(Asiento) + 1 FROM Conta_Apuntes WHERE IdEjercicio = @IdEjercicio 

UPDATE @IMPORTES SET Asiento642 = @Asiento 

------------------------------------------------------------------------------------------------------------
---- APUNTES CONTABLES 642
------------------------------------------------------------------------------------------------------------

INSERT INTO Conta_Apuntes(IdEjercicio, Asiento, Apunte, SubCuenta, Concepto, Documento, Tipo_DH, Debe_Euros, Haber_Euros, Fecha)
SELECT @IdEjercicio, @Asiento, P.Apunte640, P.CuentaSS, 'IMPORTACION NÓMINA', 'Nómina mes ' + CAST(Month(@Fecha) as varchar) + ' - ' + CAST(Year(@Fecha) as varchar), 
	CASE WHEN P.Importe_SS >= 0 THEN 'D' ELSE 'H' END, CASE WHEN P.Importe_SS >= 0 THEN P.Importe_SS ELSE 0 END, CASE WHEN P.Importe_SS >= 0 THEN 0 ELSE -1 * P.Importe_SS END, 
	@Fecha
FROM @IMPORTES P

SELECT @Apunte = Max(Apunte) + 1 FROM Conta_Apuntes WHERE IdEjercicio = @IdEjercicio AND Asiento = @Asiento

INSERT INTO Conta_Apuntes(IdEjercicio, Asiento, Apunte, SubCuenta, Concepto, Documento, Tipo_DH, Debe_Euros, Haber_Euros, Fecha)
SELECT @IdEjercicio, @Asiento, @Apunte + 1, @CuentaSS_EMP, 'IMPORTACION NÓMINA', 'Nómina mes ' + CAST(Month(@Fecha) as varchar) + ' - ' + CAST(Year(@Fecha) as varchar), 
	CASE WHEN @Importe_SS_EMP >= 0 THEN 'H' ELSE 'D' END, CASE WHEN @Importe_SS_EMP >= 0 THEN 0 ELSE -1 * @Importe_SS_EMP END, CASE WHEN @Importe_SS_EMP >= 0 THEN @Importe_SS_EMP ELSE 0 END, @Fecha

UPDATE Pers_Importa_Nominas SET IdDocApunte_SS = C.IdDoc
FROM Pers_Importa_Nominas P
INNER JOIN Conta_Apuntes C ON C.IdEjercicio = @IdEjercicio AND C.Asiento = @Asiento AND C.Apunte = 1
WHERE P.IdImportacion = @IdImportacion 

------------------------------------------------------------------------------------------------------------
---- ASIGNACION CENTROS DE COSTE.
------------------------------------------------------------------------------------------------------------

/*INSERT INTO @LOSEMPLEADOS(IdEmpleado, IdCentroCoste)
SELECT DISTINCT IdEmpleado, IdCentroCoste 
FROM vPers_Empleados_Horas_CC_Porcentajes
WHERE Anyo = Year(@Fecha) AND Mes = Month(@Fecha)*/


--Miramos si la nomina que queremos contabilizar ya esta asociada a un asiento
IF (SELECT Count(*) FROM vPers_Imputacion_Empleado_Nominas WHERE IdImportacion=@IdImportacion) = 0 BEGIN
	RAISERROR ('El EXCEL DE REPARTO DE CADA EMPLEADO A CADA PROYECTO PARA ESTE MES NO HA SIDO IMPORTADO', 12, 1)
END

INSERT INTO Conta_CentrosCoste (IdCentroCoste, Descrip, Bloqueado)
SELECT DISTINCT I.IdCentroCoste, I.CC_Descrip, 0
FROM vPers_Imputacion_Empleado_Nominas I
LEFT JOIN Conta_CentrosCoste C ON I.IdCentroCoste = C.IdCentroCoste 
WHERE C.IdCentroCoste IS NULL
AND I.IdImportacion = @IdImportacion

INSERT INTO Conta_CentrosCoste_Linea(IdEjercicio, IdAsiento, IdApunte, CentroCoste, Importe_Euros)
SELECT @IdEjercicio, I.Asiento640, I.Apunte640, L.IdCentroCoste, L.Bruto_ImporteEquipo
FROM  @IMPORTES I
INNER JOIN vPers_Imputacion_Empleado_Nominas L ON I.IdEmpleado = L.IdEmpleado 
WHERE L.IdImportacion = @IdImportacion

/*INSERT INTO Conta_CentrosCoste_Linea(IdEjercicio, IdAsiento, IdApunte, CentroCoste, Importe_Euros)
SELECT @IdEjercicio, I.Asiento640, I.Apunte640, I.IdCentroCoste, ABS(I.Importe_Bruto)
FROM  @IMPORTES I
WHERE I.IdEmpleado Not IN (SELECT IdEmpleado FROM @LOSEMPLEADOS)*/

INSERT INTO Conta_CentrosCoste_Linea(IdEjercicio, IdAsiento, IdApunte, CentroCoste, Importe_Euros)
SELECT @IdEjercicio, I.Asiento642, I.Apunte640, L.IdCentroCoste, L.Total_Coste_SS_ImporteEquipo
FROM  @IMPORTES I
INNER JOIN vPers_Imputacion_Empleado_Nominas L ON I.IdEmpleado = L.IdEmpleado 
WHERE L.IdImportacion = @IdImportacion

/*INSERT INTO Conta_CentrosCoste_Linea(IdEjercicio, IdAsiento, IdApunte, CentroCoste, Importe_Euros)
SELECT @IdEjercicio, I.Asiento642, I.Apunte640, I.IdCentroCoste, ABS(I.Importe_SS)
FROM  @IMPORTES I
WHERE I.IdEmpleado Not IN (SELECT IdEmpleado FROM @LOSEMPLEADOS)*/

--AJUSTO LOS DESCUADRES ENTRE CONTABILIDAD Y ANALITICA POR REDONDEO
INSERT INTO @APUNTES_DESCUADRADOS (Asiento, Apunte, Importe)
SELECT C.Asiento, C.APunte, ROUND(CASE WHEN C.Tipo_DH = 'D' THEN C.Debe_Euros ELSE C.Haber_Euros END, 2) - ROUND(CC.Total, 2)
FROM Conta_Apuntes C
INNER JOIN @IMPORTES I ON C.IdEjercicio = @IdEjercicio AND C.Asiento = I.Asiento640 AND C.Apunte = I.Apunte640 
LEFT JOIN (SELECT C.IDEjercicio, C.IdAsiento, C.IdApunte, ROUND(Sum(IsNULL(C.Importe_Euros, 0)), 2) AS Total
			FROM Conta_CentrosCoste_Linea C 
			GROUP BY C.IDEjercicio, C.IdAsiento, C.IdApunte) CC ON C.IdEjercicio = CC.IdEjercicio AND C.Asiento = CC.IdAsiento AND C.Apunte = CC.IdApunte 
WHERE ABS(ROUND(CASE WHEN C.Tipo_DH = 'D' THEN C.Debe_Euros ELSE C.Haber_Euros END, 2) - ROUND(CC.Total, 2)) <> 0

INSERT INTO @APUNTES_DESCUADRADOS (Asiento, Apunte, Importe)
SELECT C.Asiento, C.APunte, ROUND(ROUND(CASE WHEN C.Tipo_DH = 'D' THEN C.Debe_Euros ELSE C.Haber_Euros END, 2) - ROUND(CC.Total, 2), 2)
FROM Conta_Apuntes C
INNER JOIN @IMPORTES I ON C.IdEjercicio = @IdEjercicio AND C.Asiento = I.Asiento642 AND C.Apunte = I.Apunte640 
LEFT JOIN (SELECT C.IDEjercicio, C.IdAsiento, C.IdApunte, ROUND(Sum(IsNULL(C.Importe_Euros, 0)), 2) AS Total
			FROM Conta_CentrosCoste_Linea C 
			GROUP BY C.IDEjercicio, C.IdAsiento, C.IdApunte) CC ON C.IdEjercicio = CC.IdEjercicio AND C.Asiento = CC.IdAsiento AND C.Apunte = CC.IdApunte 
WHERE ABS(ROUND(CASE WHEN C.Tipo_DH = 'D' THEN C.Debe_Euros ELSE C.Haber_Euros END, 2) - ROUND(CC.Total, 2)) <> 0

UPDATE @APUNTES_DESCUADRADOS SET IdDoc = dbo.fun_Pers_Max_CC_Importe(@IdEjercicio, Asiento, Apunte)

UPDATE Conta_CentrosCoste_Linea SET Importe_Euros = ROUND(C.Importe_Euros, 2) + ROUND(A.Importe, 2)
FROM Conta_CentrosCoste_Linea C
INNER JOIN @APUNTES_DESCUADRADOS A ON C.IdDoc = A.IdDoc

COMMIT TRAN  
    
RETURN -1 

END TRY     

BEGIN CATCH
	
	IF @@TRANCOUNT >0 BEGIN
		ROLLBACK TRAN 
	END
	
	DECLARE @CatchError NVARCHAR(MAX)
	
    SET @CatchError=dbo.funImprimeError(ERROR_MESSAGE(),ERROR_NUMBER(),ERROR_PROCEDURE(),@@PROCID ,ERROR_LINE())

    RAISERROR(@CatchError,12,1)

    RETURN 0

END CATCH