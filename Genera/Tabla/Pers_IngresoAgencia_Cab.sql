USE [GENERA]
GO

/****** Object:  Table [dbo].[Pers_IngresoAgencia_Cab]    Script Date: 01/06/2015 16:49:32 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[Pers_IngresoAgencia_Cab](
	[IdIngresoAgencia] [smallint] NOT NULL,
	[Descrip] [varchar](100) NULL,
	[IdMoneda] [dbo].[T_Id_Moneda] NULL,
	[IdCliente] [dbo].[T_Id_Cliente] NULL,
	[Fichero] [varchar](500) NULL,
	[FechaImport] [smalldatetime] NULL,
	[FechaIngreso] [smalldatetime] NULL,
	[ImporteTotal] [decimal](18, 0) NULL,
	[IdDoc] [dbo].[T_Id_Doc] IDENTITY(1,1) NOT NULL,
	[InsertUpdate] [dbo].[T_CEESI_Insert_Update] NOT NULL,
	[Usuario] [dbo].[T_CEESI_Usuario] NOT NULL,
	[FechaInsertUpdate] [dbo].[T_CEESI_Fecha_Sistema] NOT NULL,
 CONSTRAINT [PK_Pers_IngresoAgencia] PRIMARY KEY CLUSTERED 
(
	[IdIngresoAgencia] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


