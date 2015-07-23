SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<COLLET, Gaëtan>
-- Create date: <23/07/2015>
-- Description:	<Actualizar el importe total de un ingresoAgencia despues de eliminar una linea>
-- =============================================
CREATE TRIGGER [dbo].[Pers_IngresoAgencia_Lineas_DTrig] 
   ON  [dbo].[Pers_IngresoAgencia_Lineas] 
   AFTER DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @IdIngresoAgencia INT
	DECLARE @IdIngresoAgenciaLinea INT

	DECLARE cursor_majImporte CURSOR FOR
		SELECT IdIngresoAgencia, IdIngresoAgenciaLinea FROM DELETED

		OPEN cursor_majImporte
		FETCH NEXT FROM cursor_majImporte INTO @IdIngresoAgencia, @IdIngresoAgenciaLinea

		WHILE @@FETCH_STATUS = 0 BEGIN

			IF EXISTS (SELECT * FROM Pers_IngresoAgencia_Cabecera WHERE IdIngresoAgencia = @IdIngresoAgencia) BEGIN 
				UPDATE Pers_IngresoAgencia_Cabecera SET ImporteTotal = (SELECT ISNULL(SUM(Importe),0) FROM Pers_IngresoAgencia_Lineas WHERE IdIngresoAgencia = @IdIngresoAgencia)
				WHERE IdIngresoAgencia = @IdIngresoAgencia
			END

			FETCH NEXT FROM cursor_majImporte INTO @IdIngresoAgencia, @IdIngresoAgenciaLinea

		END

		CLOSE cursor_majImporte
		DEALLOCATE cursor_majImporte

END
GO
