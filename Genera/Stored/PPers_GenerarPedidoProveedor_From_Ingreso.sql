USE [GENERA]
GO

/****** Object:  StoredProcedure [dbo].[PPers_GenerarPedidoProveedor_From_Ingreso]    Script Date: 01/06/2015 16:42:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

 
CREATE PROCEDURE [dbo].[PPers_GenerarPedidoProveedor_From_Ingreso]
	@IdEmpresa			T_Id_Empresa		OUTPUT	,                 
    @Fecha 				T_Fecha_Corta		OUTPUT	,
    @IdEmpleado 		T_Id_Empleado		OUTPUT	,
    @IdDepartamento		T_Id_Departamento	OUTPUT	,     
    @IdIngresoAgencia	int 				OUTPUT	,
    @IdProyecto 		T_Id_Proyecto		OUTPUT	,
	@ImporteProyecto	T_Precio			OUTPUT	,
	@DescripcionPed		varchar(255)		OUTPUT

AS

/***********************************************************************************************************************
									Declaracion de la variables y inicializacion
************************************************************************************************************************/

	DECLARE		@IdPedido			T_Id_Pedido = 0
	--DECLARE	  @IdEmpresa		T_Id_Empresa = 0
	DECLARE		@AnoNum				T_AñoNum = 1999
	DECLARE		@NumPedido			T_Id_Pedido = 0
	--DECLARE		@Fecha			T_Fecha_Corta = GETDATE()
	DECLARE		@IdProveedor		T_Id_Proveedor
	DECLARE		@IdPedidoProv		varchar(50) = NULL
	DECLARE		@IdContacto			int = 8
	--DECLARE		@DescripcionPed	varchar(255) = NULL
	DECLARE		@IdLista			T_Id_Lista = 0
	--DECLARE		@IdEmpleado		T_Id_Empleado = NULL
	--DECLARE		@IdDepartamento	T_Id_Departamento = NULL
	DECLARE		@IdTransportista	T_Id_Proveedor = NULL
	DECLARE		@IdMoneda			T_Id_Moneda = 0
	DECLARE		@FormaPago			T_Forma_Pago = 0
	DECLARE		@Descuento			Real = 0
	DECLARE		@ProntoPago			Real = 0
	DECLARE		@IdPortes			T_Id_Portes = 'D'
	DECLARE		@IdIva				T_Id_Iva = 0
	DECLARE		@IdEstado			T_Id_Estado = 0
	DECLARE		@IdSituacion		T_Id_Situacion = 0
	DECLARE		@FechaEntrega		T_Fecha_Corta = @Fecha
	DECLARE		@FechaEntregaTope	T_Fecha_Corta = @Fecha
	DECLARE		@Observaciones		varchar(255) = NULL
	DECLARE		@IdCentroCoste		T_Id_CentroCoste = NULL
	DECLARE		@IdCentroProd		T_CentroProductivo = NULL
	DECLARE		@IdCentroImp		T_CentroImponible = NULL
	DECLARE		@Codigo				varchar(50) = NULL
	DECLARE		@Cambio				T_Precio  = NULL
	DECLARE		@CambioEuros		T_Precio = 0
	DECLARE		@CambioBloqueado	T_Booleano = 0
	DECLARE		@Confirmado			T_Booleano = 0
	DECLARE		@IdCentroCalidad	T_CentroCalidad = NULL
	--DECLARE		@IdProyecto		T_Id_Proyecto = '1'
	DECLARE		@Inmovilizado		T_Booleano = 0
	DECLARE		@SeriePedido		T_Serie = 0
	DECLARE		@Bloqueado			T_Booleano = 0
	DECLARE		@IdMotivoBloqueo	int  = NULL
	DECLARE		@IdEmpleadoBloqueo	T_Id_Empleado  = NULL
	DECLARE		@IdOrden			T_Id_Orden = 0
	DECLARE		@IdBono				T_Id_Bono = NULL
	DECLARE		@EnvioAObra			T_Booleano = 0
	DECLARE		@IdTipoProv			T_Id_Tipo = 0
	DECLARE 	@PorcentajeProveedor Real

	DECLARE		@Precio_euro		T_Precio = 0

	Declare		@Msg_err			Varchar(255)
	DECLARE		@P0					nvarchar(1000)
	DECLARE		@CadenaStr			nvarchar(4000)	

