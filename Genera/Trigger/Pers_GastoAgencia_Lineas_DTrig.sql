SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<COLLET, Gaëtan>
-- Create date: <23/07/2015>
-- Description:	<Actualizar el importe total de un GastosAgencia despues de eliminar una linea>
-- =============================================
CREATE TRIGGER [dbo].[Pers_GastoAgencia_Lineas_DTrig] 
   ON  [dbo].[Pers_GastosAgencia_Lineas] 
   AFTER DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DECLARE @IdGastoAgencia INT
	DECLARE @IdGastoAgenciaLinea INT

	DECLARE cursor_majImporte CURSOR FOR
		SELECT IdGastoAgencia, IdGastoAgenciaLinea FROM DELETED

		OPEN cursor_majImporte
		FETCH NEXT FROM cursor_majImporte INTO @IdGastoAgencia, @IdGastoAgenciaLinea

		WHILE @@FETCH_STATUS = 0 BEGIN

			IF EXISTS (SELECT * FROM Pers_GastosAgencia_Cabecera WHERE IdGastoAgencia = @IdGastoAgencia) BEGIN 
				UPDATE Pers_GastosAgencia_Cabecera SET ImporteTotal = (SELECT ISNULL(SUM(Importe),0) FROM Pers_GastosAgencia_Lineas WHERE IdGastoAgencia = @IdGastoAgencia)
				WHERE IdGastoAgencia = @IdGastoAgencia
			END

			FETCH NEXT FROM cursor_majImporte INTO @IdGastoAgencia, @IdGastoAgenciaLinea

		END

		CLOSE cursor_majImporte
		DEALLOCATE cursor_majImporte

END
GO
