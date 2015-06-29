Sub Show()
'  Set oShell = CreateObject("WScript.Shell")
'  oShell.SendKeys "% x"
End Sub

Sub Initialize()

  
   With gForm.Controls("PnlMain")
    .ResizeEnabled = True
    .ResizeRestanteV = False
    .ResizeV = 3

  End With   

  gForm.Controls("EObjeto").ResizeV = 2

  Set lPest1 = gForm.Controls.Add("AhoraOCX.cntTab", "Pest11")
  lPest1.ResizeEnabled = True
  lPest1.ResizeV = 4
  lPest1.ResizeRestanteV = True  
  lPest1.Visible = True
  
  gForm.Width=20000
  gForm.Height = 14200
    CargaControles
	
	gForm.Controls("Botonera").BotonAdd "Refrescar Todo", "btnRefrescarTodo", , , , 383
  
End Sub

Sub CargaControles
  CargaPrincipal
  CargaEquipos
  CargaProyectos
   CargaGastos
   CargaIngresosVsGastos
   CargaEquiposEmpleados
End Sub
Sub CargaPrincipal
  Set lPnl2 = gForm.Controls.Add("Threed.SSPanel", "plnPrincipal")	
  With lPnl2	
    .Object.AutoSize = 3 'ssChildToPanel	
    .Visible = True	
    gForm.Controls("Pest11").InsertItem 0, "Principal", .Object.Hwnd, 170
    Set gForm.Controls("PnlMain").COntainer = lPnl2
  End With 	
  CreaCampoTexto "Pers_IdPresupuesto", gForm.Controls("PnlMain"), 300, 195, 1815, 300, "Id Presup.", 800, 0, "EObjeto", "IdPresupuesto" 
  CreaCampoTexto "Pers_Descrip", gForm.Controls("PnlMain"), 2375, 195, 4920, 300, "Descripción", 1000, 0, "EObjeto", "Descrip" 
  CreaCampoTexto "Pers_Año", gForm.Controls("PnlMain"), 300, 560, 1815, 300, "Año", 800, 0, "EObjeto", "Anyo" 
  CreaCampoTexto "Pers_FechaInicio", gForm.Controls("PnlMain"), 2375, 560, 2220, 300, "Fecha Inicio", 1000, 0, "EObjeto", "Fecha_Inicio" 
  CreaCampoTexto "Pers_FechaFin", gForm.Controls("PnlMain"), 4715, 560, 2565, 300, "Fecha Fin", 1000, 0, "EObjeto", "Fecha_Fin" 
  lsql = "SELECT Descrip, IdEjercicio FROM COnta_Ejercicios WHERE IdEmpresa = 0"
  CreaCampoCombo "Pers_Ejercicio", gForm.Controls("PnlMain"), 300, 915, 3045, 300, "Ejercicio" ,800, lSql, 3045, "Descrip", 8, 1000, "IdEjercicio", 8, 2, 2, "EObjeto", "IdEjercicio"
  CreaCheck "Pers_Cerrado", gForm.Controls("PnlMain"), 3750, 915, 1425, 300, "Cerrado", 1185, "EObjeto", "Cerrado"
  CreaCheck "Pers_Activo", gForm.Controls("PnlMain"), 5850, 915, 1425, 300, "Activo", 1185, "EObjeto", "Activo"
  
  
End Sub


Function CreaCampoTexto(aNombre, aParent, aLeft, aTop, aWidth, aHeight, aCaption, aAnchoEtiqueta, aMultilinea, aObjOrigen, aObjPOrigen)

  Dim lCtrl
  
  If aMultilinea <> 0 Then
    Set lCtrl = gForm.Controls.Add("AhoraOCX.TextoMultilinea", aNombre, aParent)
  Else
    Set lCtrl = gForm.Controls.Add("AhoraOCX.TextoUsuario", aNombre, aParent)
  End If 
  With lCtrl
    .Move aLeft, aTop, aWidth, aHeight
    .CaptionVisible = True  
    .CaptionWidth = aAnchoEtiqueta
    .CaptionControl = aCaption 
    .ObjOrigen = aObjOrigen
    .ObjPOrigen = aObjPOrigen
    .AplicaEstilo
    .Visible = True
    .Enabled = True
  End With
End Function

Function CreaCampoCombo(aNombre, aParent, aLeft, aTop, aWidth, aHeight, aCaption, aAnchoEtiqueta, aSQl, aAnch1, ANom1, aTD1, aAnch2, ANom2, aTD2, aNcol, aActiva, aObjOrigen, aObjPOrigen)

  Dim lCtrl
  
  Set lCtrl = gForm.Controls.Add("AhoraOCX.ComboUsuario", aNombre, aParent)
    With lCtrl
    .Move aLeft, aTop, aWidth, aHeight
    .CaptionVisible = True  
    .CaptionWidth = aAnchoEtiqueta
    .CaptionControl = aCaption 
    .C1Anchura = aAnch1
    .C1Nombre = ANom1  
    .C1TipoDato = aTD1 
    .C2Anchura = aAnch2
    .C2Nombre = ANom2  
    .C2TipoDato = aTD2
    .NColumnas = aNcol  
    .cActiva = aActiva     
    .Descripcion = aSQL
    .ObjOrigen = aObjOrigen
    .ObjPOrigen = aObjPOrigen
    
    .AplicaEstilo
    .Visible = True
    .Enabled = True
  End With
End Function

Sub CreaCheck(aNombre, aParent, aLeft, aTop, aWidth, aHeight, aCaption, aAnchoEtiqueta, aObjOrigen,aObjPOrigen)

  Dim lCtrl
  Set lCtrl = gForm.Controls.Add("AhoraOCX.CheckBoxUser", aNombre, aParent)
  
  With lCtrl
    .Move aLeft, aTop, aWidth, aHeight
    .CaptionVisible = True  
    .CaptionWidth = aAnchoEtiqueta
    .CaptionControl = aCaption 
    .ObjOrigen = aObjOrigen
    .ObjPOrigen = aObjPOrigen
    .Visible = True
    .Locked = False
    '.Value = aValue
  End With
End Sub

