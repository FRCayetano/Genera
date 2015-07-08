Sub Initialize()
  gForm.Caption = "Creacion nuevo Presupuesto de gestion"
End Sub

Sub Show()

  gform.Botonera.BotonAdd "Copiar", "BotPers_Crear", , 0, True, 123
  gform.Botonera.BotonAdd "Crear Presupuesto vacio", "BotPers_CrearVacio", , 0, True, 123
  gform.Botonera.ActivarScripts = True
  
  gForm.Controls("Botonera").Boton("BotGuardar").Visible = False
  gForm.Controls("Botonera").Boton("BotNuevo").Visible = False
  gForm.Controls("Botonera").Boton("BotImprimir").Visible = False  
  gForm.Controls("Botonera").Boton("BotEliminar").Visible = False

  lSql = "SELECT CAST(Anyo AS VARCHAR) as Anyo FROM Pers_Presupuestos UNION SELECT 'Nuevo' as Anyo"
  CreaCampoCombo "Pers_Anyo", gForm.Controls("panMain"), 200, 600, 3000, 300, "Copiar estructura del Año : ", 700, lSql, 600, "Anyo", 8, 0, "", 8, 1, 1, "X", "X"

  gForm.Width = 5000
  gForm.Height = 3500
  
End Sub

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
    .CaptionWidth = 2000
    
    .AplicaEstilo
    .Visible = True
    .Enabled = True
  End With
End Function


Sub Botonera_AfterExecute(aBotonera, aBoton)
  
End Sub


Sub Botonera_BeforeExecute(aBotonera, aBoton, aCancel)

  If aBoton.Name = "BotPers_Crear" Then
    
    Set lColparams = gcn.DameNewCollection
    IdPresupuestoNuevo = 0

    If gForm.Controls("Pers_Anyo").text = "Nuevo" Then
      ano = 0
    Else
      ano = CInt(gForm.Controls("Pers_Anyo").text) 
    End If

      lColparams.add CInt(IdPresupuestoNuevo)
      lColparams.add CInt(ano)
      
      If gForm.Controls("Pers_Anyo").text = "Nuevo" Then 
      
      If MsgBox("Crear una estructura de presupuesto vacia  ?", vbYesNo, "Confirmacion ?") = vbNo Then
          aCancel = True
          Exit Sub
      End If
    End If
    
    If Not gcn.EjecutaStoreCol("pPers_CrearEstructuraPresupuesto", lColparams) Then
      MsgBox "No se ha podido crear el nuevo presupuesto" , vbCritical, "Error creando el presupuesto"
    Else
      Set nuevoPresupuesto = gCn.Obj.DameColeccion("Presupuestos_Gestion","Where IdPresupuesto = "& lColparams.item(1) &"")
      If Not nuevoPresupuesto Is Nothing Then  
        nuevoPresupuesto.show
      End If
    End If
   
    End If
End Sub