USE [GENERA]
GO

/****** Object:  StoredProcedure [dbo].[PPers_GenerarPedidoCliente_From_Ingreso]    Script Date: 01/06/2015 16:42:06 ******/
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER ON
GO

 
CREATE PROCEDURE [dbo].[PPers_GenerarPedidoCliente_From_Ingreso]
                @Fecha															T_Fecha_Corta		OUTPUT,
                @IdCliente														T_Id_Cliente		OUTPUT,
                @IdPedidoCli													Varchar(30)			OUTPUT,
                @DescripcionPed													Varchar(255)		OUTPUT,
                @Observaciones													Varchar(255)		OUTPUT,
                @FechaSalida													T_Fecha_Corta		OUTPUT,
                @IdContacto														int,
                @IdContactoF													int,
                @IdContactoA													int,
                @FormaPago														T_Forma_Pago,
                @IdPrioridad													int,
                @IdEmpleado														T_Id_Empleado,
                @SeriePedido													T_Serie,
				@IdIngresoAgencia												int
               
AS
 
/*********************************************************************************************************************************
														Declarar las variables
**********************************************************************************************************************************/

				Declare @Msg_err Varchar(255)
				DECLARE @CadenaStr nvarchar(4000)
				DECLARE @P0 nvarchar(1000)

                DECLARE @contador int = (SELECT Count(*) from Clientes_Datos where IdCliente = @IdCliente)
                IF(@contador = 0)
                BEGIN
                               INSERT INTO Clientes_Datos (IdCliente, Cliente, RazonSocial) VALUES (@IdCliente, 'Cliente '+@IdCliente, 'Cliente '+@IdCliente)
                END

				--IF EXISTS (select * from Conf_Pedidos_Cli where Pers_IdIngresoAgencia = @IdIngresoAgencia)
				--BEGIN
					--RETURN 0
				--END
 
				DECLARE				@IdPedido									T_Id_Pedido =0
                DECLARE             @IdEmpresa									T_Id_Empresa = 0
                DECLARE             @AñoNum										T_AñoNum = 1999
                --DECLARE           @SeriePedido								T_Serie=0
                DECLARE             @NumPedido									T_Id_Pedido =0
                DECLARE             @Origen										T_Origen = NULL
                --DECLARE           @IdContacto									int = (Select IdContacto from Clientes_Datos where IdCliente = @IdCliente)
               
                if(@IdContactoA is null or @IdContactoA = '')
                                set @IdContactoA = (Select IdContactoA from Clientes_Datos where IdCliente = @IdCliente)
               
                if(@IdContactoF is null or @IdContactoF = '')
                               set @IdContactoF = (Select IdContactoF from Clientes_Datos where IdCliente = @IdCliente)
 
                --DECLARE           @IdContactoA								int = (Select IdContactoA from Clientes_Datos where IdCliente = @IdCliente)
                --DECLARE           @IdContactoF								int = (Select IdContactoF from Clientes_Datos where IdCliente = @IdCliente)
                DECLARE             @IdLista									T_Id_Lista =0
                DECLARE             @IdListaRevision							T_Revision_ =1
                --DECLARE           @IdEmpleado									T_Id_Empleado = 0
                DECLARE             @IdDepartamento								T_Id_Departamento  =0
                DECLARE             @IdTransportista							T_Id_Proveedor = NULL
                DECLARE             @IdMoneda									T_Id_Moneda =1
                --DECLARE           @FormaPago									T_Forma_Pago  =0
                DECLARE             @Descuento									Real  = 0
                DECLARE             @ProntoPago									Real =0
                DECLARE             @IdPortes									T_Id_Portes  ='D'
                DECLARE             @IdIva                                      T_Id_Iva =0
                DECLARE             @IdEstado									T_Id_Estado =0
                DECLARE             @IdSituacion								T_Id_Situacion =0
                --DECLARE           @FechaSalida								T_Fecha_Corta = GETDATE()
                DECLARE             @Comision									Real=0
                DECLARE             @Cambio										T_Precio=0
                DECLARE             @CambioEuros                                T_Precio=1
                DECLARE             @CambioBloqueado							T_Booleano=0
                DECLARE             @Representante                              T_Id_Empleado=0
                DECLARE             @IdCentroCoste                              T_Id_CentroCoste=NULL
                DECLARE             @IdProyecto									T_Id_Proyecto=NULL
                DECLARE             @IdOferta									T_Id_Oferta=NULL
                DECLARE             @Revision									smallint=NULL
                DECLARE             @Inmovilizado								T_Booleano =0
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

				set @vRet = @IdPedido
 
/*********************************************************************************************************************************
	Update la tabla de conf de Pedido para rellenar el campo Pers_IdIngresoAgencia con el ID cuyo cual estamos generando el pedido
**********************************************************************************************************************************/

				update Conf_Pedidos_Cli set Pers_IdIngresoAgencia = @IdIngresoAgencia where IdPedido = @IdPedido

/*********************************************************************************************************************************
	Declare un cursor para recuperar todas las lineas del ingreso actual
	Para cada una de las lineas, llamar a la stored pPers_PPedidos_Cli_Lineas_I para crear una linea de pedido
**********************************************************************************************************************************/
 

				DECLARE cursor_ingresoAgenciaLineas CURSOR FOR 
					select il.IdProyecto, il.Importe, p.Descrip
					from Pers_IngresoAgencia_Lineas il
					inner join Proyectos p on il.IdProyecto = p.IdProyecto
					where il.IdIngresoAgencia = @IdIngresoAgencia
				
				OPEN cursor_ingresoAgenciaLineas

				FETCH cursor_ingresoAgenciaLineas INTO @IdProyectoLin, @ImporteProyecto, @DescripProyecto
				
				WHILE @@FETCH_STATUS = 0
				BEGIN
					Set @DescripProyecto += ' : '+@IdProyectoLin

					Exec pPers_PPedidos_Cli_Lineas_I @IdPedido, @ImporteProyecto, @DescripProyecto
					FETCH cursor_ingresoAgenciaLineas INTO @IdProyectoLin, @ImporteProyecto, @DescripProyecto
				END
 
				CLOSE cursor_ingresoAgenciaLineas
				DEALLOCATE cursor_ingresoAgenciaLineas
 
			return -1	

GO