Sub CargaEquipos
  Set lPnl3 = gForm.Controls.Add("Threed.SSPanel", "plnEquipos")	
  With lPnl3	
    .Object.AutoSize = 3 'ssChildToPanel	
    .Visible = True	
    gForm.Controls("Pest11").InsertItem 1, "Equipos", .Object.Hwnd, 170
  End With 	

  Set lPnl = gForm.Controls.Add("AhoraOCX.cntPanel", "pnlEquipos2", gForm.Controls("plnEquipos"))   
  lPnl.ResizeInterior = True
  lPnl.ResizeEnabled = True
  lPnl.Estilo = 0
  lPnl.Visible = True
  lPnl.Top = 0
  lPnl.Width = gForm.Width - 200
  lPnl.Height = 5000

  Set lGrid = gForm.Controls.Add("AhoraOCX.cntGridUsuario", "grdEquipos",lPnl )
  lGrid.Visible = True
  lGrid.AplicaEstilo  
  lPnl.ResizeEnabled = True
  lgrid.Width = lPnl.width 
  lgrid.height = lPnl.Height
  lGrid.ActivarScripts=True
  lGrid.Enabled = True
  
     With gForm.Controls("grdEquipos")       
        
     .Agregar = True
     .Editar = True
     .Eliminar = True
     .CargaObjetos = False
     .EditarPorObjeto = False
     

     .AgregaColumna "IdPresupuesto", 0, "IdPresupuesto"
     .AgregaColumna "IdEquipo", 3000, "Equipo", False, "Select IdEquipo as ID, IdEquipo, Descrip from Pers_Equipos where Staff = 0"
	'.AgregaColumna "@Equipo", 3000, "Equipo", True, "Select IdEquipo as ID, Descrip from Pers_Equipos"
     .AgregaColumna "PorcGastosFijos", 1000, "%Gasto Fijo", False
	.AgregaColumna "PorcGastosEstructura", 1200, "%Gasto Estruct.", False
      .AgregaColumna "IngresosEnero", 1000, "Ing. Enero", False,,,"#,##0.00"
      .AgregaColumna "IngresosFebrero", 1000, "Ing. Febrero", False,,,"#,##0.00"
      .AgregaColumna "IngresosMarzo", 1000, "Ing. Marzo", False,,,"#,##0.00"
      .AgregaColumna "IngresosAbril", 1000, "Ing. Abril", False,,,"#,##0.00"
      .AgregaColumna "IngresosMayo", 1000, "Ing. Mayo", False,,,"#,##0.00"
      .AgregaColumna "IngresosJunio", 1000, "Ing. Junio", False,,,"#,##0.00"
      .AgregaColumna "IngresosJulio", 1000, "Ing. Julio", False,,,"#,##0.00"
      .AgregaColumna "IngresosAgosto", 1000, "Ing. Agosto", False,,,"#,##0.00"
      .AgregaColumna "IngresosSeptiembre", 1100, "Ing. Septiembre", False,,,"#,##0.00"
      .AgregaColumna "IngresosOctubre", 1000, "Ing. Octubre", False,,,"#,##0.00"
      .AgregaColumna "IngresosNoviembre", 1100, "Ing. Noviembre", False,,,"#,##0.00"
      .AgregaColumna "IngresosDiciembre", 1000, "Ing. Diciembre", False,,,"#,##0.00"
      
	'.Campo("@Equipo").Sustitucion = "Select Descrip from Pers_Equipos where IdEquipo = @IdEquipo"
	.Campo("IdPresupuesto").Default = gForm.Controls("EObjeto").ObjGlobal.Propiedades("IdPresupuesto")

     .From = "Pers_Presupuestos_Equipos" 
     .TablaObjeto = "Pers_Presupuestos_Equipos"
     .Where = " WHERE IdPresupuesto = '"& gForm.Controls("EObjeto").ObjGlobal.Propiedades("IdPresupuesto") &"'"
     .AplicaEstilo
     .Orden = "IdEquipo"
     .Refrescar
     .Refresca = True  

      .ActivarScripts = True 
	  
	  .ValueItems "IdEquipo", "Select IdEquipo, Descrip from Pers_Equipos", False
      
  End With

  
  
  Set lPnl = gForm.Controls.Add("AhoraOCX.cntPanel", "pnlProyectosEquipos", gForm.Controls("plnEquipos"))   
  lPnl.ResizeInterior = True
  lPnl.ResizeEnabled = True
  lPnl.Estilo = 0
  lPnl.Visible = True
  lPnl.Top = 5500
  lPnl.Width = gForm.Width - 200
  lPnl.Height = 5000

  Set lGrid = gForm.Controls.Add("AhoraOCX.cntGridUsuario", "grdProyectos",lPnl )
  lGrid.Visible = True
  lGrid.AplicaEstilo  
  lPnl.ResizeEnabled = True
  lgrid.Width = lPnl.width 
  lgrid.height = lPnl.Height
  
  
  


End Sub
Sub  CargaProyectos
  Set lPnl4 = gForm.Controls.Add("Threed.SSPanel", "plnProyectos")	
  With lPnl4	
    .Object.AutoSize = 3 'ssChildToPanel	
    .Visible = True	
    gForm.Controls("Pest11").InsertItem 2, "Proyectos", .Object.Hwnd, 170
  End With 	
  
   
  
  Set lPnl = gForm.Controls.Add("AhoraOCX.cntPanel", "pnlProyectosEquipos2", gForm.Controls("plnProyectos"))   
  lPnl.ResizeInterior = True
  lPnl.ResizeEnabled = True
  lPnl.Estilo = 0
  lPnl.Visible = True
  lPnl.Top = 0
  lPnl.Width = gForm.Width - 200
  lPnl.Height = 5000

  Set lGrid = gForm.Controls.Add("AhoraOCX.cntGridUsuario", "grdProyectos2",lPnl )
  lGrid.Visible = True
  lGrid.AplicaEstilo  
  lPnl.ResizeEnabled = True
  lgrid.Width = lPnl.width 
  lgrid.height = lPnl.Height
  
  
     With gForm.Controls("grdProyectos2")       
        
     .Agregar = True
     .Editar = True
     .Eliminar = True
     .CargaObjetos = False
     .EditarPorObjeto = False
     

     .AgregaColumna "IdPresupuesto", 0, "IdPresupuesto"
     '.AgregaColumna "IdEquipo", 0, "IdEq", False, "Select IdEquipo as ID, IdEquipo, Descrip from Pers_Equipos where Staff = 0"
'	.AgregaColumna "@Equipo", 3000, "Equipo", True, "Select IdEquipo as ID, Descrip from Pers_Equipos"
	 .AgregaColumna "IdProyecto", 3000, "Proyecto", False, "Select IdProyecto as ID, IdProyecto, Descrip from Proyectos "
	'.AgregaColumna "@Proyecto", 3000, "Proyecto", True, "Select IdProyecto as ID, Descrip from Proyectos"
     '.AgregaColumna "Porcentaje", 1000, "%Proyecto", False
      .AgregaColumna "IngresosEnero", 1000, "Ing. Enero", False,,,"#,##0.00"
      .AgregaColumna "IngresosFebrero", 1000, "Ing. Febrero", False,,,"#,##0.00"
      .AgregaColumna "IngresosMarzo", 1000, "Ing. Marzo", False,,,"#,##0.00"
      .AgregaColumna "IngresosAbril", 1000, "Ing. Abril", False,,,"#,##0.00"
      .AgregaColumna "IngresosMayo", 1000, "Ing. Mayo", False,,,"#,##0.00"
      .AgregaColumna "IngresosJunio", 1000, "Ing. Junio", False,,,"#,##0.00"
      .AgregaColumna "IngresosJulio", 1000, "Ing. Julio", False,,,"#,##0.00"
      .AgregaColumna "IngresosAgosto", 1000, "Ing. Agosto", False,,,"#,##0.00"
      .AgregaColumna "IngresosSeptiembre", 1100, "Ing. Septiembre", False,,,"#,##0.00"
      .AgregaColumna "IngresosOctubre", 1000, "Ing. Octubre", False,,,"#,##0.00"
      .AgregaColumna "IngresosNoviembre", 1100, "Ing. Noviembre", False,,,"#,##0.00"
      .AgregaColumna "IngresosDiciembre", 1000, "Ing. Diciembre", False,,,"#,##0.00"
      
	'.Campo("@Proyecto").Sustitucion = "Select Descrip from Proyectos where IdProyecto = @IdProyecto"
	.Campo("IdPresupuesto").Default = gForm.Controls("EObjeto").ObjGlobal.Propiedades("IdPresupuesto")
	.Campo("IdProyecto").coleccion = "Proyectos"
	.Campo("IdProyecto").ColeccionWhere = "Where IdProyecto = @IdProyecto"
	

     .From = "vPers_Presupuestos_Equipos_Proyectos" 
     .TablaObjeto = "Pers_Presupuestos_Equipos_Proyectos"
     .Where = " WHERE IdPresupuesto = '"& gForm.Controls("EObjeto").ObjGlobal.Propiedades("IdPresupuesto") &"'"
     .AplicaEstilo
     .Orden = "IdProyecto"
     .Refrescar
     .Refresca = True  

      .ActivarScripts = True 
      .ValueItems "IdProyecto", "Select IdProyecto, Descrip from Proyectos", False
      
  End With
  
  
  Set lPnl = gForm.Controls.Add("AhoraOCX.cntPanel", "pnlEquipos3", gForm.Controls("plnProyectos"))   
  lPnl.ResizeInterior = True
  lPnl.ResizeEnabled = True
  lPnl.Estilo = 0
  lPnl.Visible = True
  lPnl.Top = 5500
  lPnl.Width = gForm.Width - 200
  lPnl.Height = 5000

  Set lGrid = gForm.Controls.Add("AhoraOCX.cntGridUsuario", "grdEquipos2",lPnl )
  lGrid.Visible = True
  lGrid.AplicaEstilo  
  lPnl.ResizeEnabled = True
  lgrid.Width = lPnl.width 
  lgrid.height = lPnl.Height
  lGrid.ActivarScripts=True
  lGrid.Enabled = True
  
     

