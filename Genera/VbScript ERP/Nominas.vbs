Sub Initialize()
  gform.Botonera.BotonAdd "Contabilizar", "Bot_Contabiliza", , 0, True, 123
  gform.Botonera.BotonAdd "Ver Asiento", "Bot_VerAsiento", , 0, True, 123
  gform.Botonera.BotonAdd "Contab. Pago", "Bot_ContabilizaPago", , 0, True, 123
  gform.Botonera.BotonAdd "Ver Asiento Pago", "Bot_VerAsientoPago", , 0, True, 123
  gForm.Controls("Botonera").Boton("Bot_Contabiliza").Visible = False
  gForm.Controls("Botonera").Boton("Bot_VerAsiento").Visible = False
  gForm.Controls("Botonera").Boton("Bot_ContabilizaPago").Visible = False
  gForm.Controls("Botonera").Boton("Bot_VerAsientoPago").Visible = False
  
End Sub

Sub Show()
  
  PintaGrid()
  
  gForm.Controls("Botonera").ActivarScripts = True
  
  If gCn.DameValorCampo("SELECT Count(1) FROM Pers_Importa_Nominas WHERE IsNull(IdDocApunte, 0) = 0 AND IsNull(IdDocApunte_SS, 0)= 0 AND IdImportacion=" & gForm.Controls("EObjeto").ObjGlobal.Propiedades("IdImportacion")) > 0 Then
    gForm.Controls("Botonera").Boton("Bot_Contabiliza").Visible = True
  Else
    gForm.Controls("Botonera").Boton("Bot_VerAsiento").Visible = True
  End If

  If gCn.DameValorCampo("SELECT Count(1) FROM Pers_Importa_Nominas WHERE IsNull(IdDocApunte_Pago, 0) = 0 AND IdImportacion=" & gForm.Controls("EObjeto").ObjGlobal.Propiedades("IdImportacion")) > 0 Then
    gForm.Controls("Botonera").Boton("Bot_ContabilizaPago").Visible = True
  Else
    gForm.Controls("Botonera").Boton("Bot_VerAsientoPago").Visible = True
  End If

End Sub

Sub PintaGrid()

  'Impedir la modificacion de lo textBox porque no se rellenan aqui
  gForm.Controls("TextoUsuario")(1).Locked = True
  gForm.Controls("TextoUsuario")(2).Locked = True
  gForm.Controls("TextoUsuario")(3).Locked = True

'Crear el panel
  Set lPnl = gForm.Controls.Add("Threed.SSPanel", "Pers_PanelGrid", gForm.Controls("PnlMain"))
  lPnl.Width = gForm.Width - 500
  lPnl.Height = gForm.Height - 3000
  lPnl.Top = 1500
  lPnl.Left = gForm.Controls("cntPanel")(1).left
  lPnl.Visible= True  
  lPnl.autosize = 3
   
  'Crear el Grid
  Set lGrid = gForm.Controls.Add("AhoraOCX.cntGridUsuario", "Pers_Grid_LineasNominas", lPnl)
  
  With lGrid
    .ResizeEnabled = True
    .ResizeRestanteV = True
    .ResizeRestanteH = True
    .ResizeV = 4
    .AplicaEstilo  
    .Visible = True
    .Agregar = False
    .Editar = False
    .Eliminar = False
    .CargaObjetos = False     
    .EditarPorObjeto = False
    
    .AgregaColumna "Fecha", 0, "Fecha", False
    .AgregaColumna "Trabajador", 3000, "Trabajador",False
    .AgregaColumna "SalarioBase", 1200, "Salario base",,,,"#,##0.00", True
    .AgregaColumna "Bruto", 1200, "Bruto",,,,"#,##0.00", True
    .AgregaColumna "IRPF", 1200, "IRPF",,,,"#,##0.00", True
    .AgregaColumna "SS_Trab", 1200, "SS Trabajador",,,,"#,##0.00", True
    .AgregaColumna "Liquido", 1200, "Liquido",,,,"#,##0.00", True
    .AgregaColumna "SS", 1200, "SS Empresa",,,,"#,##0.00", True
    .AgregaColumna "ACC", 1200, "ACC",,,,"#,##0.00", True
    .AgregaColumna "Total_Coste_SS", 1200, "Total coste SS",,,,"#,##0.00", True
    .AgregaColumna "NIF", 0, "NIF",False
    
    .From = "Pers_Importa_Nominas_Lineas"
    .Where = "Where IdImportacion = "& gForm.Controls("TextoUsuario")(1).text& ""

    .campo ("Trabajador").Coleccion = "Empleados"
    .campo ("Trabajador").ColeccionWhere = "Where NIF = @NIF"
    
    .OrdenMultiple = "Trabajador"
    .RefrescaSinLoad = True 

    .Refresca = True
    
  End With
