--Borrar la configuracion actual
delete from Pers_Presupuestos_Equipos_Gastos
delete from Pers_Presupuestos_Equipos_GastosStaff
delete from Pers_Presupuestos_Equipos_Proyectos
delete from Pers_Presupuestos_Equipos
delete from Pers_Presupuestos_Equipos_Empleados
delete from Pers_Presupuestos


delete from Pers_Proyectos_Agencias_Ingresos
delete from Pers_Proyectos_Agencias_Gastos
delete from Proyectos
delete from Pers_Equipos

--Borrar los Ingresos y Gastos existentes
delete from Pers_IngresoAgencia_Cab
delete from Pers_GastosAgencia_Cab

--Desabilitar el trigger Deleted de la tabla Almacen_Hist_Mov antes de borrar
disable trigger [dbo].[Almacen_Hist_Mov_DTrig] ON [dbo].[Almacen_Hist_Mov]

delete from Almacen_Hist_Mov

enable trigger [dbo].[Almacen_Hist_Mov_DTrig] ON [dbo].[Almacen_Hist_Mov]

--Borrar cabecera de pedidos proveedores y clientes
delete from Pedidos_Cli_Cabecera
delete from Pedidos_Prov_Cabecera

--Borrar los datos de clientes y proveedores
delete from Clientes_Datos where idCliente <> 0
delete from Prov_datos where idProveedor <> 0


--A ver lo que hacemos con los equipos