End Sub

Sub  CargaGastos
Set lPnl5 = gForm.Controls.Add("Threed.SSPanel", "plnGastos")	
  With lPnl5	
    .Object.AutoSize = 3 'ssChildToPanel	
    .Visible = True	
    gForm.Controls("Pest11").InsertItem 3, "Gastos", .Object.Hwnd, 170
  End With
  
  Set lPnl = gForm.Controls.Add("AhoraOCX.cntPanel", "pnlEquiposGastos", gForm.Controls("plnGastos"))   
  lPnl.ResizeInterior = True
  lPnl.ResizeEnabled = True
  lPnl.Estilo = 0
  lPnl.Visible = True
  lPnl.Top = 0
  lPnl.Width = gForm.Width - 200
  lPnl.Height = 5000

  Set lGrid = gForm.Controls.Add("AhoraOCX.cntGridUsuario", "grdEquiposGastos",lPnl )
  lGrid.Visible = True
  lGrid.AplicaEstilo  
  lPnl.ResizeEnabled = True
  lgrid.Width = lPnl.width 
  lgrid.height = lPnl.Height
  lGrid.ActivarScripts=True
  lGrid.Enabled = True
  
     With gForm.Controls("grdEquiposGastos")       
        
     .Agregar = True
     .Editar = True
     .Eliminar = True
     .CargaObjetos = False
     .EditarPorObjeto = False
     

     .AgregaColumna "IdPresupuesto", 0, "IdPresupuesto"
     .AgregaColumna "IdEquipo", 3000, "Equipo", False, "Select IdEquipo as ID, IdEquipo, Descrip from Pers_Equipos where Staff = 0"
	'.AgregaColumna "@Equipo", 3000, "Equipo", True, "Select IdEquipo as ID, Descrip from Pers_Equipos"
     .AgregaColumna "PorcGastosFijos", 1000, "%Gasto Fijo", False
	.AgregaColumna "PorcGastosEstructura", 1200, "%Gasto Estruct.", False
      .AgregaColumna "GastosEnero", 1000, "Gasto Enero", False,,,"#,##0.00"
      .AgregaColumna "GastosFebrero", 1000, "Gasto Febrero", False,,,"#,##0.00"
      .AgregaColumna "GastosMarzo", 1000, "Gasto Marzo", False,,,"#,##0.00"
      .AgregaColumna "GastosAbril", 1000, "Gasto Abril", False,,,"#,##0.00"
      .AgregaColumna "GastosMayo", 1000, "Gasto Mayo", False,,,"#,##0.00"
      .AgregaColumna "GastosJunio", 1000, "Gasto Junio", False,,,"#,##0.00"
      .AgregaColumna "GastosJulio", 1000, "Gasto Julio", False,,,"#,##0.00"
      .AgregaColumna "GastosAgosto", 1000, "Gasto Agosto", False,,,"#,##0.00"
      .AgregaColumna "GastosSeptiembre", 1100, "Gasto Septiembre", False,,,"#,##0.00"
      .AgregaColumna "GastosOctubre", 1000, "Gasto Octubre", False,,,"#,##0.00"
      .AgregaColumna "GastosNoviembre", 1100, "Gasto Noviembre", False,,,"#,##0.00"
      .AgregaColumna "GastosDiciembre", 1000, "Gasto Diciembre", False,,,"#,##0.00"
      
	'.Campo("@Equipo").Sustitucion = "Select Descrip from Pers_Equipos where IdEquipo = @IdEquipo"
	.Campo("IdPresupuesto").Default = gForm.Controls("EObjeto").ObjGlobal.Propiedades("IdPresupuesto")

     .From = "Pers_Presupuestos_Equipos" 
     .TablaObjeto = "Pers_Presupuestos_Equipos"
     .Where = " WHERE IdPresupuesto = '"& gForm.Controls("EObjeto").ObjGlobal.Propiedades("IdPresupuesto") &"'"
     .AplicaEstilo
     .Orden = "IdEquipo"
     .Refrescar
     .Refresca = True  

      .ActivarScripts = True 
      .ValueItems "IdEquipo", "Select IdEquipo, Descrip from Pers_Equipos", False
      
      .MenuItemAdd "Fijar Gasto Personal Mensual","mnuPers_FijarGastoPersonalMensual", 0 ,, True, False, 123
  End With
  
  
  Set lPnl = gForm.Controls.Add("AhoraOCX.cntPanel", "pnlGastosEquiposStaff", gForm.Controls("plnGastos"))   
  lPnl.ResizeInterior = True
  lPnl.ResizeEnabled = True
  lPnl.Estilo = 0
  lPnl.Visible = True
  lPnl.Top = 5100
  lPnl.Width = gForm.Width - 200
  lPnl.Height = 2500

  Set lGrid = gForm.Controls.Add("AhoraOCX.cntGridUsuario", "grdEquiposStaff",lPnl )
  lGrid.Visible = True
  lGrid.AplicaEstilo  
  lPnl.ResizeEnabled = True
  lgrid.Width = lPnl.width 
  lgrid.height = lPnl.Height
  
    Set lPnl = gForm.Controls.Add("AhoraOCX.cntPanel", "pnlGastosOtros", gForm.Controls("plnGastos"))   
  lPnl.ResizeInterior = True
  lPnl.ResizeEnabled = True
  lPnl.Estilo = 0
  lPnl.Visible = True
  lPnl.Top = 7800
  lPnl.Width = gForm.Width - 200
  lPnl.Height = 2500

  Set lGrid = gForm.Controls.Add("AhoraOCX.cntGridUsuario", "grdGastosOtros",lPnl )
  lGrid.Visible = True
  lGrid.AplicaEstilo  
  lPnl.ResizeEnabled = True
  lgrid.Width = lPnl.width 
  lgrid.height = lPnl.Height
  
End Sub

