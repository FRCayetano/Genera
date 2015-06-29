USE [GENERA]
GO
/****** Object:  StoredProcedure [dbo].[PPers_PPedidos_Cli_Lineas_I]    Script Date: 29/06/2015 18:21:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 
ALTER PROCEDURE [dbo].[PPers_PPedidos_Cli_Lineas_I]
@IdPedido				T_Id_Pedido		OUTPUT,
@Precio_EURO			T_Precio		OUTPUT,
@PrecioMoneda			T_Precio		OUTPUT,
@Descrip				varchar(255)	OUTPUT,
@Fecha					T_Fecha_Corta	OUTPUT,
@IdIngresoAgencia		int				OUTPUT
--@IdIngresoAgenciaLinea	int				OUTPUT,
--@IdProyecto				T_Id_Proyecto	OUTPUT

AS

BEGIN

	--DECLARE @IdPedido               T_Id_Pedido --Param de la stored
	DECLARE @IdLinea                T_Id_Linea
	DECLARE @IdArticulo             T_Id_Articulo = 0 
	DECLARE @IdArticuloCli          T_Id_Articulo = NULL 
	DECLARE @IdAlmacen              T_Id_Almacen = 0
	DECLARE @Cantidad               T_Decimal_2 = 1
	DECLARE @Precio                 T_Precio = 0 --Param de la stored
	--DECLARE @Precio_EURO            T_Precio = @PrecioMoneda 
	--DECLARE @PrecioMoneda           T_Precio = 0
	DECLARE @Descuento              T_Decimal = 0
	DECLARE @IdIva                  T_Id_Iva = 0
	DECLARE @IdEstado               T_Id_Estado = 0
	DECLARE @IdSituacion            T_Id_Situacion = 0 
	DECLARE @IdEmbalaje             T_Id_Articulo = NULL 
	DECLARE @CantidadEmbalaje       T_Cantidad_Embalaje = 0
	DECLARE @Observaciones          Varchar(255) = NULL  
	--DECLARE @Descrip                Varchar(255) = NULL  --Param de la stored
	DECLARE @Comision               T_Decimal = 0
	DECLARE @IdAlbaran              T_Id_Albaran = NULL 
	DECLARE @FechaAlbaran           T_Fecha_Corta = NULL 
	DECLARE @IdFactura              T_Id_Factura = NULL 
	DECLARE @FechaFactura           T_Fecha_Corta = NULL 
	DECLARE @CantidadLotes          T_Decimal_2 = NULL 
	DECLARE @Marca                  T_Id_Doc = NULL 
	DECLARE @EmbalajeFinal          T_Id_Articulo = NULL 
	DECLARE @CantidadEmbalajeFinal  T_Cantidad_Embalaje = 0
	DECLARE @Descrip2               Varchar(255) = NULL 
	DECLARE @PesoNeto               T_Decimal_2 = 0
	DECLARE @PesoEmbalaje           T_Decimal_2 = 0 
	DECLARE @PesoEmbalajeFinal      T_Decimal_2 = 0          
	DECLARE @Orden                  int = 0         
	DECLARE @TotalComision          T_Decimal = 0 
	DECLARE @Path                   varchar(50) = NULL  
	DECLARE @DtoLP1                 T_Decimal = 0 
	DECLARE @DtoLP2                 T_Decimal = 0 
	DECLARE @DtoGD                  T_Decimal = 0 
	DECLARE @DtoMan                 T_Decimal = 0 
	DECLARE @ConjManual             T_Booleano = 0
	DECLARE @IdDocPadre             T_Id_Doc = NULL  
	DECLARE @IdFase                 T_IdFase = NULL 
	DECLARE @IdProyecto_Produccion  T_Id_Proyecto_Produccion = NULL 
	DECLARE @CuentaArticulo         T_Cuenta_Corriente = NULL 
	DECLARE @TipoUnidadPres         T_Tipo_Cantidad = NULL 
	DECLARE @UnidadesStock          T_Decimal_2 = 0 
	DECLARE @UnidadesPres           T_Decimal_2 = 0 
	DECLARE @Precio_EuroPres        T_Precio = 0 
	DECLARE @PrecioMonedaPres       T_Precio = 0 
	DECLARE @IdOrdenCarga           int = NULL 
	DECLARE @IdOferta               T_Id_Oferta = NULL 
	DECLARE @Revision               smallint = NULL 
	DECLARE @IdOfertaLinea          T_Id_Linea = NULL 
	DECLARE @RefCliente             Varchar(50) = NULL
	DECLARE @NumPlano               Varchar(50) = NULL
	DECLARE @IdParte                T_Id_Parte = NULL 
	DECLARE @IdSeguimiento          int = NULL 
	DECLARE @IdConceptoCertif       int = NULL  
	DECLARE @NumBultos              int = NULL  
	DECLARE @IdTipoOperacion        smallint = NULL 
	DECLARE @IdFacturaCertif        T_Id_Factura = 0 
	DECLARE @UdsCarga               T_Decimal_2 = 0
	DECLARE @IdEmbalaje_Disp        T_Id_Articulo = NULL 
	DECLARE @IdOrdenRecepcion       int = NULL 
	DECLARE @CantRecep              float = 0 
	DECLARE @NumBultosFinal         int = 0 
	DECLARE @DtoLP3                 T_Decimal = 0 
	DECLARE @DtoLP4                 T_Decimal = 0 
	DECLARE @DtoLP5                 T_Decimal = 0  
	DECLARE @UdStockCarga           T_Decimal_2 = NULL
	DECLARE @UdStockRecep           T_Decimal_2 = NULL
	DECLARE @IdMaquina				T_Id_Articulo = NULL 
	DECLARE @IdDoc                  T_Id_Doc = NULL      
	DECLARE @Usuario                T_CEESI_Usuario = NULL 
	DECLARE @FechaInsertUpdate      T_CEESI_Fecha_Sistema = NULL
 
    BEGIN TRY
 
		exec PPedidos_Cli_Lineas_I
			  @IdPedido   OUTPUT      ,
			  @IdLinea    OUTPUT      ,
			  @IdArticulo             ,
			  @IdArticuloCli          ,
			  @IdAlmacen              ,
			  @Cantidad               ,
			  @Precio                 ,
			  @Precio_EURO            ,
			  @PrecioMoneda           ,
			  @Descuento              ,
			  @IdIva                  ,
			  @IdEstado               ,
			  @IdSituacion            ,
			  @IdEmbalaje             ,
			  @CantidadEmbalaje       ,
			  @Observaciones          ,
			  @Descrip	OUTPUT		  ,
			  @Comision				  ,
			  @IdAlbaran			  ,
			  @FechaAlbaran			  ,
			  @IdFactura              ,
			  @FechaFactura			  ,
			  @CantidadLotes		  ,
			  @Marca                  ,
			  @EmbalajeFinal          ,
			  @CantidadEmbalajeFinal  ,
			  @Descrip2               ,
			  @PesoNeto               ,
			  @PesoEmbalaje           ,
			  @PesoEmbalajeFinal      ,        
			  @Orden                  ,        
			  @TotalComision		  ,
			  @Path                   ,
			  @DtoLP1                 ,
			  @DtoLP2				  ,
			  @DtoGD                  ,
			  @DtoMan                 ,
			  @ConjManual             ,
			  @IdDocPadre             ,
			  @IdFase                 ,
			  @IdProyecto_Produccion  ,
			  @CuentaArticulo         ,
			  @TipoUnidadPres         ,
			  @UnidadesStock          ,
			  @UnidadesPres           ,
			  @Precio_EuroPres        ,
			  @PrecioMonedaPres       ,
			  @IdOrdenCarga           ,
			  @IdOferta               ,
			  @Revision               ,
			  @IdOfertaLinea          ,
			  @RefCliente             ,
			  @NumPlano               ,
			  @IdParte                ,
			  @IdSeguimiento          ,
			  @IdConceptoCertif       ,
			  @NumBultos              ,
			  @IdTipoOperacion        ,
			  @IdFacturaCertif        ,
			  @UdsCarga               ,
			  @IdEmbalaje_Disp        ,
			  @IdOrdenRecepcion       ,
			  @CantRecep              ,
			  @NumBultosFinal         ,
			  @DtoLP3                 ,
			  @DtoLP4                 ,
			  @DtoLP5                 , 
			  @UdStockCarga			  ,
			  @UdStockRecep			  ,
			  @IdMaquina			  ,
			  @IdDoc	OUTPUT		  ,
			  @Usuario				  ,
			  @FechaInsertUpdate

			  --Añadir la fecha de imputacion del ingreso

			  update Conf_Pedidos_Cli_Lineas set pFechaIngreso = @Fecha where IdPedido = @Idpedido and IdLinea = @IdLinea

			  --Añadir la linea de pedido asociada a la linea de IngresoAgencia actual

			  --update Pers_IngresoAgencia_Lineas set IdPedidoLinea = @IdLinea where IdIngresoAgencia = @IdIngresoAgencia and IdProyecto = @IdProyecto

			  /*************************************************************************************************************
											Ejucatar stored para hacer el desgloce analitico
			  *************************************************************************************************************/
			  DECLARE	@Objeto varchar(50) = 'Pedido_Linea'

			  Exec PPERS_DesgloceLinea_Pedidos
					@Objeto,
					@IdPedido,
					@IdLinea, 
					@IdDoc,
					@Fecha,
					@Descrip

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