/***********************************************************************************************************************
	Comprobacion para ver si existe un tercero asociado a ese proyecto
		Si existe : continuar la creacion de pedido
		Si no existe : no hacer nada
************************************************************************************************************************/

		--Recuparar el ID del proveedor asociado al proyecto @IdProyecto
		select @IdProveedor = ISNULL(Pers_IdTercero, -1) from Conf_Proyectos where IdProyecto = @IdProyecto

		IF (@IdProveedor = -1)
			BEGIN	
				SET @P0 = Convert(Varchar,@IdProyecto)
				SET @CadenaStr = dbo.Traducir(20046, 'No existe tercero para el proyecto: %v')
				exec sprintf @Msg_err OUT, @CadenaStr, @P0

				PRINT @Msg_err
				RETURN 0
		END

		if(@IdContacto is null or @IdContacto = '')
			set @IdContacto = (Select IdContacto from Prov_Datos where IdProveedor = @IdProveedor)
               

		--Recuparar el % del proveedor asociado al proyecto @IdProyecto
		select @PorcentajeProveedor = Pers_PercentajeTercero from Conf_Proyectos where IdProyecto = @IdProyecto
		
		--print @PorcentajeProveedor
		
		Set @Precio_euro = @ImporteProyecto * (@PorcentajeProveedor / 100)

/***********************************************************************************************************************
						Comprobacion para ver si ya existe un pedido abierto y ni facturado para ese tercero
						Si ya existe : añadir una nueva linea
						Si no existe : crear un nuevo pedido
************************************************************************************************************************/

	select @IdPedido = cab.Idpedido from Pedidos_Prov_Cabecera cab inner join Pedidos_Prov_Lineas li on cab.IdPedido = li.IdPedido where cab.IdProveedor = @IdProveedor and (li.IdEstado between 0 and 6 )

	IF (@IdPedido = 0)
		BEGIN
		/***********************************************************************************************************************
			Llamar a la stored estandar para crear la cabecerra de pedido proveedor
		************************************************************************************************************************/

		Declare @vRet int
		Exec @vRet = pPedidos_Prov_Cabecera_I @IdPedido OUTPUT	,
											  @IdEmpresa 		,
											  @AnoNum			,
											  @NumPedido		,
											  @Fecha			,
											  @IdProveedor		,
											  @IdPedidoProv		,
											  @IdContacto		,
											  @DescripcionPed	,
											  @IdLista			,
											  @IdEmpleado		,
											  @IdDepartamento	,
											  @IdTransportista	,
											  @IdMoneda			,
											  @FormaPago		,
											  @Descuento		,
											  @ProntoPago		,
											  @IdPortes			,
											  @IdIva			,
											  @IdEstado			,
											  @IdSituacion		,
											  @FechaEntrega		,
											  @FechaEntregaTope	,
											  @Observaciones	,
											  @IdCentroCoste	,
											  @IdCentroProd		,
											  @IdCentroImp		,
											  @Codigo			,
											  @Cambio			,
											  @CambioEuros		,
											  @CambioBloqueado	,
											  @Confirmado		,
											  @IdCentroCalidad	,
											  @IdProyecto		,
											  @Inmovilizado		,
											  @SeriePedido		,
											  @Bloqueado		,
											  @IdMotivoBloqueo	,
											  @IdEmpleadoBloqueo,
											  @IdOrden			,
											  @IdBono			,
											  @EnvioAObra		,
											  @IdTipoProv		,
											  NULL				,
											  NULL				,
											  NULL


			Exec PPERS_PPedidos_Prov_Lineas_I @IdPedido, @Precio_EURO, @DescripcionPed, @FechaEntrega, @IdIngresoAgencia

			RETURN -1
		END
		ELSE

			Exec PPERS_PPedidos_Prov_Lineas_I @IdPedido, @Precio_EURO, @DescripcionPed, @FechaEntrega, @IdIngresoAgencia

			RETURN -1
GO