Sub   CargaIngresosVsGastos
Set lPnl5 = gForm.Controls.Add("Threed.SSPanel", "plnIngresos")	
  With lPnl5	
    .Object.AutoSize = 3 'ssChildToPanel	
    .Visible = True	
    gForm.Controls("Pest11").InsertItem 4, "Ingresos Vs Gastos", .Object.Hwnd, 170
  End With
  
  
  Set lPnl = gForm.Controls.Add("AhoraOCX.cntPanel", "pnlIngresosFinal", gForm.Controls("plnIngresos"))   
  lPnl.ResizeInterior = True
  lPnl.ResizeEnabled = True
  lPnl.Estilo = 0
  lPnl.Visible = True
  lPnl.Top = 0
  lPnl.Width = gForm.Width - 200
  lPnl.Height = 4000

  Set lGrid = gForm.Controls.Add("AhoraOCX.cntGridUsuario", "grdIngresosFinal",lPnl )
  lGrid.Visible = True
  lGrid.AplicaEstilo  
  lPnl.ResizeEnabled = True
  lgrid.Width = lPnl.width 
  lgrid.height = lPnl.Height
  lGrid.ActivarScripts=True
  lGrid.Enabled = True
  
     With gForm.Controls("grdIngresosFinal")       
        
     .Agregar = False
     .Editar = False
     .Eliminar = True
     .CargaObjetos = False
     .EditarPorObjeto = False
     

     .AgregaColumna "IdPresupuesto", 0, "IdPresupuesto"
     .AgregaColumna "IdEquipo", 3000, "Equipo", False, "Select IdEquipo as ID, IdEquipo, Descrip from Pers_Equipos where Staff = 0"
	'.AgregaColumna "@Equipo", 3000, "Equipo", True, "Select IdEquipo as ID, Descrip from Pers_Equipos"
	.AgregaColumna "IngresosTotal", 1400, "Ingresos Total", False,,,"#,##0.00",True
      .AgregaColumna "IngresosEnero", 1200, "Ingresos Enero", False,,,"#,##0.00",True
      .AgregaColumna "IngresosFebrero", 1200, "Ingresos Febrero", False,,,"#,##0.00",True
      .AgregaColumna "IngresosMarzo", 1200, "Ingresos Marzo", False,,,"#,##0.00",True
      .AgregaColumna "IngresosAbril", 1200, "Ingresos Abril", False,,,"#,##0.00",True
      .AgregaColumna "IngresosMayo", 1200, "Ingresos Mayo", False,,,"#,##0.00",True
      .AgregaColumna "IngresosJunio", 1200, "Ingresos Junio", False,,,"#,##0.00",True
      .AgregaColumna "IngresosJulio", 1200, "Ingresos Julio", False,,,"#,##0.00",True
      .AgregaColumna "IngresosAgosto", 1200, "Ingresos Agosto", False,,,"#,##0.00",True
      .AgregaColumna "IngresosSeptiembre", 1200, "Ingresos Septiembre", False,,,"#,##0.00",True
      .AgregaColumna "IngresosOctubre", 1200, "Ingresos Octubre", False,,,"#,##0.00",True
      .AgregaColumna "IngresosNoviembre", 1200, "Ingresos Noviembre", False,,,"#,##0.00",True
      .AgregaColumna "IngresosDiciembre", 1200, "Ingresos Diciembre", False,,,"#,##0.00",True
      
	'.Campo("@Equipo").Sustitucion = "Select Descrip from Pers_Equipos where IdEquipo = @IdEquipo"
	'.Campo("IdPresupuesto").Default = gForm.Controls("EObjeto").ObjGlobal.Propiedades("IdPresupuesto")

     .From = "vPers_PresupuestoIngresosVsGastos" 
     .TablaObjeto = "vPers_PresupuestoIngresosVsGastos"
     .Where = " WHERE IdPresupuesto = '"& gForm.Controls("EObjeto").ObjGlobal.Propiedades("IdPresupuesto") &"'"
     .AplicaEstilo
     .Orden = "IdEquipo"
     .Refrescar
     .Refresca = True  

      .ActivarScripts = True 
      .ValueItems "IdEquipo", "Select IdEquipo, Descrip from Pers_Equipos", False
            
  End With
  
  
  Set lPnl = gForm.Controls.Add("AhoraOCX.cntPanel", "pnlGastosFinal", gForm.Controls("plnIngresos"))   
  lPnl.ResizeInterior = True
  lPnl.ResizeEnabled = True
  lPnl.Estilo = 0
  lPnl.Visible = True
  lPnl.Top = 4100
  lPnl.Width = gForm.Width - 200
  lPnl.Height = 4000

  Set lGrid = gForm.Controls.Add("AhoraOCX.cntGridUsuario", "grdGastosFinal",lPnl )
  lGrid.Visible = True
  lGrid.AplicaEstilo  
  lPnl.ResizeEnabled = True
  lgrid.Width = lPnl.width 
  lgrid.height = lPnl.Height
  
  
     With gForm.Controls("grdGastosFinal")       
        
     .Agregar = False
     .Editar = False
     .Eliminar = True
     .CargaObjetos = False
     .EditarPorObjeto = False
     

     .AgregaColumna "IdPresupuesto", 0, "IdPresupuesto"
     .AgregaColumna "IdEquipo", 3000, "Equipo", False, "Select IdEquipo as ID, IdEquipo, Descrip from Pers_Equipos where Staff = 0"
	'.AgregaColumna "@Equipo", 3000, "Equipo", True, "Select IdEquipo as ID, Descrip from Pers_Equipos"
      .AgregaColumna "GastosTotal", 1400, "Gastos Total", False,,,"#,##0.00",True
	  .AgregaColumna "GastosEnero", 1200, "Gastos Enero", False,,,"#,##0.00",True
      .AgregaColumna "GastosFebrero", 1200, "Gastos Febrero", False,,,"#,##0.00",True
      .AgregaColumna "GastosMarzo", 1200, "Gastos Marzo", False,,,"#,##0.00",True
      .AgregaColumna "GastosAbril", 1200, "Gastos Abril", False,,,"#,##0.00",True
      .AgregaColumna "GastosMayo", 1200, "Gastos Mayo", False,,,"#,##0.00",True
      .AgregaColumna "GastosJunio", 1200, "Gastos Junio", False,,,"#,##0.00",True
      .AgregaColumna "GastosJulio", 1200, "Gastos Julio", False,,,"#,##0.00",True
      .AgregaColumna "GastosAgosto", 1200, "Gastos Agosto", False,,,"#,##0.00",True
      .AgregaColumna "GastosSeptiembre", 1200, "Gastos Septiembre", False,,,"#,##0.00",True
      .AgregaColumna "GastosOctubre", 1200, "Gastos Octubre", False,,,"#,##0.00",True
      .AgregaColumna "GastosNoviembre", 1200, "Gastos Noviembre", False,,,"#,##0.00",True
      .AgregaColumna "GastosDiciembre", 1200, "Gastos Diciembre", False,,,"#,##0.00",True
      
	'.Campo("@Equipo").Sustitucion = "Select Descrip from Pers_Equipos where IdEquipo = @IdEquipo"
	'.Campo("IdPresupuesto").Default = gForm.Controls("EObjeto").ObjGlobal.Propiedades("IdPresupuesto")

     .From = "vPers_PresupuestoIngresosVsGastos" 
     .TablaObjeto = "vPers_PresupuestoIngresosVsGastos"
     .Where = " WHERE IdPresupuesto = '"& gForm.Controls("EObjeto").ObjGlobal.Propiedades("IdPresupuesto") &"'"
     .AplicaEstilo
     .Orden = "IdEquipo"
     .Refrescar
     .Refresca = True  

      .ActivarScripts = True 
      .ValueItems "IdEquipo", "Select IdEquipo, Descrip from Pers_Equipos", False
            
  End With
  
  
    Set lPnl = gForm.Controls.Add("AhoraOCX.cntPanel", "pnlMargenFinal", gForm.Controls("plnIngresos"))   
  lPnl.ResizeInterior = True
  lPnl.ResizeEnabled = True
  lPnl.Estilo = 0
  lPnl.Visible = True
  lPnl.Top = 8200
  lPnl.Width = gForm.Width - 200
  lPnl.Height = 4000

  Set lGrid = gForm.Controls.Add("AhoraOCX.cntGridUsuario", "grdMargenFinal",lPnl )
  lGrid.Visible = True
  lGrid.AplicaEstilo  
  lPnl.ResizeEnabled = True
  lgrid.Width = lPnl.width 
  lgrid.height = lPnl.Height
  
  
     With gForm.Controls("grdMargenFinal")       
        
     .Agregar = False
     .Editar = False
     .Eliminar = True
     .CargaObjetos = False
     .EditarPorObjeto = False
     

     .AgregaColumna "IdPresupuesto", 0, "IdPresupuesto"
     .AgregaColumna "IdEquipo", 3000, "Equipo", False, "Select IdEquipo as ID, IdEquipo, Descrip from Pers_Equipos where Staff = 0"
	'.AgregaColumna "@Equipo", 3000, "Equipo", True, "Select IdEquipo as ID, Descrip from Pers_Equipos"
      .AgregaColumna "MargenTotal", 1400, "Margen Total", False,,,"#,##0.00",True
	  .AgregaColumna "MargenEnero", 1200, "Margen Enero", False,,,"#,##0.00",True
      .AgregaColumna "MargenFebrero", 1200, "Margen Febrero", False,,,"#,##0.00",True
      .AgregaColumna "MargenMarzo", 1200, "Margen Marzo", False,,,"#,##0.00",True
      .AgregaColumna "MargenAbril", 1200, "Margen Abril", False,,,"#,##0.00",True
      .AgregaColumna "MargenMayo", 1200, "Margen Mayo", False,,,"#,##0.00",True
      .AgregaColumna "MargenJunio", 1200, "Margen Junio", False,,,"#,##0.00",True
      .AgregaColumna "MargenJulio", 1200, "Margen Julio", False,,,"#,##0.00",True
      .AgregaColumna "MargenAgosto", 1200, "Margen Agosto", False,,,"#,##0.00",True
      .AgregaColumna "MargenSeptiembre", 1200, "Margen Septiembre", False,,,"#,##0.00",True
      .AgregaColumna "MargenOctubre", 1200, "Margen Octubre", False,,,"#,##0.00",True
      .AgregaColumna "MargenNoviembre", 1200, "Margen Noviembre", False,,,"#,##0.00",True
      .AgregaColumna "MargenDiciembre", 1200, "Margen Diciembre", False,,,"#,##0.00",True
      
	'.Campo("@Equipo").Sustitucion = "Select Descrip from Pers_Equipos where IdEquipo = @IdEquipo"
	'.Campo("IdPresupuesto").Default = gForm.Controls("EObjeto").ObjGlobal.Propiedades("IdPresupuesto")

     .From = "vPers_PresupuestoIngresosVsGastos" 
     .TablaObjeto = "vPers_PresupuestoIngresosVsGastos"
     .Where = " WHERE IdPresupuesto = '"& gForm.Controls("EObjeto").ObjGlobal.Propiedades("IdPresupuesto") &"'"
     .AplicaEstilo
     .Orden = "IdEquipo"
     .Refrescar
     .Refresca = True  

      .ActivarScripts = True 
      .ValueItems "IdEquipo", "Select IdEquipo, Descrip from Pers_Equipos", False
            
  End With
  
