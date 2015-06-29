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


Sub Initialize()
gform.TabDatos.Item(1).VisibleSeg = False
gform.TabDatos.Item(2).VisibleSeg = False
gform.TabDatos.Item(3).VisibleSeg = False
gform.TabDatos.Item(4).VisibleSeg = False

lSQL = "Select Descrip, IdProyecto from vPers_Proyectos WHERE IdProyectoPadre is null and IdProyecto <> " & gForm.Controls("EObjeto").ObjGlobal.Propiedades("IdProyecto")
CreaCampoCombo "Pers_IdProyectoPadre",gForm.Controls("PnlTab")(0), 3390, 2490, 4440, 300, "Proyecto Padre:" ,1500, lSql, 3045, "Descrip", 8, 1000, "IdProyecto", 8, 2, 2, "EObjeto", "IdProyectoPadre"
CreaCampoTexto "Pers_Porcentaje", gForm.Controls("PnlTab")(0), 255, 3650, 3075, 300, "Revenue Share:", 1500, 0, "EObjeto", "Pers_PorcentajeTercero" 
  CreaCampoTexto "Pers_UpFront", gForm.Controls("PnlTab")(0), 255, 1383, 3075, 300, "UpFront:", 1500, 0, "EObjeto", "Pers_UpFront" 
  CreaCampoTexto "Pers_FixFee", gForm.Controls("PnlTab")(0), 255, 1758, 3075, 300, "FixFee:", 1500, 0, "EObjeto", "Pers_FixFee" 
  CreaCampoTexto "Pers_UpFrontAcumulado", gForm.Controls("PnlTab")(0), 3405, 1383, 4400, 300, "UpFront (Pte):", 1500, 0, "EObjeto", "Pers_UpFrontAcumulado" 
  CreaCampoTexto "Pers_GastosAcumulado", gForm.Controls("PnlTab")(0), 3405, 1758, 4400, 300, "Gastos (Pte):", 1500, 0, "EObjeto", "Pers_GastosAcumulado" 

  Set lPnl2 = gForm.Controls.Add("Threed.SSPanel", "pnlAgenciasIngresos") 
  With lPnl2  
    .Object.AutoSize = 3 'ssChildToPanel  
    .Visible = True 
    gForm.Controls("TabDatos").InsertItem 7, "Ag. Ingresos", .Object.Hwnd, 170
    'Set gForm.Controls("PnlTab").COntainer = lPnl2
  End With 
    Set lPnl3 = gForm.Controls.Add("Threed.SSPanel", "pnlAgenciasGastos") 
  With lPnl3  
    .Object.AutoSize = 3 'ssChildToPanel  
    .Visible = True 
    gForm.Controls("TabDatos").InsertItem 8, "Ag. Gastos", .Object.Hwnd, 170
    'Set gForm.Controls("PnlTab").COntainer = lPnl2
  End With  
   Set lPnl4 = gForm.Controls.Add("Threed.SSPanel", "pnlPresupuestos")  
  With lPnl4  
    .Object.AutoSize = 3 'ssChildToPanel  
    .Visible = True 
    gForm.Controls("TabDatos").InsertItem 9, "Presupuestos", .Object.Hwnd, 170
    'Set gForm.Controls("PnlTab").COntainer = lPnl2
  End With  
  'gForm.Width = gForm.Width+500
  CargaGridIngresos
  CargaGridGastos
  CargaGridPresupuestos
  
  gForm.Controls("Botonera").activarScripts = True
End Sub

Sub CargaGridPresupuestos()

  Set lGrid = gForm.Controls.Add("AhoraOCX.cntGridUsuario", "Presupuestos", gForm.Controls("pnlPresupuestos"))
  lGrid.AplicaEstilo  
  With lGrid 
    .Agregar = True
    .Editar = True
    .Eliminar = True      
    .CargaObjetos = False      
    .EditarPorObjeto = False   
    .AgregaColumna "IdProyecto", 0, "IdProyecto", False 
    .AgregaColumna "IdPresupuesto", 3000, "Presupuesto", False, "Select IdPresupuesto, Descrip from Pers_Presupuestos"
    .AgregaColumna "IdEquipo", 3000, "Equipo", False , "Select IdEquipo, Descrip from Pers_Equipos where staff = 0 "
    .AgregaColumna "Porcentaje", 1500, "%Dedicacion", False         
    .From = "Pers_Presupuestos_Equipos_Proyectos"  
    .TablaObjeto = "Pers_Presupuestos_Equipos_Proyectos"
    .Where = "WHERE IdProyecto = " & gForm.Controls("EObjeto").ObjGlobal.Propiedades("IdProyecto")
    .Campo("IdProyecto").Default = gForm.Controls("EObjeto").ObjGlobal.Propiedades("IdProyecto")
    .AplicaEstilo
    .Refresca = True  
    .Visible = True
    
    .ValueItems "IdPresupuesto", "Select IdPresupuesto, Descrip from Pers_Presupuestos", False
  .ValueItems "IdEquipo", "Select IdEquipo, Descrip from Pers_Equipos", False
  
  .campo ("IdPresupuesto").coleccion = "Presupuestos_Gestion"
  .Campo ("IdPresupuesto").ColeccionWhere = "Where IdPresupuesto = @IdPresupuesto"
  End With

End Sub

