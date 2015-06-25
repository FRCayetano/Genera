USE [GENERA]
GO

/****** Object:  StoredProcedure [dbo].[pPERS_Get_Cambio_DelDia_EuroDolar]    Script Date: 25/06/2015 18:24:27 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Gaetan, COLLET>
-- Create date: <18/06/2015>
-- Description:	<Obtener el cambio del dia desde la pagina web de la European Central Bank
--				Hay que tener en cuenta que el valor del cambio se refresque cada dia entre las dos y las tres de la tarde>
-- =============================================
CREATE PROCEDURE [dbo].[pPERS_Get_Cambio_DelDia_EuroDolar]
AS

BEGIN
	DECLARE @URL VARCHAR(8000) 
	SELECT @URL = 'http://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml'

	DECLARE @Response varchar(8000)
	DECLARE @XML xml
	DECLARE @Obj int 
	DECLARE @Result int 
	DECLARE @HTTPStatus int 
	DECLARE @ErrorMsg varchar(MAX)
	DECLARE @vXML xml

	DECLARE @DateCambio		T_Fecha_Corta
	DECLARE @CodigoISO		varchar(10)
	DECLARE @ImporteCambio	DECIMAL(18,4)

	BEGIN TRY

	/*	1- Recuperar el XML que contiene los cambios del dia desde la pagina de la European Central Bank
		2- Crear una tabla temporal para almacenar el XML para despues leerlo
		3- Recoger los nodos Cubo del XML pero filtrar sobre el USD porque solo queremos este*/
		IF OBJECT_ID('tempdb..#xml') IS NOT NULL DROP TABLE #xml
		CREATE TABLE #xml ( yourXML XML )

		EXEC @Result = sp_OACreate 'MSXML2.XMLHttp', @Obj OUT 

		EXEC @Result = sp_OAMethod @Obj, 'open', NULL, 'GET', @URL, false
		EXEC @Result = sp_OAMethod @Obj, 'setRequestHeader', NULL, 'Content-Type', 'application/x-www-form-urlencoded'
		EXEC @Result = sp_OAMethod @Obj, send, NULL, ''
		EXEC @Result = sp_OAGetProperty @Obj, 'status', @HTTPStatus OUT 

		INSERT #xml ( yourXML )

		EXEC @Result = sp_OAGetProperty @Obj, 'responseXML.xml'--, @Response OUT 

		;WITH XMLNAMESPACES(
		'http://www.gesmes.org/xml/2002-08-01' as gesmes,
		DEFAULT 'http://www.ecb.int/vocabulary/2002-08-01/eurofxref'
		)

		SELECT  @DateCambio = x.Time,
				@CodigoISO = x.Currency,
				@ImporteCambio = x.Rate
		 FROM (SELECT
		T.rows.value('@time', 'datetime') AS [Time],
		T2.rows.value('@currency', 'nvarchar(100)') AS [Currency],
		T2.rows.value('@rate', 'float') AS [Rate]
		FROM
		  #xml
		CROSS APPLY
		  yourXML.nodes('/gesmes:Envelope/Cube/*') T(rows)
		CROSS APPLY
		  T.rows.nodes('Cube') as T2(rows) )x
		WHERE x.Currency = 'USD'

		/*Comprobar que la fecha de la variable @DateCambio esta la misma que la fecha del dia, si no, no hacer nada y esperar la proxima ejecucion de la stored para actualizar el cambio*/
		if CONVERT (char(10), @DateCambio, 103) = CONVERT (char(10), getdate(), 103) AND NOT EXISTS (SELECT 1 FROM Moneda WHERE ValidezDesde = cast(getdate() As Date))
			BEGIN
				update Moneda SET ImporteVenta_EURO = @ImporteCambio, ValidezDesde = @DateCambio, ValidezHasta = @DateCambio where CodigoISO = @CodigoISO
			END

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

