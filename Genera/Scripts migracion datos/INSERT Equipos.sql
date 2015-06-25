begin tran
INSERT INTO Pers_Equipos (IdEquipo, Descrip, Activo, Staff)
select IdEquipo, Equipo,1,0
from OPENROWSET('Microsoft.ACE.OLEDB.12.0',
'Excel 12.0;HDR=YES;Database=C:\TEMP\Maestro.xlsx;',
'SELECT * FROM [Equipo$]') where IdEquipo not in (select IdEquipo from Pers_Equipos)

commit tran