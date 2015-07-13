
Sub Show()

  gForm.Caption = "Formulario importacion de Nómina"

  gform.Botonera.BotonAdd "Importar Nómina", "BotPers_Importar", , 0, True, 123
  
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
  If MsgBox ("¿Desea importar la nómina del mes " & lMes & " y año " & gForm.Controls("Pers_Anyo").Text & "?", vbYesNo, "Importar nómina") = vbNo Then
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
  
  lImportacion = gCn.DameValorCampo("SELECT ISNULL(MAX(IdImportacion),0) + 1 FROM Pers_Importa_Nominas")
  
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
    Dim i
    Dim lFecha_Apunte
    Dim x

    lFecha_Apunte = lFecha

    Set objExcel = CreateObject("Excel.Application")  
    ' abre el xls  
    Set objWorkbook = objExcel.Workbooks.Open(lFichero)

      row = 2
      i = 1
      objExcel.Worksheets(1).Activate
      x = gcn.IdEmpresa
      
      'Si ya existe una importacion con la fecha de la importacion actual, quitamos el proceso'
      If gCn.DameValorCampo("SELECT Count(1) FROM Pers_Importa_Nominas WHERE Year(Fecha) = " & Year(lFecha_Apunte) & " AND Month(Fecha) = " & Month(lFecha_Apunte)) > 0 Then
        MsgBox "La Empresa " & x & " ya importó la nómina para este mes y año"
        objworkbook.Saved = True 
        objWorkbook.Close
        objExcel.Quit  
        Set objExcel = Nothing         
        Exit Sub
      End If

      'Si no, insertamos una linea en Pers_Importa_Nominas'
      lSql = "INSERT INTO Pers_Importa_Nominas (IdImportacion, Descrip, Fichero, Fecha, IdEmpresa)"
      lSql = lSql & " SELECT " & lImportacion & ", '" & "Nómina " & gCn.DameValorCampo("SELECT Nombre FROM Empresa WHERE IdEmpresa = " & x) & " " & lMes & " " & lAnyo & "', '" & lFichero & "', '" & lFecha_Apunte & "', " & x 
      
      If Not gcn.executeSql(CStr(lSql),,,,False) Then 
        objworkbook.Saved = True 
        objWorkbook.Close
        objExcel.Quit  
        Set objExcel = Nothing         
        MsgBox "Error importando fichero"
        MsgBox gcn.DameTodosLosErrores,vbcritical,"Error"
        Exit Sub
      End If
     
     'Recogemos el Excel linea por linea hasta que encontremos una celda en la columna NIF que este vacia'
      While Len("" & objExcel.ActiveSheet.Cells(row, 20)) > 0 
        lTrabajador = objExcel.ActiveSheet.Cells(row, 2)
        lNIF = objExcel.ActiveSheet.Cells(row, 20)
        lFecha = objExcel.ActiveSheet.Cells(row, 23)
        lBruto = objExcel.ActiveSheet.Cells(row, 7)
        lIRPF = -1 * objExcel.ActiveSheet.Cells(row, 9)
        lSS_TRAB = -1 * objExcel.ActiveSheet.Cells(row, 8)
        lLiquido = objExcel.ActiveSheet.Cells(row, 11)
        lCosteSS = objExcel.ActiveSheet.Cells(row, 15)
        lCosteACC = objExcel.ActiveSheet.Cells(row, 16)
        lTotalCoste = objExcel.ActiveSheet.Cells(row, 18)
        lSalarioBase = objExcel.ActiveSheet.Cells(row, 3)
        
        If Len("" & lBruto) = 0 Then
          lBruto = 0
        End If
        If Len("" & lIRPF) = 0 Then
          lIRPF = 0
        End If
        If Len("" & lSS_TRAB) = 0 Then
          lSS_TRAB = 0
        End If
        If Len("" & lLiquido) = 0 Then
          lLiquido = 0
        End If
        If Len("" & lCosteSS) = 0 Then
          lCosteSS = 0
        End If
        If Len("" & lCosteACC) = 0 Then
          lCosteACC = 0
        End If
        If Len("" & lTotalCoste) = 0 Then
          lTotalCoste = 0
        End If
        If Len("" & lSalarioBase) = 0 Then
         lSalarioBase = 0
        End If
        
        lSql = "INSERT INTO Pers_Importa_Nominas_Lineas (IdImportacion, IdLinea, Fecha, TRABAJADOR, NIF, Bruto, IRPF, SS_Trab, Liquido, SS, ACC, Total_Coste_SS, SalarioBase)"
        lSql = lSql & " SELECT " & lImportacion & ", " & i & ", '" & lFecha & "', '" & lTrabajador & "', '" & lNIF & "', " & Replace(lBruto, ",", ".") 
        lSql = lSql & ", " & Replace(lIRPF, ",", ".") & ", " & Replace(lSS_Trab, ",", ".") & ", " & Replace(lLiquido, ",", ".") & ", " & Replace(lCosteSS, ",", ".") & ", " & Replace(lCosteACC, ",", ".")
        lSql = lSql & ", " & Replace(lTotalCoste, ",", ".") & " , " & Replace(lSalarioBase, ",", ".")
         
        If Not gcn.executeSql(CStr(lSql),,,,False) Then 
          objworkbook.Saved = True 
          objWorkbook.Close
          objExcel.Quit  
          Set objExcel = Nothing        
          MsgBox "Error importando fichero"
          MsgBox gcn.DameTodosLosErrores,vbcritical,"Error"
          Exit Sub
        End If
        row = row + 1
        i = i + 1      
      Wend

    objworkbook.Saved = True 
    objWorkbook.Close
    objExcel.Quit  
    Set objExcel = Nothing 
    Set lObj = gCn.Obj.DameColeccion("Pers_Nominas", "WHERE IdImportacion = (" & CStr(lImportacion) & ")")
    If Not lObj Is Nothing Then
      gForm.Controls("Botonera").Boton("BotPers_Importar").Visible = False
      lObj.Show      
    Else
  MsgBox "No se pudo acceder a las nóminas generadas"
    End If
End Sub