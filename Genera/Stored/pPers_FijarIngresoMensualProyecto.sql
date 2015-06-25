USE [GENERA]
GO

/****** Object:  StoredProcedure [dbo].[pPers_FijarIngresoMensualProyecto]    Script Date: 25/06/2015 18:23:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		Juan Alcalde
-- Create date: 28/05/2015
-- Description:	Fija Ingreso Mensual Proyecto
-- =============================================
CREATE PROCEDURE [dbo].[pPers_FijarIngresoMensualProyecto] (

@IdPresupuesto int, 
@IdEquipo int, 
@IdProyecto int,
@IngresoMensual float
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	BEGIN try
	
		UPDATE Pers_Presupuestos_Equipos_Proyectos
		set IngresosEnero = @IngresoMensual,
		IngresosFebrero = @IngresoMensual,
		IngresosMarzo = @IngresoMensual,
		IngresosAbril = @IngresoMensual,
		IngresosMayo = @IngresoMensual,
		IngresosJunio = @IngresoMensual,
		IngresosJulio= @IngresoMensual,
		IngresosAgosto= @IngresoMensual,
		IngresosSeptiembre= @IngresoMensual,
		IngresosOctubre= @IngresoMensual,
		IngresosNoviembre= @IngresoMensual,
		IngresosDiciembre= @IngresoMensual
		where IdPresupuesto = @IdPresupuesto and IdEquipo = @IdEquipo and IdProyecto = @IdProyecto
	
	
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

