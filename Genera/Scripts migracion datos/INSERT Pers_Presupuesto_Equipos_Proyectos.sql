begin tran

insert into Pers_Presupuestos_Equipos (IdPresupuesto, IdEquipo, PorcGastosFijos, PorcGastosEstructura,IngresosEnero, IngresosFebrero, IngresosMarzo, IngresosAbril, IngresosMayo, IngresosJunio, IngresosJulio, IngresosAgosto, IngresosSeptiembre, IngresosOctubre, IngresosNoviembre, IngresosDiciembre)
select 1, IdEquipo, NULL, NULL,0,0,0,0,0,0,0,0,0,0,0,0
 from Pers_Equipos where IDEquipo not in (select distinct Idequipo from Pers_Presupuestos_Equipos) and IdEquipo > 8

insert into Pers_Presupuestos_Equipos_Proyectos(IdPresupuesto, IdEquipo, IdProyecto, Porcentaje, IngresosEnero, IngresosFebrero, IngresosMarzo, IngresosAbril, IngresosMayo, IngresosJunio, IngresosJulio, IngresosAgosto, IngresosSeptiembre, IngresosOctubre, IngresosNoviembre, IngresosDiciembre)
select x.Presupuesto, x.IdEquipo, x.IdProyecto, x.Porcentaje,0,0,0,0,0,0,0,0,0,0,0,0 from (
select distinct 1 as Presupuesto, IdEquipo, RIGHT('00000'+cast(IdProyecto as nvarchar(10)),4) as IdProyecto, 100 as Porcentaje
from OPENROWSET('Microsoft.ACE.OLEDB.12.0',
'Excel 12.0;HDR=YES;Database=C:\TEMP\Maestro.xlsx;',
'SELECT * FROM [Definitivo$]') x
where proyecto not in ('TALKING','PT CLASSIC','PT GOLD')
union
select distinct 1 as Presupuesto, IdEquipo, case when proyecto = 'PT CLASSIC' or proyecto = 'PT GOLD' then '0034'
						       when proyecto = 'TALKING' then '0048' END as IdProyecto, 100 as Porcentaje
from OPENROWSET('Microsoft.ACE.OLEDB.12.0',
'Excel 12.0;HDR=YES;Database=C:\TEMP\Maestro.xlsx;',
'SELECT * FROM [Definitivo$]') x
where proyecto in ('TALKING','PT CLASSIC','PT GOLD')
) x order by x.IdEquipo

commit tran