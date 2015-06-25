USE [GENERA]
GO

/****** Object:  StoredProcedure [dbo].[pPers_FijarGastoOtrosMensual]    Script Date: 25/06/2015 18:23:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		Juan Alcalde
-- Create date: 28/05/2015
-- Description:	Fija Gasto Otros Equipo Mensual
-- =============================================
CREATE PROCEDURE [dbo].[pPers_FijarGastoOtrosMensual] (

@IdPresupuesto int, 
@IdEquipo int, 
@IdTipoGasto varchar(10),
@GastoMensual float
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	BEGIN try
	
		UPDATE Pers_Presupuestos_Equipos_Gastos
		set GastosEnero = @GastoMensual,
		GastosFebrero = @GastoMensual,
		GastosMarzo = @GastoMensual,
		GastosAbril = @GastoMensual,
		GastosMayo = @GastoMensual,
		GastosJunio = @GastoMensual,
		GastosJulio= @GastoMensual,
		GastosAgosto= @GastoMensual,
		GastosSeptiembre= @GastoMensual,
		GastosOctubre= @GastoMensual,
		GastosNoviembre= @GastoMensual,
		GastosDiciembre= @GastoMensual
		where IdPresupuesto = @IdPresupuesto and IdEquipo = @IdEquipo  and IdTipoGasto = @IdTipoGasto
	
	
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
	
END




GO

