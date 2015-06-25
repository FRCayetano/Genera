USE [GENERA]
GO

/****** Object:  StoredProcedure [dbo].[pPers_Importar_Datos_ImportGasto]    Script Date: 25/06/2015 18:24:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Gaetan, COLLET>
-- Create date: <08/06/2015>
-- Description:	<Importar los datos de los gastos que vienen de las agencias>
-- =============================================
CREATE PROCEDURE [dbo].[pPers_Importar_Datos_ImportGasto] 
	-- Add the parameters for the stored procedure here
	
	@ClaveImportacion	varchar(255),
	@IdProveedor		T_Id_Proveedor
	--@Ubicacion varchar(255)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @IdLineaImportacion smallint
	DECLARE @IdProyectoAgencia varchar(255)
	DECLARE @IdProyectoERP T_Id_Proyecto
	DECLARE @IdGastoAgencia smallint
	DECLARE @Importe Real
	DECLARE @GastoAgenciaLinea smallint
	DECLARE @ImporteTotal DECIMAL

	BEGIN TRY

		DECLARE cursor_Import CURSOR FOR 
			select IdLineaImportacion, IdGastoAgencia, IdProyectoAgencia, Importe from Pers_Log_Importacion_GastoAgencia
			where ClaveImportacion = @ClaveImportacion 
				
		OPEN cursor_Import

		FETCH cursor_Import INTO @IdLineaImportacion, @IdGastoAgencia, @IdProyectoAgencia, @Importe
				
		WHILE @@FETCH_STATUS = 0
		BEGIN
					
			if EXISTS (select 1 from Pers_Proyectos_Agencias_Gastos where IdProyectoAgencia = @IdProyectoAgencia and IdProveedor = @IdProveedor)
				BEGIN
					set @IdProyectoERP = (select IdProyecto from Pers_Proyectos_Agencias_Gastos where IdProyectoAgencia = @IdProyectoAgencia)
					set @GastoAgenciaLinea = (select isnull(max(IdGastoAgenciaLinea), 0) +1 from Pers_GastosAgencia_Lineas where IdGastoAgencia = @IdGastoAgencia)
					insert into Pers_GastosAgencia_Lineas(IdGastoAgencia, IdGastoAgenciaLinea, IdProyecto, IdProyectoAgencia, Importe) 
						values (@IdGastoAgencia, @GastoAgenciaLinea, @IdProyectoERP, @IdProyectoAgencia, @Importe)
				END
			ELSE
				BEGIN
					update Pers_Log_Importacion_GastoAgencia set Texto_error = 'No existe correspondencia para el codigo de Proyecto Agencia : ' + @IdProyectoAgencia
					where IdLineaImportacion = @IdLineaImportacion and IdGastoAgencia = @IdGastoAgencia
				END

			FETCH cursor_Import INTO @IdLineaImportacion, @IdGastoAgencia, @IdProyectoAgencia, @Importe
		END
 
		CLOSE cursor_Import
		DEALLOCATE cursor_Import

		--MAJ de la fecha de importacion del excel y del importe total
		Set @ImporteTotal = (select sum(Importe) from Pers_GastosAgencia_Lineas where IdGastoAgencia = @IdGastoAgencia)

		update Pers_GastosAgencia_Cabecera set FechaImport = GETDATE() where IdGastoAgencia = @IdGastoAgencia
		update Pers_GastosAgencia_Cabecera set ImporteTotal = @ImporteTotal where IdGastoAgencia = @IdGastoAgencia

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

