
Sub Show()

  gForm.Caption = "Formulario imputacion porcentaje Empleado/Proyecto"

  gform.Botonera.BotonAdd "Importar Excel", "BotPers_Importar", , 0, True, 123
  
  gForm.Controls("Botonera").Boton("BotGuardar").Visible = False
  gForm.Controls("Botonera").Boton("BotNuevo").Visible = False
  gForm.Controls("Botonera").Boton("BotImprimir").Visible = False  
  gForm.Controls("Botonera").Boton("BotEliminar").Visible = False

  lSql = "SELECT Mes, NumMes FROM vPers_Meses ORDER BY NumMes"
  CreaCampoCombo "Pers_Mes", gForm.Controls("panMain"), 600, 350, 3000, 300, "Mes", 700, lSql, 2000, "Mes", 8, 0, "NumMes", 8, 2, 2, "X", "X"
  
  lSql = "SELECT 2015 AS Anyo UNION SELECT 2016 UNION SELECT 2017 UNION SELECT 2018 UNION SELECT 2019 UNION SELECT 2020 UNION SELECT 2021 UNION SELECT 2022"
  CreaCampoCombo "Pers_Anyo", gForm.Controls("panMain"), 600, 650, 3000, 300, "Año", 700, lSql, 2000, "Anyo", 8, 0, "", 8, 1, 1, "X", "X"

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
    
    .AplicaEstilo
    .Visible = True
    .Enabled = True
  End With
End Function


Sub Botonera_AfterExecute(aBotonera, aBoton)

If aBoton.Name = "BotPers_Importar" Then
  Set lColParam = gcn.dameNewCollection
  
  If Len("" & gForm.Controls("Pers_Mes").Text) = 0 Or Len("" & gForm.Controls("Pers_Anyo").Text) = 0 Then
    MsgBox "Debe indicar mes y año"
    Exit Sub
  End If
  
  lMes = gCn.DameValorCampo("SELECT Mes FROM vPers_Meses WHERE NumMes = " & gForm.Controls("Pers_Mes").Text)
  If MsgBox ("¿Desea importar las imputaciones del mes " & lMes & " y año " & gForm.Controls("Pers_Anyo").Text & "?", vbYesNo, "Importar Imputaciones") = vbNo Then
    Exit Sub
  End If 

  If gForm.Controls("Pers_Mes").Text < 12 Then
    lFecha = DateAdd("d", -1, CDate("01/" & Right("0" & CStr(gForm.Controls("Pers_Mes").Text + 1), 2) & "/" & gForm.Controls("Pers_Anyo").Text))
  Else
    lFecha = DateAdd("d", -1, CDate("01/01/" & gForm.Controls("Pers_Anyo").Text + 1))
  End If
  
  lFichero = SelectFile()
  
  Set fso = CreateObject("Scripting.FileSystemObject")
  
  If Not fso.FileExists(lFichero) Then
    MsgBox "Fichero " & lFichero & " no existente"
    Exit Sub
  End If
  
  lImportacion = gCn.DameValorCampo("SELECT ISNULL(MAX(IdImportacion),0) + 1 FROM Pers_Importa_Dedicacion_Empleado_Proyecto")
  
  Importar_Excel lImportacion, lFichero, lFecha, lMes, gForm.Controls("Pers_Anyo").Text
    
End If

End Sub

Function SelectFile()
    Dim objExec, strMSHTA, wshShell

    SelectFile = ""

    strMSHTA = "mshta.exe ""about:" & "<" & "input type=file id=FILE>" _
             & "<" & "script>FILE.click();new ActiveXObject('Scripting.FileSystemObject')" _
             & ".GetStandardStream(1).WriteLine(FILE.value);close();resizeTo(0,0);" & "<" & "/script>"""

    Set wshShell = CreateObject("WScript.Shell")
    Set objExec = wshShell.Exec(strMSHTA)

    SelectFile = objExec.StdOut.ReadLine()

    Set objExec = Nothing
    Set wshShell = Nothing
End Function

