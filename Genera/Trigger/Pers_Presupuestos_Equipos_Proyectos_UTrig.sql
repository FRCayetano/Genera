USE [GENERA]
GO

/****** Object:  Trigger [dbo].[Pers_Presupuestos_Equipos_Proyectos_UTrig]    Script Date: 08/07/2015 14:29:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[Pers_Presupuestos_Equipos_Proyectos_UTrig] 
ON [dbo].[Pers_Presupuestos_Equipos_Proyectos] 
AFTER UPDATE
AS

BEGIN

	IF EXISTS (SELECT 1 FROM INSERTED i INNER JOIN Pers_Presupuestos pp ON i.IdPresupuesto = pp.IdPresupuesto AND pp.Cerrado = 1) BEGIN
		PRINT dbo.Traducir(32705, 'No se puede modificar la estructura o los datos de un presupuesto cerrado.')
		ROLLBACK TRAN
		RETURN		
	END

	UPDATE PPE
	set IngresosEnero = t1.IngresosEnero,
	IngresosFebrero = t1.IngresosFebrero,
	IngresosMarzo = t1.IngresosMarzo,
	IngresosAbril = t1.IngresosAbril,
	IngresosMayo = t1.IngresosMayo,
	IngresosJunio = t1.IngresosJunio,
	IngresosJulio = t1.IngresosJulio,
	IngresosAgosto = t1.IngresosAgosto,
	IngresosSeptiembre = t1.IngresosSeptiembre,
	IngresosOctubre = t1.IngresosOctubre,
	IngresosNoviembre = t1.IngresosNoviembre,
	IngresosDiciembre = t1.IngresosDiciembre	
	from (
	SELECT PP.[IdPresupuesto]
      ,PP.[IdEquipo]
      ,SUM(PP.[IngresosEnero]) as IngresosEnero
      ,SUM(PP.[IngresosFebrero]) as IngresosFebrero
      ,SUM(PP.[IngresosMarzo]) as IngresosMarzo
      ,SUM(PP.[IngresosAbril]) as IngresosAbril
      ,SUM(PP.[IngresosMayo]) as IngresosMayo
      ,SUM(PP.[IngresosJunio]) as IngresosJunio
      ,SUM(PP.[IngresosJulio]) as IngresosJulio
      ,SUM(PP.[IngresosAgosto]) as IngresosAgosto
      ,SUM(PP.[IngresosSeptiembre]) as IngresosSeptiembre
      ,SUM(PP.[IngresosOctubre]) as IngresosOctubre
      ,SUM(PP.[IngresosNoviembre]) as IngresosNoviembre
	  ,SUM(PP.[IngresosDiciembre]) as IngresosDiciembre
  FROM [Pers_Presupuestos_Equipos_Proyectos] PP
  inner join inserted I ON PP.IdPresupuesto = I.IdPresupuesto and PP.IdEquipo = I.IdEquipo
  GROUP BY PP.IdPresupuesto, PP.IdEquipo) t1
  inner join Pers_Presupuestos_Equipos PPE ON t1.IdPresupuesto = PPE.IdPresupuesto and t1.IdEquipo = PPE.IdEquipo


END

GO


