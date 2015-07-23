CREATE VIEW vPers_Imputacion_Empleado_Nominas
AS
SELECT	 ino.IdImportacion as IdImportacion,
		 ino.fecha as Fecha_Imputacion,
		 right('00' + CAST(pep.idequipo AS VARCHAR),2) + right('0000' + dl.IdProyecto,4) as IdCentroCoste,
		 'C.C. ' + pe.Descrip + ' ' + pr.Descrip as CC_Descrip,
		 dl.idEmpleado as IdEmpleado,
		 dl.PorcentajeDedic as PorcentajeDedic, 
		 ed.NIF as NIF, 
		 pep.IdEquipo as IdEquipo,
		 pe.Descrip as DescripEquipo, 
		 pep.Porcentaje as PorcentajeReparto_Equipo,
		 ABS(ROUND(((ABS(ROUND(((inol.Bruto * dl.PorcentajeDedic) /100.0), 2)) * pep.Porcentaje) /100.0), 2)) as Bruto_ImporteEquipo,
		 ABS(ROUND(((ABS(ROUND(((inol.Total_Coste_SS * dl.PorcentajeDedic) /100.0), 2)) * pep.Porcentaje) /100.0), 2)) as Total_Coste_SS_ImporteEquipo
FROM Pers_Importa_Nominas ino
INNER JOIN Pers_Importa_Nominas_Lineas inol on ino.IdImportacion = inol.IdImportacion
INNER JOIN Empleados_Datos ed on ed.NIF = inol.NIF
INNER JOIN Pers_Importa_Dedicacion_Empleado_Proyecto_Lineas dl ON dl.IdEmpleado = ed.IdEmpleado
INNER JOIN Pers_Presupuestos_Equipos_Proyectos pep on pep.IdProyecto = dl.IdProyecto
INNER JOIN Pers_Presupuestos pp on pp.IdPresupuesto = pep.IdPresupuesto
INNER JOIN Proyectos pr on pr.IdProyecto = dl.IdProyecto
INNER JOIN Pers_Equipos pe on pe.IdEquipo = pep.IdEquipo
WHERE YEAR(dl.Fecha) = YEAR(ino.Fecha) and MONTH(dl.Fecha) = MONTH(ino.fecha)
AND dl.PorcentajeDedic > 0
AND dl.fecha between pp.Fecha_Inicio and pp.Fecha_Fin
AND ed.IdEmpleado IN (SELECT IdEmpleado FROM Pers_Presupuestos_Equipos_Empleados WHERE IdEquipo <> 1)
UNION
select  ino.IdImportacion as IdImportacion,
		ino.fecha as Fecha_Imputacion,
		C.CentroCoste,
		'C.C. ' + pe.Descrip + ' Estructura' as CC_Descrip,
		ed.IdEmpleado,
		0,
		ed.NIF,
		pe.IdEquipo,
		pe.Descrip,
		C.Porcentaje,
		ABS(ROUND(((inol.Bruto * C.Porcentaje) /100.0), 2)) as Bruto_ImporteEquipo,
		ABS(ROUND(((inol.Total_Coste_SS * C.Porcentaje) /100.0), 2)) as Total_Coste_SS_ImporteEquipo
FROM Pers_Importa_Nominas ino
INNER JOIN Pers_Importa_Nominas_Lineas inol on ino.IdImportacion = inol.IdImportacion
INNER JOIN Empleados_Datos ed on ed.NIF = inol.NIF
INNER JOIN (
	select '1' as Plug, CentroCoste, Porcentaje from TiposGastos_Definiciones def
	INNER JOIN TiposGastos_Delegaciones del ON def.IdTipoGasto = del.IdTipoGasto
	INNER JOIN CentrosCoste_Objetos co ON co.IdDocObjeto = del.IdDoc
	WHERE del.IdTipoGasto = 31) C ON C.Plug = '1'
INNER JOIN Pers_Equipos pe ON pe.IdEquipo = LEFT(C.CentroCoste,2)
WHERE ed.IdEmpleado IN (SELECT IdEmpleado FROM Pers_Presupuestos_Equipos_Empleados pep 
						INNER JOIN Pers_Presupuestos pp ON pp.IdPresupuesto = pep.IdPresupuesto 
						WHERE pep.IdEquipo = 1 and ino.Fecha between pp.Fecha_Inicio and pp.Fecha_Fin)
