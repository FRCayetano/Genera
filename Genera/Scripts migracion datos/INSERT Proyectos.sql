begin tran

insert into Proyectos (IdProyecto, Descrip, Fecha, IdEstado, Tipo, IdSituacion, IdDepartamento, SeguimientosTareas, IdDelegacion)
SELECT RIGHT('00000'+cast(IdProyecto as nvarchar(10)),4), Proyecto, GETDATE(), 0, '(Sin definir)', 0,0,0,-1
from OPENROWSET('Microsoft.ACE.OLEDB.12.0',
'Excel 12.0;HDR=YES;Database=C:\TEMP\Maestro.xlsx;',
'SELECT * FROM [Proyecto$]') where RIGHT('00000'+cast(IdProyecto as nvarchar(10)),4) not in (select IdProyecto from Proyectos)

UPDATE Proyectos set IdProveedor = RIGHT('00000'+cast(x.IdTercero as nvarchar(10)),5)
from OPENROWSET('Microsoft.ACE.OLEDB.12.0',
'Excel 12.0;HDR=YES;Database=C:\TEMP\Maestro.xlsx;',
'SELECT * FROM [Definitivo$]') x
where Proyectos.IdProyecto = x.IdProyecto
and x.IdTercero is not null and x.IdTercero <> '#N/A' and x.IdTercero <> ''

update Conf_Proyectos set Pers_PorcentajeTercero = 40
where IdProyecto in (select IdProyecto from Proyectos where IdProveedor is not null)

update Conf_Proyectos set IdProyectoPadre = case when x.proyecto = 'TALKING' Then '0048'
												 when x.proyecto = 'PT GOLD' or x.proyecto = 'PT CLASSIC' Then '0034'
												 end
from OPENROWSET('Microsoft.ACE.OLEDB.12.0',
'Excel 12.0;HDR=YES;Database=C:\TEMP\Maestro.xlsx;',
'SELECT * FROM [Definitivo$]') x
where Conf_Proyectos.IdProyecto = RIGHT('00000'+cast(x.IdProyecto as nvarchar(10)),4)
and x.Proyecto in ('PT CLASSIC','PT GOLD','TALKING')

commit tran

