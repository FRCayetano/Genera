USE [GENERA]
GO

/****** Object:  StoredProcedure [dbo].[PPers_GenerarPedidoCliente_From_Ingreso]    Script Date: 25/06/2015 18:23:56 ******/
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER ON
GO


 
CREATE PROCEDURE [dbo].[PPers_GenerarPedidoCliente_From_Ingreso]
        @Fecha															T_Fecha_Corta		OUTPUT,
        @IdCliente														T_Id_Cliente		OUTPUT,
        @DescripcionPed													Varchar(255)		OUTPUT,
        @IdEmpleado														T_Id_Empleado             ,
		@IdMoneda                                                       T_Id_Moneda         OUTPUT,
		@IdIngresoAgencia												int
               
AS
 
/*********************************************************************************************************************************
														Declarar las variables
**********************************************************************************************************************************/
 
BEGIN

	DECLARE				@IdPedido									T_Id_Pedido =0
    DECLARE             @IdEmpresa									T_Id_Empresa = 0
    DECLARE             @AñoNum										T_AñoNum = 1999
    DECLARE             @SeriePedido								T_Serie=0
    DECLARE             @NumPedido									T_Id_Pedido =0
    DECLARE             @Origen										T_Origen = NULL
    DECLARE             @IdPedidoCli                                Varchar(30) = 0
    DECLARE             @IdContacto									int = (Select IdContacto from Clientes_Datos where IdCliente = @IdCliente)
    DECLARE             @IdContactoA                                int = (Select IdContactoA from Clientes_Datos where IdCliente = @IdCliente)
    DECLARE             @IdContactoF                                int = (Select IdContactoF from Clientes_Datos where IdCliente = @IdCliente) 
    DECLARE             @IdLista									T_Id_Lista =0
    DECLARE             @IdListaRevision							T_Revision_ =1
    --DECLARE           @IdEmpleado									T_Id_Empleado = 0
    DECLARE             @IdDepartamento								T_Id_Departamento  =0
    DECLARE             @IdTransportista							T_Id_Proveedor = NULL
    --DECLARE             @IdMoneda									T_Id_Moneda =1
    DECLARE             @FormaPago									T_Forma_Pago  =0
    DECLARE             @Descuento									Real  = 0
    DECLARE             @ProntoPago									Real =0
    DECLARE             @IdPortes									T_Id_Portes  ='D'
    DECLARE             @IdIva                                      T_Id_Iva =0
    DECLARE             @IdEstado									T_Id_Estado =0
    DECLARE             @IdSituacion								T_Id_Situacion =0
    DECLARE             @FechaSalida								    T_Fecha_Corta = GETDATE()
	DECLARE				@Observaciones								Varchar(255) = ''
    DECLARE             @Comision									Real=0
    DECLARE             @Cambio										T_Precio= (select Cambio from funDameCambioMoneda(2,gETDATE()))
    DECLARE             @CambioEuros                                T_Precio= (select Cambio from funDameCambioMoneda(2,gETDATE()))
    DECLARE             @CambioBloqueado							T_Booleano=0
    DECLARE             @Representante                              T_Id_Empleado=0
    DECLARE             @IdCentroCoste                              T_Id_CentroCoste=NULL
    DECLARE             @IdProyecto									T_Id_Proyecto=NULL
    DECLARE             @IdOferta									T_Id_Oferta=NULL
    DECLARE             @Revision									smallint=NULL
    DECLARE             @Inmovilizado								T_Booleano =0
    DECLARE             @IdPrioridad                                int = 1
    DECLARE             @Referencia									varchar(50)='0'
    DECLARE             @RecogidaPorCli								T_Booleano=0
    DECLARE             @ContactoLlamada							varchar(255)=NULL
    DECLARE             @Hora										varchar(5)=NULL
    DECLARE             @HoraSalida									varchar(5)=NULL
    DECLARE             @IdTipoPedido								int=0
    DECLARE             @RecEquivalencia							T_Booleano=0
    DECLARE             @Bloqueado									T_Booleano=0
    DECLARE             @IdMotivoBloqueo							int=NULL
    DECLARE             @IdEmpleadoBloqueo							int=NULL
    DECLARE             @IdApertura									int=NULL
    DECLARE             @IdPedidoOrigen								T_Id_Pedido=0
    DECLARE             @NoCalcularPromo							T_Booleano=0
			
	--Datos necesarios para generar las lineas
	DECLARE				@IdProyectoLin								T_id_proyecto
	DECLARE				@ImporteProyecto							Real
	DECLARE				@DescripProyecto							varchar(max)
				