Sub Importar_Excel(lImportacion, lFichero, lFecha, lMes, lAnyo)

    Dim row 'As long
    Dim col
    Dim l

    row = 3
    col = 3
    l = 1

    'Abrir el Excel'
    Set objExcel = CreateObject("Excel.Application")  
    Set objWorkbook = objExcel.Workbooks.Open(lFichero)

    objExcel.Worksheets(1).Activate
    
    'Si ya existe una importacion con la fecha de la importacion actual, quitamos el proceso'
    If gCn.DameValorCampo("SELECT Count(1) FROM Pers_Importa_Dedicacion_Empleado_Proyecto WHERE Year(Fecha) = " & Year(lFecha) & " And Month(Fecha) = " & Month(lFecha) & " And IdEmpresa = " & gcn.IdEmpresa) > 0 Then
      MsgBox "La Empresa " & gcn.IdEmpresa & " ya importó las imputaciones de cada empleado/proyecto para este mes y año"
  	  objworkbook.Saved = True 
  	  objWorkbook.Close
      objExcel.Quit  
      Set objExcel = Nothing         
      Exit Sub
    End If

    'Si no, insertamos una linea en Pers_Importa_Nominas'
    lSql = "INSERT INTO Pers_Importa_Dedicacion_Empleado_Proyecto (IdImportacion, Descrip, Fichero, Fecha, IdEmpresa)"
    lSql = lSql & " SELECT " & lImportacion & ", '" & "Imputaciones Empleado " & gCn.DameValorCampo("SELECT Nombre FROM Empresa WHERE IdEmpresa = " & gcn.IdEmpresa) & " " & lMes & " " & lAnyo & "', '" & lFichero & "', '" & lFecha & "', " & gcn.IdEmpresa 
    
    If Not gcn.executeSql(CStr(lSql),,,,False) Then 
  	  objworkbook.Saved = True 
  	  objWorkbook.Close
      objExcel.Quit  
      Set objExcel = Nothing         
      MsgBox "Error importando fichero"
      MsgBox gcn.DameTodosLosErrores,vbcritical,"Error"
      Exit Sub
    End If
   
   'Recoger cada linea (cada  IdEmpleado)'
    While Len("" & objExcel.ActiveSheet.Cells(row, 1)) > 0
      'Recogemos cada columna para la linea activa (cada proyectos)' 
      While Len("" & objExcel.ActiveSheet.Cells(1, col)) > 0

      
        porcentaje_Empleado = objExcel.ActiveSheet.Cells(row, col)
        idEmpleado = objExcel.ActiveSheet.Cells(row, 1)
        idProyecto = objExcel.ActiveSheet.Cells(1, col)
        
        If Not Len("" & objExcel.ActiveSheet.Cells(row, col)) > 0 Then
          porcentaje_Empleado = 0
        End If

        lSql = "INSERT INTO Pers_Importa_Dedicacion_Empleado_Proyecto_Lineas (IdImportacion, IdLinea, Fecha, IdEmpleado, IdProyecto, PorcentajeDedic)"
        lSql = lSql & " SELECT " & lImportacion & ", " & l & ", '" & lFecha & "', " & idEmpleado & ", '" & idProyecto & "', " & Replace(porcentaje_Empleado, ",", ".") 

        If Not gcn.executeSql(CStr(lSql),,,,False) Then 
          objworkbook.Saved = True 
          objWorkbook.Close
          objExcel.Quit  
          Set objExcel = Nothing         
          MsgBox "Error importando fichero"
          MsgBox gcn.DameTodosLosErrores,vbcritical,"Error"
          Exit Sub
        End If

        l = l + 1
        col = col +1
      Wend

    row = row + 1
    col = 3 

    Wend

    objworkbook.Saved = True 
    objWorkbook.Close
    objExcel.Quit  
    Set objExcel = Nothing

    Set lColParam = gcn.dameNewCollection
    lColParam.Add lImportacion
    lColParam.Add ""

    If gCn.EjecutaStoreCol("pPers_Importar_Imputacion_Empleado_Proyecto",lColParam) = True Then
      MsgBox "Imputaciones importadas correctamente"
    Else
      On Error Resume Next
      If Len("" & CStr(lColParam.Item(2))) > 0 Then
        MsgBox "Error importando las imputaciones. Los valores afectados son:" & vbcrlf & CStr(lColParam.Item(2))
      End If
    End If  
End Sub
