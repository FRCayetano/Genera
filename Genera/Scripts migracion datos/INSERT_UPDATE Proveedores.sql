begin tran

INSERT INTO Prov_Datos (FechaAlta, IdProveedor, RazonSocial, Proveedor, Nif, Direccion, Web, E_Mail, NumTelefono, Notas)
select GETDATE(), RIGHT('00000'+cast(IdProveedor as nvarchar(10)),5), Proveedor,Proveedor, CIF, DIRECCION, Web, Correo, Telefono, Actividad
from OPENROWSET('Microsoft.ACE.OLEDB.12.0',
'Excel 12.0;HDR=YES;Database=C:\TEMP\Proveedores _Clientes.xlsx;',
'SELECT * FROM [Proveedor$]')

update Prov_Datos_Economicos
set FormaPago = ISNULL(x.IdFormatPago,0),
	IdMoneda = ISNULL(x.Moneda,1)
from OPENROWSET('Microsoft.ACE.OLEDB.12.0',
'Excel 12.0;HDR=YES;Database=C:\TEMP\Proveedores _Clientes.xlsx;',
'SELECT * FROM [Proveedor$]') x
where x.IdPRoveedor = Prov_Datos_Economicos.IdProveedor

commit tran