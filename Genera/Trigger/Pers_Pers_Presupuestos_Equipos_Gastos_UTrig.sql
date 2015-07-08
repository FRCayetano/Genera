USE [GENERA]
GO

/****** Object:  Trigger [dbo].[Pers_Pers_Presupuestos_Equipos_Gastos_UTrig]    Script Date: 08/07/2015 14:28:45 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<COLLET, Gaetan>
-- Create date: <07/07/2015>
-- Description:	<Impedir la modificacion de la estructura de un presupuesto cerrado>
-- =============================================
CREATE TRIGGER [dbo].[Pers_Pers_Presupuestos_Equipos_Gastos_UTrig]
   ON  [dbo].[Pers_Presupuestos_Equipos_Gastos] 
   FOR UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--No vale para UPDATE masivo que afecten a varios presupuestos porque el ROLLBACK se lanza si hay un presupuesto cerrado
	--Hay que desactivar el trigger o poner el campo cerrar de Pers_Presupuestos a 0 para modificar la estructura del presupuesto

	IF EXISTS (SELECT 1 FROM INSERTED i INNER JOIN Pers_Presupuestos pp ON i.IdPresupuesto = pp.IdPresupuesto AND pp.Cerrado = 1) BEGIN
		PRINT dbo.Traducir(32705, 'No se puede modificar la estructura o los datos de un presupuesto cerrado.')
		ROLLBACK TRAN
		RETURN		
	END
END
GO


