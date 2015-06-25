USE [GENERA]
GO

/****** Object:  StoredProcedure [dbo].[pPers_DespuesEliminar_IngresoLinea]    Script Date: 25/06/2015 18:22:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<COLLET, Gaetan>
-- Create date: <09/06/2015>
-- Description:	<Si se elimina una linea de un ingresoAgencia :
				-- update el campo Importe total
				-- borrar la linea de pedido cliente que coresponde a la linea de ingreso
				-- borrar la linea de pedido proveedor que coresponde a la linea de ingreso>
-- =============================================
CREATE PROCEDURE [dbo].[pPers_DespuesEliminar_IngresoLinea] 
	-- Add the parameters for the stored procedure here
	@IdCabecera				smallint,
	@IdLinea				smallint,
	@TipoObj				varchar(20),
	@Return					varchar(255) OUTPUT 
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @IdPedido		T_Id_Pedido
	DECLARE @IdLineaPed		T_Id_Linea
	DECLARE @ImporteTotal	DECIMAL

	DECLARE @IdPEdidoProv	T_Id_Pedido
	DECLARE @IdLineaPedProv	T_Id_Linea

    -- Insert statements for procedure here
	BEGIN TRY
	
		IF @TipoObj = 'IngresoAgencia'
		BEGIN
			--Definicion de las variables necesarias para identificar despues la linea de PEDIDO CLIENTE a borrar
			Set @IdPedido = (select IdPedido from Pers_IngresoAgencia_Cabecera where IdIngresoAgencia = @IdCabecera)
			Set @IdLineaPed = (select IdPedidoLinea from Pers_IngresoAgencia_Lineas where IdIngresoAgencia = @IdCabecera and IdIngresoAgenciaLinea = @IdLinea)
			Set @ImporteTotal = (select sum(Importe) from Pers_IngresoAgencia_Lineas where IdIngresoAgencia = @IdCabecera and IdIngresoAgenciaLinea <> @IdLinea)

			--Definicion de las variables necesarias para identificar despues la linea de PEDIDO PROVEEDOR a borrar
			Set @IdPedidoProv = (select IdPedidoProv from Pers_Mapeo_Ingreso_PedidoProv where IdIngresoAgencia = @IdCabecera and IdIngresoAgenciaLinea = @IdLinea)
			Set @IdLineaPedProv = (select IdLinea from Pers_Mapeo_Ingreso_PedidoProv where IdIngresoAgencia = @IdCabecera and IdIngresoAgenciaLinea = @IdLinea)

			--Update el campo Importe total despues de borrar una linea de IngresoAgenciaLinea
			update Pers_IngresoAgencia_Cabecera set ImporteTotal = @ImporteTotal where IdIngresoAgencia = @IdCabecera

			--BORRAR PEDIDO PROVEEDOR
			---------------------------------------------------------------------------------------------------------------------------------------------------------
			IF EXISTS (select Idpedido from Pedidos_Prov_Lineas where Idpedido = @IdPedidoProv and IdLinea = @IdLineaPedProv)
			BEGIN
				delete from Pedidos_Prov_Lineas where Idpedido = @IdPedidoProv and IdLinea = @IdLineaPedProv
			END

			IF (select count(1) from Pedidos_Prov_Lineas where IdPedido = @IdPedidoProv) = 0
			BEGIN
				delete from Pedidos_Prov_Cabecera where IdPedido = @IdPedidoProv
			END
			---------------------------------------------------------------------------------------------------------------------------------------------------------

			--BORRAR PEDIDO CLIENTE
			---------------------------------------------------------------------------------------------------------------------------------------------------------
			IF (select IdEstado from Pedidos_Cli_Lineas where IdPedido = @IdPedido and IdLinea = @IdLineaPed) > 0
				BEGIN
					PRINT dbo.Traducir(14178, 'Imposible eliminar líneas de Pedido facturadas')
					RETURN 0
				END

			--El pedido no tiene mas lineas, borramos
			IF @IdLineaPed = 0 And @IdPedido <> 0
			BEGIN
				delete from Pedidos_Cli_Cabecera where IdPedido = @IdPedido
				update Pers_IngresoAgencia_Cabecera set IdPedido = 0 where IdIngresoAgencia = @IdCabecera
			END

			--El pedido tiene lineas, borramos la linea asociada a la linea del ingresoAgencia
			IF @IdLineaPed <> 0 And @IdPedido <> 0
			BEGIN
				IF (select IdEstado from Pedidos_Cli_Lineas where IdPedido = @IdPedido and IdLinea = @IdLineaPed) = 0
				BEGIN
					delete from Pedidos_Cli_Lineas where IdPEdido = @IdPedido and IdLinea = @IdLineaPed
					update Pers_IngresoAgencia_Lineas set IdPedidoLinea = 0 where IdIngresoAgencia = @IdCabecera and IdIngresoAgenciaLinea = @IdLinea
				END				
			END

			--Conprobacion final para averiguar que despues de las supreciones, queda un pedido sin lineas
			IF (select count(IdLinea) from Pedidos_Cli_Lineas where IdPedido = @IdPedido) = 0
			BEGIN
				delete from Pedidos_Cli_Cabecera where IdPedido = @IdPedido
				update Pers_IngresoAgencia_Cabecera set IdPedido = 0 where IdIngresoAgencia = @IdCabecera
			END
			---------------------------------------------------------------------------------------------------------------------------------------------------------
			RETURN -1
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
END
GO

