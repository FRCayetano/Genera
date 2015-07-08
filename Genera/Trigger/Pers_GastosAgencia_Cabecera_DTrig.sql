SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Gaetan, COLLET>
-- Create date: <02-07-2015>
-- Description:	<Trigger para eliminar el pedido proveedor a la hora de suprimir la cabecera de GastosAgencias>
-- =============================================
CREATE TRIGGER [dbo].[Pers_GastosAgencia_Cabecera_DTrig] 
   ON  [dbo].[Pers_GastosAgencia_Cabecera] 
   AFTER DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    
	DELETE FROM Pedidos_Prov_Cabecera
	WHERE IdPedido = (SELECT IdPedidoProv FROM DELETED)

END
GO
