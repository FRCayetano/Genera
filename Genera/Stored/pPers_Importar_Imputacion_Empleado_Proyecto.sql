SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[pPers_Importar_Imputacion_Empleado_Proyecto] (@IdImportacion int, @Retorno varchar(400) OUTPUT) AS

BEGIN TRY

DECLARE @Valores TABLE (Valor varchar(100))
DECLARE @EMPLEADO varchar(100)

IF (SELECT COUNT(*) FROM ( 
		SELECT IdEmpleado, SUM(PorcentajeDedic) Porcent
		FROM Pers_Importa_Dedicacion_Empleado_Proyecto_Lineas 
		WHERE IdImportacion = @IdImportacion
		GROUP BY IdEmpleado
		HAVING SUM(PorcentajeDedic) > 100 or SUM(PorcentajeDedic) < 100
		)tbo ) > 0 BEGIN

	INSERT INTO @Valores (Valor)
	SELECT LEFT(tbo.Apellidos, 100)
	FROM ( 
		SELECT l.IdEmpleado, SUM(PorcentajeDedic) Porcent, e.Apellidos
		FROM Pers_Importa_Dedicacion_Empleado_Proyecto_Lineas l
		INNER JOIN Empleados_Datos E ON E.IdEmpleado = l.IdEmpleado
		WHERE IdImportacion = 1
		GROUP BY l.IdEmpleado, e.Apellidos
		HAVING SUM(PorcentajeDedic) > 100 or SUM(PorcentajeDedic) < 100
		)tbo 

	WHILE (SELECT COUNT(1) FROM @Valores) > 0 BEGIN
		SELECT TOP 1 @EMPLEADO = Valor FROM @Valores 
		IF LEN(ISNULL(@Retorno, '')) < 400 BEGIN
			SET @Retorno = ISNULL(@Retorno, '') + @EMPLEADO + char(13)
		END
		DELETE FROM @Valores WHERE Valor = @EMPLEADO 
	END

	RAISERROR ('EXISTEN TRABAJADORES CUYO LA SUMATORIA DE LOS PORCENTAJES ES DESIGUAL DE 100.', 12, 1)
END

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
