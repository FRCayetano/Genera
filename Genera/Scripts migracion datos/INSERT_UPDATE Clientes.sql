begin tran
INSERT INTO Clientes_Datos (FechaAlta, IdCliente, RazonSocial, Cliente, Nif, Direccion, Web, NumTelefono)
select GETDATE(), RIGHT('00000'+cast(IdCliente as nvarchar(10)),5),Cliente, Cliente,  CIF, DIRECCION, Correo, Telefono
from OPENROWSET('Microsoft.ACE.OLEDB.12.0',
'Excel 12.0;HDR=YES;Database=C:\TEMP\Proveedores _Clientes.xlsx;',
'SELECT * FROM [Cliente$]') 

update Clientes_Datos_Economicos 
set IdMoneda = t1.Moneda
from OPENROWSET('Microsoft.ACE.OLEDB.12.0',
'Excel 12.0;HDR=YES;Database=C:\TEMP\Proveedores _Clientes.xlsx;',
'SELECT * FROM [Cliente$]') t1
where Clientes_Datos_Economicos.IdCliente = RIGHT('00000'+cast(t1.IdCliente as nvarchar(10)),5)
and t1.Moneda is not null

commit tran