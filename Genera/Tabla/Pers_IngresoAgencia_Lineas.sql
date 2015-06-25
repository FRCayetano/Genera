USE [GENERA]
GO

/****** Object:  Table [dbo].[Pers_IngresoAgencia_Lineas]    Script Date: 01/06/2015 16:49:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[Pers_IngresoAgencia_Lineas](
	[IdIngresoAgencia] [smallint] NOT NULL,
	[IdIngresoAgenciaLinea] [smallint] NOT NULL,
	[IdProyecto] [dbo].[T_Id_Proyecto] NOT NULL,
	[IdProyectoAgencia] [dbo].[T_Id_Proyecto] NULL,
	[Importe] [decimal](18, 0) NULL,
	[IdDoc] [dbo].[T_Id_Doc] IDENTITY(1,1) NOT NULL,
	[InsertUpdate] [dbo].[T_CEESI_Insert_Update] NOT NULL,
	[Usuario] [dbo].[T_CEESI_Usuario] NOT NULL,
	[FechaInsertUpdate] [dbo].[T_CEESI_Fecha_Sistema] NOT NULL,
 CONSTRAINT [PK_Pers_IngresoAgencia_Lineas] PRIMARY KEY CLUSTERED 
(
	[IdIngresoAgencia] ASC,
	[IdIngresoAgenciaLinea] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[Pers_IngresoAgencia_Lineas]  WITH CHECK ADD  CONSTRAINT [FK_Pers_IngresoAgencia_Lineas_Pers_IngresoAgencia_Cab] FOREIGN KEY([IdIngresoAgencia])
REFERENCES [dbo].[Pers_IngresoAgencia_Cab] ([IdIngresoAgencia])
GO

ALTER TABLE [dbo].[Pers_IngresoAgencia_Lineas] CHECK CONSTRAINT [FK_Pers_IngresoAgencia_Lineas_Pers_IngresoAgencia_Cab]
GO


