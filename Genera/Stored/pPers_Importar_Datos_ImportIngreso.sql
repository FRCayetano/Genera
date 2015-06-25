USE [GENERA]
GO

/****** Object:  StoredProcedure [dbo].[pPers_Importar_Datos_ImportIngreso]    Script Date: 25/06/2015 18:24:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Gaetan, COLLET>
-- Create date: <05/06/2015>
-- Description:	<Importar los datos de los ingresos antes de importar>
-- =============================================
CREATE PROCEDURE [dbo].[pPers_Importar_Datos_ImportIngreso] 
	-- Add the parameters for the stored procedure here
	
	@ClaveImportacion varchar(255),
	@IdCliente	T_Id_Cliente
	--@Ubicacion varchar(255)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @IdLineaImportacion smallint
	DECLARE @IdProyectoAgencia varchar(255)
	DECLARE @IdProyectoERP T_Id_Proyecto
	DECLARE @IdIngresoAgencia smallint
	DECLARE @Importe Real
	DECLARE @IngresoAgenciaLinea smallint
	DECLARE @ImporteTotal DECIMAL

	BEGIN TRY

		DECLARE cursor_Import CURSOR FOR 
						select IdLineaImportacion, IdIngresoAgencia, IdProyectoAgencia, Importe from Pers_Log_Importacion_IngresoAgencia
						where ClaveImportacion = @ClaveImportacion 
				
		OPEN cursor_Import

		FETCH cursor_Import INTO @IdLineaImportacion, @IdIngresoAgencia, @IdProyectoAgencia, @Importe
				
		WHILE @@FETCH_STATUS = 0
		BEGIN
					
			if EXISTS (select 1 from Pers_Proyectos_Agencias_Ingresos where IdProyectoAgencia = @IdProyectoAgencia and IdCliente = @IdCliente)
				BEGIN
					set @IdProyectoERP = (select IdProyecto from Pers_Proyectos_Agencias_Ingresos where IdProyectoAgencia = @IdProyectoAgencia and IdCliente = @IdCliente)
					set @IngresoAgenciaLinea = (select isnull(max(IdIngresoAgenciaLinea), 0) +1 from Pers_IngresoAgencia_Lineas where IdIngresoAgencia = @IdIngresoAgencia)
					insert into Pers_IngresoAgencia_Lineas(IdIngresoAgencia, IdIngresoAgenciaLinea, IdProyecto, IdProyectoAgencia, Importe) 
						values (@IdIngresoAgencia, @IngresoAgenciaLinea, @IdProyectoERP, @IdProyectoAgencia, @Importe)
				END

			ELSE
				BEGIN
					update Pers_Log_Importacion_IngresoAgencia set Texto_error = 'No existe correspondencia para el codigo de Proyecto Agencia : ' + @IdProyectoAgencia
					where IdLineaImportacion = @IdLineaImportacion and IdIngresoAgencia = @IdIngresoAgencia
				END	
			FETCH cursor_Import INTO @IdLineaImportacion, @IdIngresoAgencia, @IdProyectoAgencia, @Importe
		END
 
		CLOSE cursor_Import
		DEALLOCATE cursor_Import

		--MAJ de la fecha de importacion del excel y del importe total
		Set @ImporteTotal = (select sum(Importe) from Pers_IngresoAgencia_Lineas where IdIngresoAgencia = @IdIngresoAgencia)

		update Pers_IngresoAgencia_Cabecera set FechaImport = GETDATE() where IdIngresoAgencia = @IdIngresoAgencia
		update Pers_IngresoAgencia_Cabecera set ImporteTotal = @ImporteTotal where IdIngresoAgencia = @IdIngresoAgencia

		return -1

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

