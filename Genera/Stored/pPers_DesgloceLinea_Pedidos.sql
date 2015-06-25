USE [GENERA]
GO

/****** Object:  StoredProcedure [dbo].[pPERS_DesgloceLinea_Pedidos]    Script Date: 25/06/2015 18:21:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Gaetan, COLLET>
-- Create date: <10/06/2015>
-- Description:	<Realizar el desgloce analitico de la linea de pedido Cliente o Proveedor
--				Depende del parametro @Objeto = Tipo objeto>
-- =============================================
CREATE PROCEDURE [dbo].[pPERS_DesgloceLinea_Pedidos]
	@Objeto 		  varchar(50)		OUTPUT,
	@IdPedido         T_Id_Pedido		OUTPUT,
	@IdLinea	      T_Id_Linea		OUTPUT, 
	@IdDocObjeto      T_Id_Doc		    OUTPUT,
	@FechaImputacion  T_Fecha_Corta     OUTPUT,
	@Descrip		  varchar(255)		OUTPUT

AS

BEGIN

DECLARE @Porcentaje		T_Real124
DECLARE @IdProyecto		varchar(15)
DECLARE @IdEquipo		int
DECLARE @CentroCoste	T_Id_CentroCoste

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	/*Recuperar el IdProyecto a partir de la descripcion de la linea de pedido*/
	Set @IdProyecto = LTRIM(SUBSTRING(@Descrip,CHARINDEX( ':' ,@Descrip) +1,len(@Descrip)))
	SET @IdProyecto = (Select case when IdProyectoPadre is null then IdProyecto else IdProyectoPadre end from Conf_Proyectos where IdProyecto = @IdProyecto)
	
	BEGIN TRY

		DECLARE cursor_desgloceAnalitico CURSOR FOR 
			select pep.IdEquipo, pep.IdProyecto, pep.Porcentaje 
			from Pers_Presupuestos_Equipos_Proyectos pep 
			inner join Pers_Presupuestos p on pep.IdPresupuesto = p.IdPresupuesto
				where @FechaImputacion between p.Fecha_Inicio and p.Fecha_Fin
				and pep.IdProyecto = @IdProyecto
				
		OPEN cursor_desgloceAnalitico

		FETCH NEXT FROM cursor_desgloceAnalitico INTO @IdEquipo, @IdProyecto, @Porcentaje
				
		WHILE @@FETCH_STATUS = 0
		BEGIN

			Set @CentroCoste = (select right('00' + convert(varchar,@IdEquipo),2))
			Set @CentroCoste += (select right('0000' + convert(varchar,@IdProyecto),4))

			--Para arreglar un fallito durante la insercion del centro de coste para el desgloce de linea de pedido proveedor, intenta insertar la misms linea dos veces
			IF @Objeto = 'PedidoProv_Linea'
			BEGIN
				/*Insercion en la tabla CentrosCoste_Objetos*/
				DELETE FROM [dbo].[CentrosCoste_Objetos]
				WHERE [Objeto] = 'PedidoProv_Linea' and [IdDocObjeto] = @IdDocObjeto and [CentroCoste] = @CentroCoste and [Porcentaje] = @Porcentaje
			END

			INSERT INTO [dbo].[CentrosCoste_Objetos]
			([Objeto],[IdDocObjeto],[CentroCoste],[Porcentaje])
			VALUES
			(@Objeto, @IdDocObjeto, @CentroCoste, @Porcentaje)

			FETCH NEXT FROM cursor_desgloceAnalitico INTO @IdEquipo, @IdProyecto, @Porcentaje
		END
 
		CLOSE cursor_desgloceAnalitico
		DEALLOCATE cursor_desgloceAnalitico

		RETURN -1

	END TRY

	BEGIN CATCH
        IF @@TRANCOUNT >0 BEGIN
            ROLLBACK TRAN 
        END

        DECLARE @CatchError NVARCHAR(MAX)
        SET @CatchError=dbo.funImprimeError(ERROR_MESSAGE(),ERROR_NUMBER(),ERROR_PROCEDURE(),@@PROCID ,ERROR_LINE())
        RAISERROR(@CatchError,12,1)

        RETURN 0
    END CATCH

END
GO


