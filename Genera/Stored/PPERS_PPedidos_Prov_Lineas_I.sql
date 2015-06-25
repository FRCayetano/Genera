USE [GENERA]
GO

/****** Object:  StoredProcedure [dbo].[PPERS_PPedidos_Prov_Lineas_I]    Script Date: 01/06/2015 16:46:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[PPERS_PPedidos_Prov_Lineas_I]
	@IdPedido         T_Id_Pedido		OUTPUT,
	@Precio_EURO      T_Precio			OUTPUT, 
	@Descrip          Varchar(255)      OUTPUT,
	@FechaEntrega     T_Fecha_Corta     OUTPUT,
	@IdIngresoAgencia int				OUTPUT

AS

--DECLARE                           @IdPedido									T_Id_Pedido			= 0 
DECLARE                             @IdLinea									T_Id_Linea			= 0 
DECLARE                             @IdArticulo									T_Id_Articulo       = '0' 
DECLARE                             @IdArticuloProv								T_Id_Articulo       = Null 
DECLARE                             @IdAlmacen									T_Id_Almacen		= 0 
DECLARE                             @Cantidad									T_Decimal_2			= 1 
DECLARE                             @Precio										T_Precio			= 0 
--DECLARE                           @Precio_EURO								T_Precio			= 0 
DECLARE                             @PrecioMoneda								T_Precio			= 0 
DECLARE                             @Descuento									T_Decimal			= 0 
DECLARE                             @IdIva										T_Id_Iva			= 0 
DECLARE                             @IdEstado									T_Id_Estado			= 0 
DECLARE                             @IdSituacion								T_Id_Situacion      = 0 
DECLARE                             @IdEmbalaje									T_Id_Articulo       = NULL 
DECLARE                             @CantidadEmbalaje							T_Cantidad_Embalaje = 1 
DECLARE                             @Observaciones								varchar(255)		= Null 
--DECLARE                           @Descrip									varchar(255)		= '(GENERICO)' 
DECLARE                             @IdAlbaran									T_Id_Albaran		= NULL 
DECLARE                             @FechaAlbaran								T_Fecha_Corta       = NULL 
DECLARE                             @IdFactura									T_Id_Factura		= NULL 
DECLARE                             @FechaFactura								T_Fecha_Corta       = NULL 
DECLARE                             @Lote										T_Lote				= NULL 
DECLARE                             @Marca										T_Id_Doc			= NULL 
DECLARE                             @CuentaArticulo								T_Cuenta_Corriente  = NULL 
DECLARE                             @TipoUnidadPres								T_Tipo_Cantidad     = NULL 
DECLARE                             @UnidadesStock								T_Decimal_2			= 0 
DECLARE                             @UnidadesPres								T_Decimal_2			= 1 
DECLARE                             @Precio_EuroPres							T_Precio			= 0 
DECLARE                             @PrecioMonedaPres							T_Precio			= 0 
DECLARE                             @IdProyecto_Produccion						T_Id_Proyecto_Produccion = NULL 
DECLARE                             @IdFase										T_IdFase			= NULL 
DECLARE                             @DtoLP1										T_Decimal			= 0 
DECLARE                             @DtoLP2										T_Decimal			= 0 
DECLARE                             @DtoLP3										T_Decimal			= 0 
DECLARE                             @DtoLP4										T_Decimal			= 0 
DECLARE                             @DtoLP5										T_Decimal			= 0 
DECLARE                             @DtoMan										T_Decimal			= 0 
--DECLARE                             @FechaEntrega								T_Fecha_Corta       = '20150528 00:0:00.000' 
DECLARE                             @FechaEntregaTope							T_Fecha_Corta		= @FechaEntrega 
DECLARE                             @NumPlano									varchar(50)         = NULL 
DECLARE                             @IdParte									T_Id_Parte			= NULL 
DECLARE                             @IdPacking									T_Id_Packing		= NULL 
DECLARE                             @IdDocPadre									T_Id_Doc			= NULL 
DECLARE                             @IdOrdenRecepcion							int					= NULL 
DECLARE                             @CantRecep									T_Decimal_2			= 0 
DECLARE                             @Numbultos									int					= 1 
DECLARE                             @IdEmbalajeFinal							T_Id_Articulo       = NULL 
DECLARE                             @CantidadEmbalajeFinal						T_Cantidad_Embalaje = 1 
DECLARE                             @IdEmbalaje_Disp							T_Id_Articulo       = NULL 
DECLARE                             @NumeroDeLotes								int					= 0 
DECLARE                             @CantidadLotes								T_Decimal_2         = 0 
DECLARE                             @IdOrdenCarga								int					= NULL 
DECLARE                             @UdsCarga									T_Decimal_2			= 0 
DECLARE                             @NumBultosFinal								int					= 0 
DECLARE                             @UdStockCarga								T_Decimal_2			= 0 
DECLARE                             @UdStockRecep								T_Decimal_2			= 0 
DECLARE                             @IdDoc										T_Id_Doc			= NULL 
DECLARE                             @Usuario									T_CEESI_Usuario     = NULL 
DECLARE                             @FechaInsertUpdate							T_CEESI_Fecha_Sistema = NULL


	Exec PPedidos_Prov_Lineas_I @IdPedido,
		@IdLinea,
		@IdArticulo,
		@IdArticuloProv,
		@IdAlmacen,
		@Cantidad,
		@Precio,
		@Precio_EURO,
		@PrecioMoneda,
		@Descuento,
		@IdIva,
		@IdEstado,
		@IdSituacion,
		@IdEmbalaje,
		@CantidadEmbalaje,
		@Observaciones,
		@Descrip,
		@IdAlbaran,
		@FechaAlbaran,
		@IdFactura,
		@FechaFactura,
		@Lote,
		@Marca,
		@CuentaArticulo,
		@TipoUnidadPres,
		@UnidadesStock,
		@UnidadesPres,
		@Precio_EuroPres,
		@PrecioMonedaPres,
		@IdProyecto_Produccion,
		@IdFase, 
		@DtoLP1, 
		@DtoLP2, 
		@DtoLP3, 
		@DtoLP4, 
		@DtoLP5, 
		@DtoMan, 
		@FechaEntrega,
		@FechaEntregaTope,
		@NumPlano,
		@IdParte,
		@IdPacking,@IdDocPadre,
		@IdOrdenRecepcion,
		@CantRecep,
		@Numbultos,
		@IdEmbalajeFinal,
		@CantidadEmbalajeFinal,
		@IdEmbalaje_Disp,
		@NumeroDeLotes,
		@CantidadLotes,
		@IdOrdenCarga, 
		@UdsCarga,
		@NumBultosFinal,
		@UdStockCarga ,
		@UdStockRecep,
		NULL,
		NULL,
		NULL

	update Conf_Pedidos_Prov_Lineas set Pers_IdIngresoAgencia = @IdIngresoAgencia where IdPedido = @IdPedido

	RETURN -1


GO