End Sub


Sub CargaEquiposEmpleados
  Set lPnl3 = gForm.Controls.Add("Threed.SSPanel", "plnEquiposEmpleados")	
  With lPnl3	
    .Object.AutoSize = 3 'ssChildToPanel	
    .Visible = True	
    gForm.Controls("Pest11").InsertItem 5, "Equipos Empleados", .Object.Hwnd, 170
  End With 	

  Set lPnl = gForm.Controls.Add("AhoraOCX.cntPanel", "pnlEquiposEmpleados", gForm.Controls("plnEquiposEmpleados"))   
  lPnl.ResizeInterior = True
  lPnl.ResizeEnabled = True
  lPnl.Estilo = 0
  lPnl.Visible = True
  lPnl.Top = 0
  lPnl.Width = gForm.Width - 200
  lPnl.Height = 5000

  Set lGrid = gForm.Controls.Add("AhoraOCX.cntGridUsuario", "grdEquiposEmpleados",lPnl )
  lGrid.Visible = True
  lGrid.AplicaEstilo  
  lPnl.ResizeEnabled = True
  lgrid.Width = lPnl.width 
  lgrid.height = lPnl.Height
  lGrid.ActivarScripts=True
  lGrid.Enabled = True
  
     With gForm.Controls("grdEquiposEmpleados")       
        
     .Agregar = False
     .Editar = False
     .Eliminar = False
     .CargaObjetos = False
     .EditarPorObjeto = False
     

     '.AgregaColumna "IdPresupuesto", 0, "IdPresupuesto"
     .AgregaColumna "IdEquipo", 3000, "Equipo", True, "Select IdEquipo as ID, IdEquipo, Descrip from Pers_Equipos where Activo=1"
	 .AgregaColumna "Staff", 1000, "Staff", True
	'.AgregaColumna "@Equipo", 3000, "Equipo", True, "Select IdEquipo as ID, Descrip from Pers_Equipos"
    ' .AgregaColumna "PorcGastosFijos", 1000, "%Gasto Fijo", False
	'.AgregaColumna "PorcGastosEstructura", 1200, "%Gasto Estruct.", False
    '  .AgregaColumna "IngresosEnero", 1000, "Ing. Enero", False,,,"#,##0.00"
    '  .AgregaColumna "IngresosFebrero", 1000, "Ing. Febrero", False,,,"#,##0.00"
    '  .AgregaColumna "IngresosMarzo", 1000, "Ing. Marzo", False,,,"#,##0.00"
    '  .AgregaColumna "IngresosAbril", 1000, "Ing. Abril", False,,,"#,##0.00"
    '  .AgregaColumna "IngresosMayo", 1000, "Ing. Mayo", False,,,"#,##0.00"
    '  .AgregaColumna "IngresosJunio", 1000, "Ing. Junio", False,,,"#,##0.00"
    '  .AgregaColumna "IngresosJulio", 1000, "Ing. Julio", False,,,"#,##0.00"
    '  .AgregaColumna "IngresosAgosto", 1000, "Ing. Agosto", False,,,"#,##0.00"
    '  .AgregaColumna "IngresosSeptiembre", 1100, "Ing. Septiembre", False,,,"#,##0.00"
    '  .AgregaColumna "IngresosOctubre", 1000, "Ing. Octubre", False,,,"#,##0.00"
    '  .AgregaColumna "IngresosNoviembre", 1100, "Ing. Noviembre", False,,,"#,##0.00"
    '  .AgregaColumna "IngresosDiciembre", 1000, "Ing. Diciembre", False,,,"#,##0.00"
      
	'.Campo("@Equipo").Sustitucion = "Select Descrip from Pers_Equipos where IdEquipo = @IdEquipo"
	'.Campo("IdPresupuesto").Default = gForm.Controls("EObjeto").ObjGlobal.Propiedades("IdPresupuesto")

     .From = "Pers_Equipos" 
     .TablaObjeto = "Pers_Equipos"
     '.Where = " WHERE IdPresupuesto = '"& gForm.Controls("EObjeto").ObjGlobal.Propiedades("IdPresupuesto") &"'"
     .AplicaEstilo
     .Orden = "IdEquipo"
     .Refrescar
     .Refresca = True  

      .ActivarScripts = True 
	  
	  .ValueItems "IdEquipo", "Select IdEquipo, Descrip from Pers_Equipos", False
      
  End With

  
  
  Set lPnl = gForm.Controls.Add("AhoraOCX.cntPanel", "pnlEmpleados", gForm.Controls("plnEquiposEmpleados"))   
  lPnl.ResizeInterior = True
  lPnl.ResizeEnabled = True
  lPnl.Estilo = 0
  lPnl.Visible = True
  lPnl.Top = 5500
  lPnl.Width = gForm.Width - 200
  lPnl.Height = 5000

  Set lGrid = gForm.Controls.Add("AhoraOCX.cntGridUsuario", "grdEmpleados",lPnl )
  lGrid.Visible = True
  lGrid.AplicaEstilo  
  lPnl.ResizeEnabled = True
  lgrid.Width = lPnl.width 
  lgrid.height = lPnl.Height
  
 
End Sub

'Para Activar este evento hay que configurar la grid. Poner en el sub Initialize por ejemplo: gForm.grdLineas.ActivarScripts = True
Sub Grid_RowColChange(aGrid, LastRow, LastCol)
  If aGrid.Name = "grdEquipos" Then
    lIdEquipo = aGrid.GetValue("IdEquipo")
    If Len("" & lIdEquipo)>0 Then
      CargaGridProyectosEquipos(lIdEquipo)
    Else
      gForm.Controls("grdProyectos").LimpiaGrid
    End If
  End If
 
 If aGrid.Name = "grdProyectos2" Then
    lIdProyecto = aGrid.GetValue("IdProyecto")
    If Len("" & lIdProyecto )>0 Then
      CargaGridEquiposProyectos(lIdProyecto)
    Else 
      gForm.Controls("grdEquipos2").LimpiaGrid
    End If
 End If
 
  If aGrid.Name = "grdEquiposGastos" Then
    lIdEquipo = aGrid.GetValue("IdEquipo")
     If Len("" & lIdEquipo)>0 Then
        CargaGridGastosEquiposStaffyOtros(lIdEquipo)
     Else 
       gForm.Controls("grdEquiposStaff").LimpiaGrid 
       gForm.Controls("grdGastosOtros").LimpiaGrid 
     End If
 End If
 
   If aGrid.Name = "grdEquiposEmpleados" Then
    lIdEquipo = aGrid.GetValue("IdEquipo")
    If Len("" & lIdEquipo)>0 Then
      CargaGridEquiposEmpleados(lIdEquipo)
    Else
      gForm.Controls("grdEmpleados").LimpiaGrid
    End If
  End If
End Sub

