USE [GENERA]
GO
/****** Object:  StoredProcedure [dbo].[PPers_GenerarPedidoProveedor_From_Ingreso]    Script Date: 29/06/2015 18:19:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Gaetan, COLLET>
-- Create date: <01/06/2015>
-- Description:	<Permite la creacion de los pedidos de proveedores (terceros) a la hora de generar los pedidos a partir de los ingresos de una agencia>
-- =============================================
ALTER PROCEDURE [dbo].[PPers_GenerarPedidoProveedor_From_Ingreso] 
	 @IdEmpresa T_Id_Empresa OUTPUT
	,@Fecha T_Fecha_Corta OUTPUT
	,@IdEmpleado T_Id_Empleado OUTPUT
	,@IdDepartamento T_Id_Departamento OUTPUT
	,@IdIngresoAgencia INT OUTPUT
	,@IdMoneda T_Id_Moneda
AS
BEGIN
	DECLARE @IdPedido T_Id_Pedido = 0
	--DECLARE	  @IdEmpresa		T_Id_Empresa = 0
	DECLARE @AnoNum T_AñoNum = 1999
	DECLARE @NumPedido T_Id_Pedido = 0
	--DECLARE		@Fecha			T_Fecha_Corta = GETDATE()
	DECLARE @IdProveedor T_Id_Proveedor
	DECLARE @IdPedidoProv VARCHAR(50) = NULL
	DECLARE @IdContacto INT = NULL
	DECLARE @DescripcionPed VARCHAR(255) = NULL
	DECLARE @IdLista T_Id_Lista = 0
	--DECLARE		@IdEmpleado		T_Id_Empleado = NULL
	--DECLARE		@IdDepartamento	T_Id_Departamento = NULL
	DECLARE @IdTransportista T_Id_Proveedor = NULL
	--DECLARE		@IdMoneda			T_Id_Moneda = 0
	DECLARE @FormaPago T_Forma_Pago = 0
	DECLARE @Descuento REAL = 0
	DECLARE @ProntoPago REAL = 0
	DECLARE @IdPortes T_Id_Portes = 'D'
	DECLARE @IdIva T_Id_Iva = 0
	DECLARE @IdEstado T_Id_Estado = 0
	DECLARE @IdSituacion T_Id_Situacion = 0
	DECLARE @FechaEntrega T_Fecha_Corta = @Fecha
	DECLARE @FechaEntregaTope T_Fecha_Corta = @Fecha
	DECLARE @Observaciones VARCHAR(255) = NULL
	DECLARE @IdCentroCoste T_Id_CentroCoste = NULL
	DECLARE @IdCentroProd T_CentroProductivo = NULL
	DECLARE @IdCentroImp T_CentroImponible = NULL
	DECLARE @Codigo VARCHAR(50) = NULL
	DECLARE @Cambio T_Precio = NULL
	DECLARE @CambioEuros T_Precio = 1
	DECLARE @CambioBloqueado T_Booleano = 0
	DECLARE @Confirmado T_Booleano = 0
	DECLARE @IdCentroCalidad T_CentroCalidad = NULL
	--DECLARE		@IdProyecto		T_Id_Proyecto = '1'
	DECLARE @Inmovilizado T_Booleano = 0
	DECLARE @SeriePedido T_Serie = 0
	DECLARE @Bloqueado T_Booleano = 0
	DECLARE @IdMotivoBloqueo INT = NULL
	DECLARE @IdEmpleadoBloqueo T_Id_Empleado = NULL
	DECLARE @IdOrden T_Id_Orden = 0
	DECLARE @IdBono T_Id_Bono = NULL
	DECLARE @EnvioAObra T_Booleano = 0
	DECLARE @IdTipoProv T_Id_Tipo = 0
	DECLARE @PorcentajeProveedor REAL
	DECLARE @ImporteLineaPedido T_Precio = 0
	DECLARE @ImportePedido DECIMAL
	DECLARE @Msg_err VARCHAR(255)
	DECLARE @P0 NVARCHAR(1000)
	DECLARE @CadenaStr NVARCHAR(4000)
	DECLARE @TipoImport VARCHAR(255) = 'Ingreso'
	DECLARE @Descrip_Proyecto VARCHAR(255)
	DECLARE @UpFront DECIMAL
	DECLARE @UpFrontAcumulado DECIMAL
	DECLARE @GastosPendientes DECIMAL
	DECLARE @IdMonedaProveedor T_Id_Moneda
	DECLARE @CambioDelDia DECIMAL(18, 4)
	DECLARE @Precio_EURO T_Precio
	DECLARE @PrecioMoneda T_Precio

	/***********************************************************************************************************************
	Comprobacion para ver si existe un tercero asociado a ese proyecto
		Si existe : continuar la creacion de pedido
		Si no : no hacer nada 
************************************************************************************************************************/
	BEGIN TRY

		--Declaramos el cursor para recoger todos los proyectos que tengan ingresos en el IngresoAgencia
		DECLARE @IdProyecto			T_Id_Proyecto
		DECLARE @ImporteProyecto	DECIMAL(18,4)
		DECLARE cursor_ingresoAgenciaLineas CURSOR FOR 
        		select distinct il.IdProyecto, SUM(il.Importe)
        		from Pers_IngresoAgencia_Lineas il
        		inner join Proyectos p on il.IdProyecto = p.IdProyecto
        		where il.IdIngresoAgencia = @IdIngresoAgencia
				GROUP BY il.IdProyecto
        	
        OPEN cursor_ingresoAgenciaLineas
        FETCH cursor_ingresoAgenciaLineas INTO @IdProyecto, @ImporteProyecto
        	
        WHILE @@FETCH_STATUS = 0
        BEGIN
				
			--Obtener el ID del proveedor asociado al proyecto @IdProyecto
			SELECT @IdProveedor = ISNULL(IdProveedor, - 1)
			FROM Proyectos
			WHERE IdProyecto = @IdProyecto

			IF (@IdProveedor <> - 1)
			BEGIN
				SET @IdContacto = (
					SELECT IdContacto
					FROM Prov_Datos
					WHERE IdProveedor = @IdProveedor
					)
					
				--Recuperacion de la propriedades del proyecto (UpFront, GastosPendiente, Porcentaje tercero...)
				SELECT @PorcentajeProveedor = cp.Pers_PorcentajeTercero
					,@UpFront = ISNULL(cp.Pers_UpFront, 0)
					,@UpFrontAcumulado = ISNULL(cp.Pers_UpFrontAcumulado, 0)
					,@GastosPendientes = ISNULL(cp.Pers_GastosAcumulado, 0)
					,@DescripcionPed = 'Proyecto ' + p.Descrip + ' : ' + p.IdProyecto
				FROM Proyectos p
				INNER JOIN Conf_Proyectos cp ON p.IdProyecto = cp.IdProyecto
				WHERE p.IdProyecto = @IdProyecto

				--Gestion de la moneda
				SET @ImporteLineaPedido = @ImporteProyecto * (@PorcentajeProveedor / 100)
				SET @IdMonedaProveedor = (
						SELECT ISNULL(IdMoneda,1)
						FROM Prov_Datos_Economicos
						WHERE IdProveedor = @IdProveedor
						)
				SET @CambioDelDia = (
						SELECT Cambio
						FROM funDameCambioMoneda(2, GETDATE())
						)

				IF @IdMonedaProveedor > 1
				BEGIN
					SET @Precio_EURO = 0
					SET @PrecioMoneda = @ImporteLineaPedido

					--Si la moneda del Excel es el euro, convert el importe porque queremos crear un pedido en dolare
					IF @IdMoneda = 1
					BEGIN
						SET @PrecioMoneda = (@PrecioMoneda * @CambioDelDia)
					END
				END

				IF @IdMonedaProveedor = 1
				BEGIN
					--Si la moneda del excel nos viene en dolares, convertir el importe en EURO
					IF @IdMoneda > 1
					BEGIN
						SET @Precio_EURO = @ImporteLineaPedido / @CambioDelDia
					END

					IF @IdMoneda = 1
					BEGIN
						SET @Precio_EURO = @ImporteLineaPedido
					END

					SET @PrecioMoneda = @Precio_EURO
				END

				--Miramos si ya existe un pedido para ese proveedor que no sea facturado
				--Si un pedido existe, añadimos una linea si no creamos una nueva cabecera u despues la linea
				DECLARE @NbExistPedido	INT
				SELECT @NbExistPedido = count(cab.Idpedido)
				FROM Pedidos_Prov_Cabecera cab
				INNER JOIN Pedidos_Prov_Lineas li ON cab.IdPedido = li.IdPedido
				WHERE cab.IdProveedor = @IdProveedor
					AND (
						li.IdEstado BETWEEN 0
							AND 6
						)

				DECLARE @IdLinea	T_Id_Linea = 0
				IF (@NbExistPedido = 0)
				BEGIN
					Set @IdPedido = 0
					EXEC pPedidos_Prov_Cabecera_I @IdPedido OUTPUT
						,@IdEmpresa
						,@AnoNum
						,@NumPedido
						,@Fecha
						,@IdProveedor
						,@IdPedidoProv
						,@IdContacto
						,@DescripcionPed
						,@IdLista
						,@IdEmpleado
						,@IdDepartamento
						,@IdTransportista
						,@IdMonedaProveedor
						,@FormaPago
						,@Descuento
						,@ProntoPago
						,@IdPortes
						,@IdIva
						,@IdEstado
						,@IdSituacion
						,@FechaEntrega
						,@FechaEntregaTope
						,@Observaciones
						,@IdCentroCoste
						,@IdCentroProd
						,@IdCentroImp
						,@Codigo
						,@CambioDelDia
						,@CambioDelDia
						,@CambioBloqueado
						,@Confirmado
						,@IdCentroCalidad
						,@IdProyecto
						,@Inmovilizado
						,@SeriePedido
						,@Bloqueado
						,@IdMotivoBloqueo
						,@IdEmpleadoBloqueo
						,@IdOrden
						,@IdBono
						,@EnvioAObra
						,@IdTipoProv
						,NULL
						,NULL
						,NULL

					EXEC PPERS_PPedidos_Prov_Lineas_I @IdPedido
						,@Precio_EURO
						,@PrecioMoneda
						,@DescripcionPed
						,@FechaEntrega
						,@IdIngresoAgencia
						,@TipoImport
				END
				ELSE
				BEGIN

					--Si ya existe un pedido para el tercero, recuperamos el id de este pedido y añadimos una linea al pedido
					SELECT @IdPedido = MIN(cab.Idpedido)
					FROM Pedidos_Prov_Cabecera cab
					INNER JOIN Pedidos_Prov_Lineas li ON cab.IdPedido = li.IdPedido
					WHERE cab.IdProveedor = @IdProveedor
					AND (
						li.IdEstado BETWEEN 0
							AND 6
						)

					EXEC PPERS_PPedidos_Prov_Lineas_I @IdPedido
						,@Precio_EURO
						,@PrecioMoneda
						,@DescripcionPed
						,@FechaEntrega
						,@IdIngresoAgencia
						,@TipoImport
				END

				--Recuperar el importe total del pedido para asegurarse de que, a la hora de descontar el upfront y los gastos, que no vamos a crear un pedido con un importe negativo
				SET @ImportePedido = (
						SELECT sum(PrecioMoneda)
						FROM Pedidos_Prov_Lineas
						WHERE IdPedido = @IdPedido
						)

				--Si existe, descontar el UpFront que el Indie recibio para desarollar el juego y actualizamos el campo UpFrontAcumulado de la tabla Conf_proyectos
				--Creamos una linea en el pedido proveedor con el importe negativo que vamos a descontar
				DECLARE @ImporteLineaDescontada 	DECIMAL(18,4) 
				DECLARE @IdLineaMovimientoHistorico INT
				DECLARE @IdMonedaProyecto 			INT
				DECLARE @QuedaUpFront				DECIMAL(18,4)

				SET @IdMonedaProyecto = (
						SELECT ISNULL(Pers_Moneda, 1)
						FROM Conf_Proyectos
						WHERE IdProyecto = @IdProyecto
						)

				--Entramos aqui si queda upFront a descontar para el proyecto
				IF @UpFront <> 0
					AND @UpFrontAcumulado < @UpFront
				BEGIN
					SET @DescripcionPed = 'UpFront del proyecto : ' + @IdProyecto
					SET @TipoImport = ''

					--Si el importe del pedido esta superior al upfront restante, podemos descontar todo el upFront restante en el pedido
					IF @ImportePedido >= (@UpFront - @UpFrontAcumulado)
					BEGIN
						SET @ImportePedido = @ImportePedido - (@UpFront - @UpFrontAcumulado)
						SET @ImporteLineaDescontada = (@UpFront - @UpFrontAcumulado) * - 1

						UPDATE Conf_Proyectos
						SET Pers_UpfrontAcumulado = Pers_UpFront
						WHERE IdProyecto = @IdProyecto
					END
					ELSE
					BEGIN
					-- Queda mas UpFront que el importe total del pedido, asi no se puede descontar todo el UpFront restante
					-- En este caso ponemos el pedido a zero y descontamos el importe del pedido al UpFront
						SET @ImporteLineaDescontada = @ImporteLineaPedido * - 1

						SET @ImportePedido = @ImportePedido - (@ImporteLineaDescontada * - 1)

						UPDATE Conf_Proyectos
						SET Pers_UpfrontAcumulado = (@UpFrontAcumulado + (@ImporteLineaDescontada * - 1))
						WHERE IdProyecto = @IdProyecto
					
					END

					EXEC PPERS_PPedidos_Prov_Lineas_I @IdPedido
						,@ImporteLineaDescontada
						,@ImporteLineaDescontada
						,@DescripcionPed
						,@FechaEntrega
						,@IdIngresoAgencia
						--,@IdIngresoAgenciaLinea
						,@TipoImport

	
					SET @IdLineaMovimientoHistorico = (
							SELECT ISNULL(MAX(IdMovimiento), 0)
							FROM Pers_Historico_Mov_UpFrontGastos
							)

					--Escribimos una linea en la tabla Pers_Historico_Mov_UpFrontGastos para seguir los movimientos de importe de UpFront y GastosPendiente
					INSERT INTO Pers_Historico_Mov_UpFrontGastos (
						IdMovimiento
						,TipoMovimiento
						,Descrip
						,Importe
						,IdObjCabecera
						--,IdObjLinea
						,IdProyecto
						,FechaMovimiento
						)
					VALUES (
						@IdLineaMovimientoHistorico + 1
						,'UpFront'
						,'Modificado tras importacion de Ingreso'
						,@ImporteLineaDescontada
						,@IdIngresoAgencia
						--,@IdIngresoAgenciaLinea
						,@IdProyecto
						,GETDATE()
						)
				END

				--Si existe, descontar los gastos Pendientes y actualizamos el campo gastos pendientes de la tabla Conf_Proyectos
				IF @GastosPendientes <> 0
					AND @ImportePedido > 0
				BEGIN
					SET @DescripcionPed = 'Gastos Pendientes del proyecto : ' + @IdProyecto
					SET @TipoImport = ''

					IF @ImportePedido >= @GastosPendientes
					BEGIN
						SET @ImportePedido = @ImportePedido - @GastosPendientes
						SET @ImporteLineaDescontada = @GastosPendientes * - 1

						UPDATE Conf_Proyectos
						SET Pers_GastosAcumulado = 0
						WHERE IdProyecto = @IdProyecto
					END
					ELSE
					BEGIN
						SET @ImporteLineaDescontada = @ImportePedido * - 1

						UPDATE Conf_Proyectos
						SET Pers_GastosAcumulado = (@GastosPendientes - @ImportePedido)
						WHERE IdProyecto = @IdProyecto

						SET @ImportePedido = 0
					END

				
					EXEC PPERS_PPedidos_Prov_Lineas_I @IdPedido
						,@ImporteLineaDescontada
						,@ImporteLineaDescontada
						,@DescripcionPed
						,@FechaEntrega
						,@IdIngresoAgencia
						--,@IdIngresoAgenciaLinea
						,@TipoImport

					SET @IdLineaMovimientoHistorico = (
							SELECT ISNULL(MAX(IdMovimiento), 0)
							FROM Pers_Historico_Mov_UpFrontGastos
							)

					--Si existe, descontar los gastos Pendientes y actualizamos el campo gastos pendientes de la tabla Conf_Proyectos
					INSERT INTO Pers_Historico_Mov_UpFrontGastos (
						IdMovimiento
						,TipoMovimiento
						,Descrip
						,Importe
						,IdObjCabecera
						--,IdObjLinea
						,IdProyecto
						,FechaMovimiento
						)
					VALUES (
						@IdLineaMovimientoHistorico + 1
						,'GastosPendientes'
						,'Modificado tras importacion de Ingreso'
						,@ImporteLineaDescontada
						,@IdIngresoAgencia
						--,@IdIngresoAgenciaLinea
						,@IdProyecto
						,GETDATE()
						)
			END
		END
		FETCH cursor_ingresoAgenciaLineas INTO @IdProyecto, @ImporteProyecto
        END

        CLOSE cursor_ingresoAgenciaLineas
        DEALLOCATE cursor_ingresoAgenciaLineas

		RETURN - 1
	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRAN
		END

		DECLARE @CatchError NVARCHAR(MAX)

		SET @CatchError = dbo.funImprimeError(ERROR_MESSAGE(), ERROR_NUMBER(), ERROR_PROCEDURE(), @@PROCID, ERROR_LINE())

		RAISERROR (
				@CatchError
				,12
				,1
				)

		RETURN 0
	END CATCH
END