End Sub

Sub Botonera_AfterExecute(aBotonera, aBoton)

  If aBoton.Name = "Bot_Contabiliza" Then
    Set lColParam = gcn.dameNewCollection
    lColParam.Add gForm.Controls("EObjeto").ObjGlobal.Propiedades("IdImportacion")
    lColParam.Add ""

    If gCn.EjecutaStoreCol("pPers_Nominas_Importar",lColParam) = True Then
      gForm.Controls("Botonera").Boton("Bot_Contabiliza").Visible = False
      gForm.Controls("Botonera").Boton("Bot_VerAsiento").Visible = True
      gForm.Controls("EObjeto").Refresh
      MsgBox "Nómina generada correctamente"
    Else
      On Error Resume Next
      If Len("" & CStr(lColParam.Item(2))) > 0 Then
        MsgBox "Error generando asiento. Los valores afectados son:" & vbcrlf & CStr(lColParam.Item(2))
      End If
    End If  
  End If
  
  If aBoton.Name = "Bot_VerAsiento" Then      
    Dim lAsiento1
    Dim lAsiento2
    Dim lIdEjercicio
    Dim lAsiento
  
    lAsiento1 = gCn.DameValorCampo("SELECT Asiento FROM Conta_Apuntes WHERE IdDoc = " & gForm.Controls("EObjeto").ObjGlobal.Propiedades("IdDocApunte"))
    lAsiento2 = gCn.DameValorCampo("SELECT Asiento FROM Conta_Apuntes WHERE IdDoc = " & gForm.Controls("EObjeto").ObjGlobal.Propiedades("IdDocApunte_SS"))
  
    On Error Resume Next
    If Len("" & lAsiento1) > 0 Then
      lIdEjercicio = gCn.DameValorCampo("SELECT IdEjercicio FROM Conta_Apuntes WHERE IdDoc = " & gForm.Controls("EObjeto").ObjGlobal.Propiedades("IdDocApunte"))
    Else
      If Len("" & lAsiento2) > 0 Then
        lIdEjercicio = gCn.DameValorCampo("SELECT IdEjercicio FROM Conta_Apuntes WHERE IdDoc = " & gForm.Controls("EObjeto").ObjGlobal.Propiedades("IdDocApunte_SS"))
      End If
    End If
    lAsiento = ""
    If Len("" & lAsiento1) > 0 Then
      lAsiento = lAsiento1
      If Len("" & lAsiento2) > 0 Then
        lAsiento = lAsiento & ", " & lAsiento2
      End If      
    Else
      If Len("" & lAsiento2) > 0 Then
        lAsiento = lAsiento2
      End If      
    End If
    
    If Len("" & lAsiento) > 0 Then 
      Set lFrm = gcn.ahoraproceso("ObjFormConta_Apuntes",False)
'     lFrm.carga_extracto CLng(lIdEjercicio), 0, Nothing, CStr(lAsiento) , True
      lFrm.carga_extracto CLng(lIdEjercicio), 0, Nothing, CStr(lAsiento) , True
    Else
      MsgBox "No se pudo acceder a los asientos generados"
    End If
  End If
End Sub 