Sub CargaGridProyectosEquipos (IdEquipo)
    gForm.Controls("grdProyectos").LimpiaGrid 
   With gForm.Controls("grdProyectos")       
        
     .Agregar = True
     .Editar = True
     .Eliminar = True
     .CargaObjetos = False
     .EditarPorObjeto = False
     

     .AgregaColumna "IdPresupuesto", 0, "IdPresupuesto"
     .AgregaColumna "IdEquipo", 0, "IdEq", False, "Select IdEquipo as ID, IdEquipo, Descrip from Pers_Equipos where IdEquipo = " & IdEquipo
'	.AgregaColumna "@Equipo", 3000, "Equipo", True, "Select IdEquipo as ID, Descrip from Pers_Equipos"
	 .AgregaColumna "IdProyecto", 3000, "Proyecto", False, "Select IdProyecto as ID, IdProyecto, Descrip from Proyectos "
	'.AgregaColumna "@Proyecto", 3000, "Proyecto", True, "Select IdProyecto as ID, Descrip from Proyectos"
     .AgregaColumna "Porcentaje", 1000, "%Proyecto", False
      .AgregaColumna "IngresosEnero", 1000, "Ing. Enero", False,,,"#,##0.00"
      .AgregaColumna "IngresosFebrero", 1000, "Ing. Febrero", False,,,"#,##0.00"
      .AgregaColumna "IngresosMarzo", 1000, "Ing. Marzo", False,,,"#,##0.00"
      .AgregaColumna "IngresosAbril", 1000, "Ing. Abril", False,,,"#,##0.00"
      .AgregaColumna "IngresosMayo", 1000, "Ing. Mayo", False,,,"#,##0.00"
      .AgregaColumna "IngresosJunio", 1000, "Ing. Junio", False,,,"#,##0.00"
      .AgregaColumna "IngresosJulio", 1000, "Ing. Julio", False,,,"#,##0.00"
      .AgregaColumna "IngresosAgosto", 1000, "Ing. Agosto", False,,,"#,##0.00"
      .AgregaColumna "IngresosSeptiembre", 1100, "Ing. Septiembre", False,,,"#,##0.00"
      .AgregaColumna "IngresosOctubre", 1000, "Ing. Octubre", False,,,"#,##0.00"
      .AgregaColumna "IngresosNoviembre", 1100, "Ing. Noviembre", False,,,"#,##0.00"
      .AgregaColumna "IngresosDiciembre", 1000, "Ing. Diciembre", False,,,"#,##0.00"
      
	.Campo("IdEquipo").Default = IdEquipo
	.Campo("IdPresupuesto").Default = gForm.Controls("EObjeto").ObjGlobal.Propiedades("IdPresupuesto")
	'.Campo("@Proyecto").Sustitucion = "Select Descrip from Proyectos where IdProyecto = @IdProyecto"
	.Campo("IdProyecto").coleccion = "Proyectos"
	.Campo("IdProyecto").ColeccionWhere = "Where IdProyecto = @IdProyecto"

	

     .From = "Pers_Presupuestos_Equipos_Proyectos" 
     .TablaObjeto = "Pers_Presupuestos_Equipos_Proyectos"
     .Where = " WHERE IdPresupuesto = '"& gForm.Controls("EObjeto").ObjGlobal.Propiedades("IdPresupuesto") &"'" & " AND IdEquipo = " & IdEquipo
     .AplicaEstilo
     .Orden = "IdProyecto"
     .Refrescar
     .Refresca = True  

      .ActivarScripts = True 
      .ValueItems "IdProyecto", "Select IdProyecto, Descrip from Proyectos", False
      
      .MenuItemAdd "Fijar Ingreso Mensual","mnuPers_FijarIngresoMensualProyecto", 0 , ,True, False, 123

	  
  End With
End Sub

Sub CargaGridEquiposProyectos (IdProyecto)
  
  gForm.Controls("grdEquipos2").LimpiaGrid
  With gForm.Controls("grdEquipos2")       
        
     .Agregar = True
     .Editar = True
     .Eliminar = True
     .CargaObjetos = False
     .EditarPorObjeto = False
     

     .AgregaColumna "IdPresupuesto", 0, "IdPresupuesto"
     .AgregaColumna "IdProyecto",0,"IdProyecto"
     .AgregaColumna "IdEquipo", 3000, "Equipo", False, "Select IdEquipo as ID, IdEquipo, Descrip from Pers_Equipos where Staff = 0"
	'.AgregaColumna "@Equipo", 3000, "Equipo", True, "Select IdEquipo as ID, Descrip from Pers_Equipos"
     .AgregaColumna "Porcentaje", 1000, "%Proyecto", False
      .AgregaColumna "IngresosEnero", 1000, "Ing. Enero", False,,,"#,##0.00"
      .AgregaColumna "IngresosFebrero", 1000, "Ing. Febrero", False,,,"#,##0.00"
      .AgregaColumna "IngresosMarzo", 1000, "Ing. Marzo", False,,,"#,##0.00"
      .AgregaColumna "IngresosAbril", 1000, "Ing. Abril", False,,,"#,##0.00"
      .AgregaColumna "IngresosMayo", 1000, "Ing. Mayo", False,,,"#,##0.00"
      .AgregaColumna "IngresosJunio", 1000, "Ing. Junio", False,,,"#,##0.00"
      .AgregaColumna "IngresosJulio", 1000, "Ing. Julio", False,,,"#,##0.00"
      .AgregaColumna "IngresosAgosto", 1000, "Ing. Agosto", False,,,"#,##0.00"
      .AgregaColumna "IngresosSeptiembre", 1100, "Ing. Septiembre", False,,,"#,##0.00"
      .AgregaColumna "IngresosOctubre", 1000, "Ing. Octubre", False,,,"#,##0.00"
      .AgregaColumna "IngresosNoviembre", 1100, "Ing. Noviembre", False,,,"#,##0.00"
      .AgregaColumna "IngresosDiciembre", 1000, "Ing. Diciembre", False,,,"#,##0.00"
      
	'.Campo("@Equipo").Sustitucion = "Select Descrip from Pers_Equipos where IdEquipo = @IdEquipo"
	.Campo("IdPresupuesto").Default = gForm.Controls("EObjeto").ObjGlobal.Propiedades("IdPresupuesto")
	.Campo("IdProyecto").Default = IdProyecto

     .From = "Pers_Presupuestos_Equipos_Proyectos" 
     .TablaObjeto = "Pers_Presupuestos_Equipos_Proyectos"
     .Where = " WHERE IdPresupuesto = '"& gForm.Controls("EObjeto").ObjGlobal.Propiedades("IdPresupuesto") &"' AND IdProyecto = '" & IdProyecto & "'"
     .AplicaEstilo
     .Orden = "IdEquipo"
     .Refrescar
     .Refresca = True  

      .ActivarScripts = True 
	  .ValueItems "IdEquipo", "Select IdEquipo, Descrip from Pers_Equipos", False
	  
     .MenuItemAdd "Fijar Ingreso Mensual","mnuPers_FijarIngresoMensualProyecto", 0 , ,True, False, 123

      
  End With
End Sub


Sub CargaGridGastosEquiposStaffyOtros (IdEquipo)
    gForm.Controls("grdEquiposStaff").LimpiaGrid 
   With gForm.Controls("grdEquiposStaff")       
        
     .Agregar = True
     .Editar = True
     .Eliminar = True
     .CargaObjetos = False
     .EditarPorObjeto = False
     

     .AgregaColumna "IdPresupuesto", 0, "IdPresupuesto"
     .AgregaColumna "IdEquipo", 0, "IdEq", False, "Select IdEquipo as ID, IdEquipo, Descrip from Pers_Equipos where IdEquipo = " & IdEquipo
