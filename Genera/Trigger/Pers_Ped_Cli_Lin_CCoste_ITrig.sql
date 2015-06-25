USE [GENERA]
GO

/****** Object:  Trigger [dbo].[Pers_Ped_Cli_Lin_CCoste_ITrig]    Script Date: 01/06/2015 16:48:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<COLLET Gaetan>
-- Create date: <01/06/2015>
-- Description:	<Añadir el porcentaje correspondiente a la linea de pedido en el centro de coste>
-- =============================================
CREATE TRIGGER [dbo].[Pers_Ped_Cli_Lin_CCoste_ITrig] 
   ON  [dbo].[Pedidos_Cli_Lineas]
   AFTER INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DECLARE @Objeto			varchar(50) = 'Pedido_Linea'
	DECLARE @IdDocObjeto	T_Id_Doc
	DECLARE @CentroCoste	T_Id_CentroCoste
	DECLARE @Porcentaje		T_Real124
	DECLARE @IdProyecto		varchar(15)
	DECLARE @Descripcion	varchar(255)
	DECLARE @IdEquipo		int

	Set @IdDocObjeto = (select IdDoc from inserted)
	Set @Descripcion = (select Descrip from inserted)

	/*Recuperar el IdProyecto a partir de la descripcion de la linea de pedido*/
	Set @IdProyecto = LTRIM(SUBSTRING(@Descripcion,CHARINDEX( ':' ,(select Descrip from inserted)) +1,len(@Descripcion)))

	print @IdProyecto

	/*Cursor sobre la table que contiene los porcentajes de cada equipo para despues insertar una linea en CentroCoste_Objeto*/
		--Calcular el codigo del centro de coste, Equipo/Proyecto
	DECLARE cursor_desgloceAnalitico CURSOR FOR 
		select idproyecto, idequipo, porcentaje
		from Pers_EquiposPorProyectos
		where idProyecto = @IdProyecto
				
		OPEN cursor_desgloceAnalitico

		FETCH cursor_desgloceAnalitico INTO @IdProyecto, @IdEquipo, @Porcentaje
				
		WHILE @@FETCH_STATUS = 0
		BEGIN

			Set @CentroCoste = (select right('0000' + convert(varchar,@IdEquipo),4))
			Set @CentroCoste += (select right('0000' + convert(varchar,@IdProyecto),4))

			/*Insercion en la tabla CentrosCoste_Objetos*/

			INSERT INTO [dbo].[CentrosCoste_Objetos]
           ([Objeto],[IdDocObjeto],[CentroCoste],[Porcentaje])
			VALUES
           (@Objeto, @IdDocObjeto, @CentroCoste, @Porcentaje)

			FETCH cursor_desgloceAnalitico INTO @IdProyecto, @IdEquipo, @Porcentaje
			END
 
			CLOSE cursor_desgloceAnalitico
			DEALLOCATE cursor_desgloceAnalitico

END

GO


