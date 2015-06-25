USE [GENERA]
GO

/****** Object:  StoredProcedure [dbo].[PPers_GenerarPedidoProveedor_From_Gastos]    Script Date: 25/06/2015 18:24:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


 
CREATE PROCEDURE [dbo].[PPers_GenerarPedidoProveedor_From_Gastos]
	@IdEmpresa				T_Id_Empresa		OUTPUT	,
	@IdProveedor			T_Id_Proveedor		OUTPUT	,			                 
    @Fecha 					T_Fecha_Corta		OUTPUT	,
    @IdEmpleado 			T_Id_Empleado		OUTPUT	,
    @IdDepartamento			T_Id_Departamento	OUTPUT	,     
    @IdGastoAgencia			int 				OUTPUT	,
	@IdMoneda				int					OUTPUT

AS
BEGIN
/***********************************************************************************************************************
									Declaracion de la variables y inicializacion blabla
************************************************************************************************************************/

	DECLARE		@IdPedido			T_Id_Pedido = 0
	--DECLARE	  @IdEmpresa		T_Id_Empresa = 0
	DECLARE		@AnoNum				T_AñoNum = 1999
	DECLARE		@NumPedido			T_Id_Pedido = 0
	--DECLARE		@Fecha			T_Fecha_Corta = GETDATE()
	--DECLARE		@IdProveedor		T_Id_Proveedor
	DECLARE		@IdPedidoProv		varchar(50) = NULL
	DECLARE		@IdContacto			int = 8
	DECLARE		@DescripcionPed	varchar(255) = NULL
	DECLARE		@IdLista			T_Id_Lista = 0
	--DECLARE		@IdEmpleado		T_Id_Empleado = NULL
	--DECLARE		@IdDepartamento	T_Id_Departamento = NULL
	DECLARE		@IdTransportista	T_Id_Proveedor = NULL
	--DECLARE		@IdMoneda			T_Id_Moneda = 0
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
	DECLARE		@CambioEuros		T_Precio = 1
	DECLARE		@CambioBloqueado	T_Booleano = 0
	DECLARE		@Confirmado			T_Booleano = 0
	DECLARE		@IdCentroCalidad	T_CentroCalidad = NULL
	DECLARE		@IdProyecto			T_Id_Proyecto = NULL
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

	--Datos necesarios para generar las lineas
	DECLARE		@IdProyectoLin			T_id_proyecto
	DECLARE		@ImporteProyecto		Real
	DECLARE		@DescripProyecto		varchar(max)
	DECLARE		@TipoImport				varchar(255) = 'Gasto'
	DECLARE		@IdGastoAgenciaLinea	int
	DECLARE		@IdMonedaProveedor		T_Id_Moneda
	DECLARE @CambioDelDia					DECIMAL(18,4)

	SET @CambioDelDia = (
			SELECT Cambio
			FROM funDameCambioMoneda(2, GETDATE())
			)

	if(@IdContacto is null or @IdContacto = '')
		set @IdContacto = (Select IdContacto from Prov_Datos where IdProveedor = @IdProveedor)       

	Set @DescripcionPed = 'Generado desde Gasto numero : '+cast(@IdGastoAgencia as varchar)

	Set @IdMonedaProveedor = (Select IdMoneda from Prov_Datos_Economicos where IDProveedor = @IdProveedor)

	BEGIN TRY

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
												  @IdMonedaProveedor,
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
												  @CambioDelDia		,
												  @CambioDelDia		,
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


		--Asignar el numero de pedido proveedor generado a la cabecera de GastoAgencia
		update Pers_GastosAgencia_Cabecera set IdPedidoProv = @IdPedido where IdGastoAgencia = @IdGastoAgencia

		/*********************************************************************************************************************************
		Declare un cursor para recuperar todas las lineas del ingreso actual
		Para cada una de las lineas, llamar a la stored pPers_PPedidos_Cli_Lineas_I para crear una linea de pedido
		**********************************************************************************************************************************/
			
		--CURSOR PARA CREAR LAS LINEAS DEL PEDIDO CREADO
		--PARA CADA LINEA (PROYECTO) UPDATE EL CAMPO GASTOS PENDIENTES
		DECLARE @Old_Pers_GastosAcumulado		DECIMAL
		DECLARE @IdTercero						T_Id_Proveedor
		DECLARE @ImporteGastoTercero			DECIMAL
		DECLARE @PorcentajeTercero				DECIMAL
		DECLARE @IdLineaMovimientoHistorico		INT
		DECLARE @IdMonedaProyecto				INT
		DECLARE @PrecioMoneda					T_Precio
		DECLARE	@Precio_euro					T_Precio

		DECLARE cursor_gastosAgenciaLineas CURSOR FOR 
			select distinct il.IdProyecto, il.Importe, 'Proyecto '+p.Descrip+' : ' + il.IdProyecto, il.IdGastoAgenciaLinea
			from Pers_GastosAgencia_Lineas il
			inner join Proyectos p on il.IdProyecto = p.IdProyecto
			where il.IdGastoAgencia = @IdGastoAgencia
				
		OPEN cursor_gastosAgenciaLineas
		FETCH cursor_gastosAgenciaLineas INTO @IdProyectoLin, @ImporteProyecto, @DescripProyecto, @IdGastoAgenciaLinea
				
		WHILE @@FETCH_STATUS = 0
		BEGIN

			IF @IdMonedaProveedor > 1
			BEGIN
				SET @Precio_EURO = 0
				SET @PrecioMoneda = @ImporteProyecto

				--Si la moneda del Excel es el euro, convert el importe porque queremos crear un pedido en dolare
				IF @IdMoneda = 1
				BEGIN
					SET @PrecioMoneda = (@PrecioMoneda * @CambioDelDia)
				END
		END

			IF @IdMonedaProveedor = 1
			BEGIN
				--Si la moneda del excel nos viene en dolare, convert el importe en EURO
				IF @IdMoneda > 1
				BEGIN
					SET @Precio_EURO = @ImporteProyecto / @CambioDelDia
				END

				IF @IdMoneda = 1
				BEGIN
					SET @Precio_EURO = @ImporteProyecto
				END

				SET @PrecioMoneda = @Precio_EURO
			END

			Exec PPERS_PPedidos_Prov_Lineas_I @IdPedido, @Precio_EURO, @PrecioMoneda, @DescripProyecto, @Fecha, @IdGastoAgencia, @IdGastoAgenciaLinea, @TipoImport

			SET @IdTercero = (SELECT IdProveedor from Proyectos where IdProyecto = @IdProyectoLin)
			IF @IdTercero IS NOT NULL
				BEGIN

					SELECT @Old_Pers_GastosAcumulado = ISNULL(Pers_GastosAcumulado,0),
						   @PorcentajeTercero = Pers_PorcentajeTercero
					FROM Conf_Proyectos
					where IdProyecto = @IdProyectoLin

					SET @ImporteGastoTercero = @ImporteProyecto * (@PorcentajeTercero / 100)
					SET @IdMonedaProyecto = (SELECT ISNULL(Pers_Moneda,1) from Conf_Proyectos where IdProyecto = @IdProyectoLin)

					--Si la Moneda del Proyecto es diferente de la Moneda que viene del gasto, convertimos el importe el la moneda del Proyecto
					IF @IdMoneda <> @IdMonedaProyecto
						BEGIN
							Exec @ImporteGastoTercero = Pers_Fun_DameImporteConCambio @ImporteGastoTercero, @IdMonedaProyecto
						END

					UPDATE Conf_Proyectos SET Pers_GastosAcumulado = (@Old_Pers_GastosAcumulado + @ImporteGastoTercero) where IdProyecto = @IdProyectoLin

					SET @IdLineaMovimientoHistorico = (SELECT ISNULL(MAX(IdMovimiento),0) from Pers_Historico_Mov_UpFrontGastos)
					INSERT INTO Pers_Historico_Mov_UpFrontGastos (IdMovimiento, TipoMovimiento, Descrip, Importe, IdObjCabecera, IdObjLinea, IdProyecto, FechaMovimiento) 
						VALUES (@IdLineaMovimientoHistorico + 1, 'GastosPendientes', 'Moficado tras importacion de gasto' , (@Old_Pers_GastosAcumulado + @ImporteGastoTercero), @IdGastoAgencia, @IdGastoAgenciaLinea, @IdProyectoLin, GETDATE())
				END

			FETCH cursor_gastosAgenciaLineas INTO @IdProyectoLin, @ImporteProyecto, @DescripProyecto, @IdGastoAgenciaLinea
		END
 
		CLOSE cursor_gastosAgenciaLineas
		DEALLOCATE cursor_gastosAgenciaLineas


		DECLARE @Objeto varchar(50) = 'PedidoProv_Linea'
		--CURSOR PARA INSERTAR DESGLOSE ANALITICO
		DECLARE @IdLinea int
		DECLARE @IDDocLinea int
		DECLARE @Descrip nvarchar(MAX)
		DECLARE GeneraDesgloseCursor CURSOR FOR
		SELECT IdPedido, IdLinea, IdDoc, Descrip FROM Pedidos_Prov_Lineas where IdPedido = @IdPedido
		OPEN GeneraDesgloseCursor
		FETCH NEXT FROM GeneraDesgloseCursor INTO @IdPedido, @IdLinea, @IdDocLinea, @Descrip
		WHILE @@FETCH_STATUS = 0
		BEGIN
			Exec PPERS_DesgloceLinea_Pedidos
				@Objeto,
				@IdPedido,
				@IdLinea, 
				@IdDocLinea,
				@Fecha,
				@Descrip

				FETCH NEXT FROM GeneraDesgloseCursor INTO @IdPedido, @IdLinea, @IdDocLinea, @Descrip
		END
		CLOSE GeneraDesgloseCursor
		DEALLOCATE GeneraDesgloseCursor

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