/*********************************************************************************************************************************
					Llamar a la stored estandard de creacion de cabecerra de pedido para crearla
**********************************************************************************************************************************/

    BEGIN TRY
            Declare @vRet int
        	Exec @vRet = pPedidos_Cli_Cabecera_I
                                 @IdPedido output   ,
                                 @IdEmpresa         ,
                                 @AñoNum            ,
                                 @SeriePedido		,
                                 @NumPedido			,
                                 @Fecha				,
                                 @IdCliente         ,
                                 @Origen            ,
                                 @IdPedidoCli		,
                                 @IdContacto		,
                                 @IdContactoA		,
                                 @IdContactoF       ,
                                 @DescripcionPed	,
                                 @IdLista			,
                                 @IdListaRevision	,
                                 @IdEmpleado		,
                                 @IdDepartamento	,
                                 @IdTransportista   ,
                                 @IdMoneda			,
                                 @FormaPago			,
                                 @Descuento			,
                                 @ProntoPago		,
                                 @IdPortes			,
                                 @IdIva				,
                                 @IdEstado			,
                                 @IdSituacion		,
                                 @FechaSalida       ,
                                 @Observaciones     ,
                                 @Comision			,
                                 @Cambio			,
                                 @CambioEuros		,
                                 @CambioBloqueado	,
                                 @Representante		,
                                 @IdCentroCoste		,
                                 @IdProyecto        ,
                                 @IdOferta			,
                                 @Revision			,
                                 @Inmovilizado		,
                                 @Referencia		,
                                 @RecogidaPorCli	,
                                 @ContactoLlamada	,
                                 @Hora				,
                                 @HoraSalida        ,
                                 @IdTipoPedido		,
                                 @RecEquivalencia	,
                                 @Bloqueado			,
                                 @IdMotivoBloqueo   ,
                                 @IdEmpleadoBloqueo ,
                                 @IdApertura		,
                                 @IdPedidoOrigen	,
                                 @NoCalcularPromo	,
                                 NULL,NULL,NULL


		--Asociar el IdPedido de la cabecera generada a la cabecera del IngresoAgencia actual
		update Pers_IngresoAgencia_Cabecera set IdPEdido = @IdPedido where IdIngresoAgencia = @IdIngresoAgencia

        /*********************************************************************************************************************************
        Declare un cursor para recuperar todas las lineas del ingreso actual
        Para cada una de las lineas, llamar a la stored pPers_PPedidos_Cli_Lineas_I para crear una linea de pedido
        **********************************************************************************************************************************/
			DECLARE @PrecioMoneda		T_Precio 
			DECLARE @Precio_EURO		T_Precio
			DECLARE @IdIngresoAgenciaLinea	int
        	DECLARE cursor_ingresoAgenciaLineas CURSOR FOR 
        		select distinct il.IdProyecto, SUM(il.Importe), 'Proyecto '+ p.Descrip +': ' + il.IdProyecto
        		from Pers_IngresoAgencia_Lineas il
        		inner join Proyectos p on il.IdProyecto = p.IdProyecto
        		where il.IdIngresoAgencia = @IdIngresoAgencia
				GROUP BY il.IdProyecto,  'Proyecto '+ p.Descrip +': ' + il.IdProyecto
        	
        	OPEN cursor_ingresoAgenciaLineas
        	FETCH cursor_ingresoAgenciaLineas INTO @IdProyectoLin, @ImporteProyecto, @DescripProyecto
        	
        	WHILE @@FETCH_STATUS = 0
        	BEGIN
				
				SET @PrecioMoneda = @ImporteProyecto
				SET @Precio_EURO = @ImporteProyecto

				IF @IdMoneda > 1
				BEGIN
					SET @Precio_EURO = 0
				END

				Exec pPers_PPedidos_Cli_Lineas_I @IdPedido, @Precio_EURO, @PrecioMoneda, @DescripProyecto, @Fecha, @IdIngresoAgencia
        		FETCH cursor_ingresoAgenciaLineas INTO @IdProyectoLin, @ImporteProyecto, @DescripProyecto
        	END

        	CLOSE cursor_ingresoAgenciaLineas
        	DEALLOCATE cursor_ingresoAgenciaLineas

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