'	.AgregaColumna "@Equipo", 3000, "Equipo", True, "Select IdEquipo as ID, Descrip from Pers_Equipos"
	 .AgregaColumna "IdEquipoStaff", 3000, "Equipo Staff", False, "Select IdEquipo as ID, IdEquipo, Descrip from Pers_Equipos where staff = 1 "
	'.AgregaColumna "@EquipoStaff", 3000, "Eq. Staff", True, "Select IdEquipo as ID, Descrip from Pers_Equipos"
      .AgregaColumna "GastosEnero", 1000, "Gasto Enero", False,,,"#,##0.00"
      .AgregaColumna "GastosFebrero", 1000, "Gasto Febrero", False,,,"#,##0.00"
      .AgregaColumna "GastosMarzo", 1000, "Gasto Marzo", False,,,"#,##0.00"
      .AgregaColumna "GastosAbril", 1000, "Gasto Abril", False,,,"#,##0.00"
      .AgregaColumna "GastosMayo", 1000, "Gasto Mayo", False,,,"#,##0.00"
      .AgregaColumna "GastosJunio", 1000, "Gasto Junio", False,,,"#,##0.00"
      .AgregaColumna "GastosJulio", 1000, "Gasto Julio", False,,,"#,##0.00"
      .AgregaColumna "GastosAgosto", 1000, "Gasto Agosto", False,,,"#,##0.00"
      .AgregaColumna "GastosSeptiembre", 1100, "Gasto Septiembre", False,,,"#,##0.00"
      .AgregaColumna "GastosOctubre", 1000, "Gasto Octubre", False,,,"#,##0.00"
      .AgregaColumna "GastosNoviembre", 1100, "Gasto Noviembre", False,,,"#,##0.00"
      .AgregaColumna "GastosDiciembre", 1000, "Gasto Diciembre", False,,,"#,##0.00"
      
	.Campo("IdEquipo").Default = IdEquipo
	.Campo("IdPresupuesto").Default = gForm.Controls("EObjeto").ObjGlobal.Propiedades("IdPresupuesto")
	'.Campo("@EquipoStaff").Sustitucion = "Select Descrip from Pers_Equipos where IdEquipo = @IdEquipoStaff"

	

     .From = "Pers_Presupuestos_Equipos_GastosStaff" 
     .TablaObjeto = "Pers_Presupuestos_Equipos_GastosStaff"
     .Where = " WHERE IdPresupuesto = '"& gForm.Controls("EObjeto").ObjGlobal.Propiedades("IdPresupuesto") &"'" & " AND IdEquipo = " & IdEquipo
     .AplicaEstilo
     .Orden = "IdEquipoStaff"
     .Refrescar
     .Refresca = True  

      .ActivarScripts = True 
      
	  .ValueItems "IdEquipoStaff","Select IdEquipo, Descrip from Pers_Equipos", False
	  
	   .MenuItemAdd "Fijar Gasto Staff Mensual","mnuPers_FijarGastoStaffMensual", 0 , ,True, False, 123

	  
  End With
    
  gForm.Controls("grdGastosOtros").LimpiaGrid 
   With gForm.Controls("grdGastosOtros")       
        
     .Agregar = True
     .Editar = True
     .Eliminar = True
     .CargaObjetos = False
     .EditarPorObjeto = False
     

     .AgregaColumna "IdPresupuesto", 0, "IdPresupuesto"
     .AgregaColumna "IdEquipo", 0, "IdEq", False, "Select IdEquipo as ID, IdEquipo, Descrip from Pers_Equipos where IdEquipo = " & IdEquipo
'	.AgregaColumna "@Equipo", 3000, "Equipo", True, "Select IdEquipo as ID, Descrip from Pers_Equipos"
	' .AgregaColumna "IdTipoGasto", 3000, "Gasto", False, "Select IdTipoGasto as ID, IdTipoGasto, Descrip from TiposGastos_Definiciones  "
       .AgregaColumna "IdTipoGasto", 3000, "Gasto", False, "Select IdTipoGasto as ID, IdTipoGasto, Descrip from TiposGastos_Definiciones  "
	'.AgregaColumna "@EquipoStaff", 3000, "Eq. Staff", True, "Select IdEquipo as ID, Descrip from Pers_Equipos"
      .AgregaColumna "GastosEnero", 1000, "Gasto Enero", False,,,"#,##0.00"
      .AgregaColumna "GastosFebrero", 1000, "Gasto Febrero", False,,,"#,##0.00"
      .AgregaColumna "GastosMarzo", 1000, "Gasto Marzo", False,,,"#,##0.00"
      .AgregaColumna "GastosAbril", 1000, "Gasto Abril", False,,,"#,##0.00"
      .AgregaColumna "GastosMayo", 1000, "Gasto Mayo", False,,,"#,##0.00"
      .AgregaColumna "GastosJunio", 1000, "Gasto Junio", False,,,"#,##0.00"
      .AgregaColumna "GastosJulio", 1000, "Gasto Julio", False,,,"#,##0.00"
      .AgregaColumna "GastosAgosto", 1000, "Gasto Agosto", False,,,"#,##0.00"
      .AgregaColumna "GastosSeptiembre", 1100, "Gasto Septiembre", False,,,"#,##0.00"
      .AgregaColumna "GastosOctubre", 1000, "Gasto Octubre", False,,,"#,##0.00"
      .AgregaColumna "GastosNoviembre", 1100, "Gasto Noviembre", False,,,"#,##0.00"
      .AgregaColumna "GastosDiciembre", 1000, "Gasto Diciembre", False,,,"#,##0.00"
      
	.Campo("IdEquipo").Default = IdEquipo
	.Campo("IdPresupuesto").Default = gForm.Controls("EObjeto").ObjGlobal.Propiedades("IdPresupuesto")
	'.Campo("@EquipoStaff").Sustitucion = "Select Descrip from Pers_Equipos where IdEquipo = @IdEquipoStaff"

	

     .From = "Pers_Presupuestos_Equipos_Gastos" 
     .TablaObjeto = "Pers_Presupuestos_Equipos_Gastos"
     .Where = " WHERE IdPresupuesto = '"& gForm.Controls("EObjeto").ObjGlobal.Propiedades("IdPresupuesto") &"'" & " AND IdEquipo = " & IdEquipo
     .AplicaEstilo
     .Orden = "IdTipoGasto"
     .Refrescar
     .Refresca = True  

      .ActivarScripts = True 
      .ValueItems "IdTipoGasto", "Select IdTipoGasto, Descrip from TiposGastos_Definiciones", False
      
      .MenuItemAdd "Fijar Gasto Otros Mensual","mnuPers_FijarGastoOtrosMensual", 0 , ,True, False, 123

      
  End With
End Sub


Sub CargaGridEquiposEmpleados (IdEquipo)
    gForm.Controls("grdEmpleados").LimpiaGrid 
   With gForm.Controls("grdEmpleados")       
        
     .Agregar = True
     .Editar = True
     .Eliminar = True
     .CargaObjetos = False
     .EditarPorObjeto = False
     

     .AgregaColumna "IdPresupuesto", 0, "IdPresupuesto"
     .AgregaColumna "IdEquipo", 0, "IdEq", False, "Select IdEquipo as ID, IdEquipo, Descrip from Pers_Equipos where IdEquipo = " & IdEquipo
'	.AgregaColumna "@Equipo", 3000, "Equipo", True, "Select IdEquipo as ID, Descrip from Pers_Equipos"
	 .AgregaColumna "IdEmpleado", 3000, "Empleado", False, "Select IdEmpleado as ID, IdEmpleado, NombreCompleto from vEmpleados_Datos "
	'.AgregaColumna "@Proyecto", 3000, "Proyecto", True, "Select IdProyecto as ID, Descrip from Proyectos"
     .AgregaColumna "PorcDedicacion", 1000, "%Dedicacion", False
      
	.Campo("IdEquipo").Default = IdEquipo
	.Campo("PorcDedicacion").Default = 100
	.Campo("IdPresupuesto").Default = gForm.Controls("EObjeto").ObjGlobal.Propiedades("IdPresupuesto")
	'.Campo("@Proyecto").Sustitucion = "Select Descrip from Proyectos where IdProyecto = @IdProyecto"
	.campo ("IdEmpleado").coleccion = "Empleados"
      .Campo ("IdEmpleado").ColeccionWhere = "Where IdEmpleado = @IdEmpleado"

	

     .From = "Pers_Presupuestos_Equipos_Empleados" 
     .TablaObjeto = "Pers_Presupuestos_Equipos_Empleados"
     .Where = " WHERE IdPresupuesto = '"& gForm.Controls("EObjeto").ObjGlobal.Propiedades("IdPresupuesto") &"'" & " AND IdEquipo = " & IdEquipo
     .AplicaEstilo
     .Orden = "IdProyecto"
     .Refrescar
     .Refresca = True  

      .ActivarScripts = True 
      .ValueItems "IdEmpleado", "Select IdEmpleado, NombreCompleto from VEmpleados_Datos", False
      
      
	  
  End With
