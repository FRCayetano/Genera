begin tran

insert into Pers_Proyectos_Agencias_Ingresos ( IdProyecto, IdCliente, IdProyectoAgencia, NombreAPP)
select RIGHT('00000'+cast(IDPROYECTO as nvarchar(10)),4) IdProyecto, RIGHT('00000'+cast(IDAGENCIA as nvarchar(10)),5) IdAgencia, CODIGOENAGENCIA, NOMBREAPP 
from OPENROWSET('Microsoft.ACE.OLEDB.12.0',
'Excel 12.0;HDR=YES;Database=C:\TEMP\Maestro.xlsx;',
'SELECT * FROM [Definitivo$]') x
where x.IDAGENCIA is not null

commit tran


