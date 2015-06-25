USE [GENERA]
GO

/****** Object:  Table [dbo].[Pers_Proyecto_Configuracion]    Script Date: 01/06/2015 16:50:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[Pers_Proyecto_Configuracion](
	[IdProyecto] [dbo].[T_Id_Proyecto] NULL,
	[IdProyectoAgencia] [dbo].[T_Id_Proyecto] NULL,
	[IdCliente] [dbo].[T_Id_Cliente] NULL,
	[UsuarioAgencia] [varchar](50) NULL,
	[IdDoc] [dbo].[T_Id_Doc] IDENTITY(1,1) NOT NULL,
	[InsertUpdate] [dbo].[T_CEESI_Insert_Update] NOT NULL,
	[Usuario] [dbo].[T_CEESI_Usuario] NOT NULL,
	[FechaInsertUpdate] [dbo].[T_CEESI_Fecha_Sistema] NOT NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[Pers_Proyecto_Configuracion]  WITH CHECK ADD  CONSTRAINT [FK_Pers_Proyecto_Configuracion_Proyectos] FOREIGN KEY([IdProyecto])
REFERENCES [dbo].[Proyectos] ([IdProyecto])
GO

ALTER TABLE [dbo].[Pers_Proyecto_Configuracion] CHECK CONSTRAINT [FK_Pers_Proyecto_Configuracion_Proyectos]
GO