End Sub


Sub Grid_MenuAfterExecute(aGrid,aMenuItem)
  If aMenuItem.Name = "mnuPers_FijarIngresoMensualProyecto" Then
    lIdPresupuesto = gForm.Controls("EObjeto").ObjGlobal.Propiedades("IdPresupuesto")
	lIdEquipo = aGrid.GetValue("IdEquipo")
	lIdProyecto = aGrid.GetValue("IdProyecto")
    If Len("" & lIdPresupuesto & lIdEquipo & lIdProyecto) = 0 Then
      MsgBox "Debe seleccionar un proyecto de un equipo"
      Exit Sub
    End If
    IngresoMensual = InputBox("Introduzca el importe del Ingreso Mensual")
      
      If IsNumeric(IngresoMensual) = False Then
        MsgBox "El formato del importe introducido no es correcto"
        eCancel = True
		Exit Sub
     End If
    FijarIngresoMensualProyecto lIdPresupuesto,lIdEquipo, lIdProyecto, IngresoMensual
	aGrid.Refrescar
	gForm.Controls("grdEquipos").Refrescar
	gForm.Controls("grdProyectos2").Refrescar
  End If
  
  If aMenuItem.Name = "mnuPers_FijarGastoPersonalMensual" Then
    lIdPresupuesto = gForm.Controls("EObjeto").ObjGlobal.Propiedades("IdPresupuesto")
	lIdEquipo = aGrid.GetValue("IdEquipo")
	If Len("" & lIdEquipo ) = 0 Then
      MsgBox "Debe seleccionar un equipo"
      Exit Sub
    End If
    GastoMensual = InputBox("Introduzca el importe del Gasto Mensual")
      
      If IsNumeric(GastoMensual) = False Then
        MsgBox "El formato del importe introducido no es correcto"
        eCancel = True
		Exit Sub
     End If
    FijarGastoPersonalMensual lIdPresupuesto,lIdEquipo, GastoMensual
	aGrid.Refrescar
  End If
  If aMenuItem.Name = "mnuPers_FijarGastoStaffMensual" Then
    lIdPresupuesto = gForm.Controls("EObjeto").ObjGlobal.Propiedades("IdPresupuesto")
	lIdEquipo = aGrid.GetValue("IdEquipo")
	lIdEquipoStaff = aGrid.GetValue("IdEquipoStaff")
    If Len("" & lIdPresupuesto & lIdEquipo & lIdEquipoStaff) = 0 Then
      MsgBox "Debe seleccionar un equipo operativo y un equipo de STAFF"
      Exit Sub
    End If
       GastoMensual = InputBox("Introduzca el importe del Gasto Mensual")
      
      If IsNumeric(GastoMensual) = False Then
        MsgBox "El formato del importe introducido no es correcto"
        eCancel = True
		Exit Sub
     End If
    FijarGastoStaffMensual lIdPresupuesto,lIdEquipo, lIdEquipoStaff, GastoMensual
	aGrid.Refrescar
  End If
  
  If aMenuItem.Name = "mnuPers_FijarGastoOtrosMensual" Then
	lIdPresupuesto = gForm.Controls("EObjeto").ObjGlobal.Propiedades("IdPresupuesto")
    lIdEquipo = aGrid.GetValue("IdEquipo")
	lIdTipoGasto = aGrid.GetValue("IdTipoGasto")
    If Len("" & lIdEquipo & lIdTipoGasto) = 0 Then
      MsgBox "Debe seleccionar un tipo de gasto de un equipo"
      Exit Sub
    End If
        GastoMensual = InputBox("Introduzca el importe del Gasto Mensual")
      
      If IsNumeric(GastoMensual) = False Then
        MsgBox "El formato del importe introducido no es correcto"
        eCancel = True
		Exit Sub
     End If
    FijarGastoOtrosMensual lIdPresupuesto, lIdEquipo, lIdTipoGasto, GastoMensual
	aGrid.Refrescar
  End If
End Sub

Sub FijarIngresoMensualProyecto (lIdPresupuesto,lIdEquipo, lIdProyecto, IngresoMensual)
	Set lColParam = gcn.dameNewCollection
    lColParam.Add lIdPresupuesto
	lColParam.Add lIdEquipo
	lColParam.Add lIdProyecto
	lColParam.Add IngresoMensual
	'lColParam.Add ""

    If gCn.EjecutaStoreCol("pPers_FijarIngresoMensualProyecto",lColParam) = True Then
      MsgBox "Ingresos modificados correctamente"
    Else
	    If Len("" & CStr(lColParam.Item(2))) > 0 Then
			MsgBox "Error modificando ingresos" & vbcrlf & CStr(lColParam.Item(2))
		End If
    End If  
End Sub

Sub FijarGastoPersonalMensual(lIdPresupuesto,lIdEquipo, GastoMensual)
Set lColParam = gcn.dameNewCollection
    lColParam.Add lIdPresupuesto
	lColParam.Add lIdEquipo
	lColParam.Add GastoMensual
	'lColParam.Add ""

    If gCn.EjecutaStoreCol("pPers_FijarGastoPersonalMensual",lColParam) = True Then
      MsgBox "Ingresos modificados correctamente"
    Else
	    If Len("" & CStr(lColParam.Item(2))) > 0 Then
			MsgBox "Error modificando ingresos" & vbcrlf & CStr(lColParam.Item(2))
		End If
    End If 
End Sub

Sub FijarGastoStaffMensual(lIdPresupuesto,lIdEquipo, lIdEquipoStaff, GastoMensual)
Set lColParam = gcn.dameNewCollection
    lColParam.Add lIdPresupuesto
	lColParam.Add lIdEquipo
	lColParam.Add lIdEquipoStaff
	lColParam.Add GastoMensual
	'lColParam.Add ""

    If gCn.EjecutaStoreCol("pPers_FijarGastoStaffMensual",lColParam) = True Then
      MsgBox "Gastos modificados correctamente"
    Else
	    If Len("" & CStr(lColParam.Item(2))) > 0 Then
			MsgBox "Error modificando gastos" & vbcrlf & CStr(lColParam.Item(2))
		End If
    End If 
End Sub

Sub FijarGastoOtrosMensual(lIdPresupuesto, lIdEquipo, lIdTipoGasto, GastoMensual)
Set lColParam = gcn.dameNewCollection
    lColParam.Add lIdPresupuesto
	lColParam.Add lIdEquipo
	lColParam.Add lIdTipoGasto
	lColParam.Add GastoMensual
	'lColParam.Add ""

    If gCn.EjecutaStoreCol("pPers_FijarGastoOtrosMensual",lColParam) = True Then
      MsgBox "Gastos modificados correctamente"
    Else
	    If Len("" & CStr(lColParam.Item(2))) > 0 Then
			MsgBox "Error modificando gastos" & vbcrlf & CStr(lColParam.Item(2))
		End If
    End If 
End Sub


Sub Botonera_AfterExecute(aBotonera, aBoton)
	If (aBoton.Name = "btnRefrescarTodo") And Not gForm.Eobjeto.ObjGlobal.Nuevo Then
		gForm.Controls("grdEquipos").Refrescar
		gForm.Controls("grdProyectos").Refrescar
		gForm.Controls("grdProyectos2").Refrescar
		gForm.Controls("grdEquipos2").Refrescar
		gForm.Controls("grdEquiposGastos").Refrescar
		gForm.Controls("grdEquiposStaff").Refrescar
		gForm.Controls("grdGastosOtros").Refrescar
		gForm.Controls("grdIngresosFinal").Refrescar
		gForm.Controls("grdGastosFinal").Refrescar
		gForm.Controls("grdMargenFinal").Refrescar
		gForm.Controls("grdEquiposEmpleados").Refrescar
		gForm.Controls("grdEmpleados").Refrescar
		
	End If
End Sub