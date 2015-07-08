-- =============================================
-- Author:		<COLLET, Gaetan>
-- Create date: <07/07/2015>
-- Description:	<Inicializacion de un nuevo presupuesto de gestion, copiamdo la estructura del presupuesto pasado>
-- =============================================
ALTER PROCEDURE [dbo].[pPers_CrearEstructuraPresupuesto] 
	@IdPresupuestoNuevo	INT OUTPUT,
	@Anyo				INT OUTPUT
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -------------------------------------------------------------------------------
	--				Creacion del nuevo presupuesto : Pers_Presupuesto
	-------------------------------------------------------------------------------
	BEGIN
	
		DECLARE @IdPresupuestoPasado	INT
		DECLARE @Fecha_inicio_N			T_Fecha_Corta
		DECLARE @Fecha_Fin_N			T_Fecha_Corta
		DECLARE @AnyoP					INT
		DECLARE @AnyoN					INT

		SELECT  @IdPresupuestoNuevo = IdPresupuesto + 1,
				@AnyoN = anyo + 1,
				@Fecha_inicio_N = DATEADD(year,1,Fecha_Inicio),
				@Fecha_Fin_N = DATEADD(year,1,Fecha_Fin)
		FROM Pers_Presupuestos
		WHERE IdPresupuesto = (SELECT MAX(IdPresupuesto) FROM Pers_Presupuestos)

		--Si el parametro Anyo es superior a 0, el usuario quiere crear el nuevo presupuesto a partir de la estructura del año selecionado
		--Si no, el usuario solo quiere crear un presupuesto vacio asi que creamos une registro en Pers_Presupuest y salimos de la stored
		IF @Anyo > 0
			BEGIN
				SET @IdPresupuestoPasado = (SELECT IdPresupuesto FROM Pers_Presupuestos WHERE Anyo = @Anyo)
			END
		ELSE
			BEGIN
				
				INSERT INTO Pers_Presupuestos(IdPresupuesto	,
									 Anyo			, 
									 Fecha_Inicio	, 
									 Fecha_Fin		,
									 Descrip 		,
									 IdEjercicio	,
									 IdEstado		,
									 Cerrado 		, 
									 Activo) 
				VALUES (@IdPresupuestoNuevo,
						@AnyoN,
						@Fecha_Inicio_N,
						@Fecha_Fin_N,
						'Presupuesto ' + CAST(@AnyoN AS VARCHAR),
						0,0,0,0)

				RETURN -1

			END

		INSERT INTO Pers_Presupuestos(IdPresupuesto	,
									 Anyo			, 
									 Fecha_Inicio	, 
									 Fecha_Fin		,
									 Descrip 		,
									 IdEjercicio	,
									 IdEstado		,
									 Cerrado 		, 
									 Activo) 
		VALUES (@IdPresupuestoNuevo,
				@AnyoN,
				@Fecha_Inicio_N,
				@Fecha_Fin_N,
				'Presupuesto ' + CAST(@AnyoN AS VARCHAR),
				0,0,0,0)


		IF NOT EXISTS (SELECT 1 FROM Pers_Presupuestos WHERE IdDoc = SCOPE_IDENTITY())
		BEGIN
			PRINT dbo.Traducir(24176, 'ERROR EN INSERCIÓN. NO SE HA PODIDO INSERTAR EN LA TABLA DE PRESUPUESTOS.')
			RETURN 0
		END
	END

    -------------------------------------------------------------------------------
	--				Creacion de la estructura de : Pers_Presupuesto_Equipos
	-------------------------------------------------------------------------------
	BEGIN
		INSERT INTO Pers_Presupuestos_Equipos(
											IdPresupuesto,
											IdEquipo,
											PorcGastosFijos,
											PorcGastosEstructura,
											IngresosEnero,
											IngresosFebrero,
											IngresosMarzo,
											IngresosAbril,
											IngresosMayo,
											IngresosJunio,
											IngresosJulio,
											IngresosAgosto,
											IngresosSeptiembre,
											IngresosOctubre,
											IngresosNoviembre,
											IngresosDiciembre,
											GastosEnero,
											GastosFebrero,
											GastosMarzo,
											GastosAbril,
											GastosMayo,
											GastosJunio,
											GastosJulio,
											GastosAgosto,
											GastosSeptiembre,
											GastosOctubre,
											GastosNoviembre,
											GastosDiciembre
											 )
			SELECT  @IdPresupuestoNuevo,
		   			IdEquipo, 
				    PorcGastosFijos, 
				    PorcGastosEstructura,
				    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
			FROM Pers_Presupuestos_Equipos
			WHERE idPresupuesto = @IdPresupuestoPasado
	END

    -------------------------------------------------------------------------------
	--			Creacion de la estructura de : Pers_Presupuesto_Equipos_Gastos
	-------------------------------------------------------------------------------

	BEGIN
		INSERT INTO Pers_Presupuestos_Equipos_Gastos(
													IdPresupuesto,
													IdEquipo,
													IdTipoGasto,
													GastosEnero,
													GastosFebrero,
													GastosMarzo,
													GastosAbril,
													GastosMayo,
													GastosJunio,
													GastosJulio,
													GastosAgosto,
													GastosSeptiembre,
													GastosOctubre,
													GastosNoviembre,
													GastosDiciembre
													)
			SELECT 	@IdPresupuestoNuevo,
		   			IdEquipo, 
		   			IdTipoGasto, 
	   				0,0,0,0,0,0,0,0,0,0,0,0
			FROM Pers_Presupuestos_Equipos_Gastos
			WHERE idPresupuesto = @IdPresupuestoPasado
	END

    -------------------------------------------------------------------------------
	--		Creacion de la estructura de : Pers_Presupuestos_Equipos_GastosStaff
	-------------------------------------------------------------------------------

	BEGIN

		INSERT INTO Pers_Presupuestos_Equipos_GastosStaff(
													IdPresupuesto,
													IdEquipo,
													IdEquipoStaff,
													GastosEnero,
													GastosFebrero,
													GastosMarzo,
													GastosAbril,
													GastosMayo,
													GastosJunio,
													GastosJulio,
													GastosAgosto,
													GastosSeptiembre,
													GastosOctubre,
													GastosNoviembre,
													GastosDiciembre
													)
			SELECT 	@IdPresupuestoNuevo,
	   				IdEquipo, 
	   				IdEquipoStaff, 
	   				0,0,0,0,0,0,0,0,0,0,0,0
			FROM Pers_Presupuestos_Equipos_GastosStaff
			WHERE idPresupuesto = @IdPresupuestoPasado

	END

    -------------------------------------------------------------------------------
	--		Creacion de la estructura de : Pers_Presupuestos_Equipos_Proyectos
	-------------------------------------------------------------------------------

	BEGIN
		INSERT INTO Pers_Presupuestos_Equipos_Proyectos(
											IdPresupuesto,
											IdEquipo,
											IdProyecto,
											Porcentaje,
											IngresosEnero,
											IngresosFebrero,
											IngresosMarzo,
											IngresosAbril,
											IngresosMayo,
											IngresosJunio,
											IngresosJulio,
											IngresosAgosto,
											IngresosSeptiembre,
											IngresosOctubre,
											IngresosNoviembre,
											IngresosDiciembre
											)
			SELECT 	@IdPresupuestoNuevo,
	   				IdEquipo, 
	   				IdProyecto, 
	   				Porcentaje,
	   				0,0,0,0,0,0,0,0,0,0,0,0
			FROM Pers_Presupuestos_Equipos_Proyectos
			WHERE idPresupuesto = @IdPresupuestoPasado	

	END

    -------------------------------------------------------------------------------
	--		Creacion de la estructura de : Pers_Presupuestos_Equipos_Empleados
	-------------------------------------------------------------------------------

	BEGIN

		INSERT INTO Pers_Presupuestos_Equipos_Empleados(
											IdPresupuesto,
											IdEquipo,
											IdEmpleado,
											PorcDedicacion,
											GastosEnero,
											GastosFebrero,
											GastosMarzo,
											GastosAbril,
											GastosMayo,
											GastosJunio,
											GastosJulio,
											GastosAgosto,
											GastosSeptiembre,
											GastosOctubre,
											GastosNoviembre,
											GastosDiciembre
											)
			SELECT 	@IdPresupuestoNuevo,
	   				IdEquipo, 
	   				IdEmpleado, 
	   				PorcDedicacion,
	   				0,0,0,0,0,0,0,0,0,0,0,0
			FROM Pers_Presupuestos_Equipos_Empleados
			WHERE idPresupuesto = @IdPresupuestoPasado

	END

	RETURN -1

END