Sub CargaGridIngresos()


  Set lGrid = gForm.Controls.Add("AhoraOCX.cntGridUsuario", "Ingresos Agencias", gForm.Controls("pnlAgenciasIngresos"))
  lGrid.AplicaEstilo  
  With lGrid 
    .Agregar = True
    .Editar = True
    .Eliminar = True      
    .CargaObjetos = False      
    .EditarPorObjeto = False     
    .AgregaColumna "IdProyecto", 0, ""
    .AgregaColumna "IdCliente", 1800, "Agencia", False , "Select IdCliente, Cliente from Clientes_Datos "
    .AgregaColumna "IdProyectoAgencia", 1500, "ID Proyecto", False
    .AgregaColumna "UsuarioAgencia", 1500, "Usuario", False         
    .From = "Pers_Proyectos_Agencias_Ingresos"  
    .TablaObjeto = "Pers_Proyectos_Agencias_Ingresos"
    .Where = "WHERE IdProyecto = " & gForm.Controls("EObjeto").ObjGlobal.Propiedades("IdProyecto")
    .Campo("IdProyecto").Default = gForm.Controls("EObjeto").ObjGlobal.Propiedades("IdProyecto")
    .AplicaEstilo
    .Refresca = True  
    .Visible = True
    
    .ValueItems "IdCliente", "Select IdCliente, Cliente from Clientes_Datos", False
  End With


End Sub 

Sub CargaGridGastos()

  Set lGrid = gForm.Controls.Add("AhoraOCX.cntGridUsuario", "Gastos Agencias", gForm.Controls("pnlAgenciasGastos"))
  lGrid.AplicaEstilo  
  With lGrid 
    .Agregar = True
    .Editar = True
    .Eliminar = True      
    .CargaObjetos = False      
    .EditarPorObjeto = False     
    .AgregaColumna "IdProyecto", 0, ""
    .AgregaColumna "IdProveedor", 1800, "Agencia", False , "Select IdProveedor, Proveedor  from Prov_Datos "
    .AgregaColumna "IdProyectoAgencia", 1500, "ID Proyecto", False
    .AgregaColumna "UsuarioAgencia", 1500, "Usuario", False         
    .From = "Pers_Proyectos_Agencias_Gastos"  
    .TablaObjeto = "Pers_Proyectos_Agencias_Gastos"
    .Where = "WHERE IdProyecto = " & gForm.Controls("EObjeto").ObjGlobal.Propiedades("IdProyecto")
    .Campo("IdProyecto").Default = gForm.Controls("EObjeto").ObjGlobal.Propiedades("IdProyecto")
    .AplicaEstilo
    .Refresca = True  
    .Visible = True
    
    .ValueItems "IdProveedor", "Select IdProveedor, Proveedor from Prov_Datos", False
  End With


End Sub


Sub Botonera_BeforeExecute(aBotonera, aBoton, aCancel)

  If aBoton.Name = "botGuardar" Then  
    If gForm.Eobjeto.ObjGlobal.Propiedades("IdProyecto") <> "0" Then 
      UpFrontPte = gForm.Controls("Pers_UpFrontAcumulado").text
      UpFrontPteBDD = gcn.DameValorCampo("select Pers_UpFrontAcumulado from Conf_Proyectos where IdProyecto = "&gForm.Controls("IdProyecto").text&"")
      GastosAcumulados = gForm.Controls("Pers_GastosAcumulado").text
      GastosAcumuladosBDD = gcn.DameValorCampo("select Pers_GastosAcumulado from Conf_Proyectos where IdProyecto = "&gForm.Controls("IdProyecto").text&"")
      IdProyecto = gForm.Controls("IdProyecto").text
      vDate = gcn.DameValorCampo("select GETDATE()")
    
      If CDbl(UpFrontPte) <> CDbl(UpFrontPteBDD) Then
        IdLineaMovimientoHistorico = gcn.DameValorCampo("select ISNULL(MAX(IdMovimiento),0) + 1 from Pers_Historico_Mov_UpFrontGastos")
        lSql = "insert into Pers_Historico_Mov_UpFrontGastos(IdMovimiento, TipoMovimiento, Descrip, Importe, IdObjCabecera, IdObjLinea, IdProyecto, FechaMovimiento) values ("&IdLineaMovimientoHistorico&",'UpFront', 'Modificado tras el objeto Proyectos',"&UpFrontPte&",NULL,NULL,"&IdProyecto&",'"&CDate(VDate)&"')" 
      
        If Not gcn.executeSql(CStr(lSql),,,,False) Then          
          MsgBox "Error insertando movimiento"
          MsgBox gcn.DameTodosLosErrores,vbcritical,"Error"
          Exit Sub
        End If 
      End If
      
      If CDbl(GastosAcumulados) <> CDbl(GastosAcumuladosBDD) Then
        IdLineaMovimientoHistorico = gcn.DameValorCampo("select ISNULL(MAX(IdMovimiento),0) + 1 from Pers_Historico_Mov_UpFrontGastos")
        lSql = "insert into Pers_Historico_Mov_UpFrontGastos(IdMovimiento, TipoMovimiento, Descrip, Importe, IdObjCabecera, IdObjLinea, IdProyecto, FechaMovimiento) values ("&IdLineaMovimientoHistorico&",'Gastos', 'Modificado tras el objeto Proyectos',"&GastosAcumulados&",NULL,NULL,"&IdProyecto&",'"&CDate(VDate)&"')" 
      
        If Not gcn.executeSql(CStr(lSql),,,,False) Then          
          MsgBox "Error insertando movimiento"
          MsgBox gcn.DameTodosLosErrores,vbcritical,"Error"
          Exit Sub
        End If 
      End If
    End If
  End If

End Sub
