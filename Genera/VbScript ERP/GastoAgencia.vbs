Sub Show()
  
  If gForm.Controls("EObjeto").ObjGlobal.Propiedades("IdGastoAgencia") = "" Then
  
    lastId = gcn.dameValorCampo("select isnull(max(IdGastoAgencia),0) + 1 from Pers_GastosAgencia_Cabecera")
    gForm.Controls("TextoUsuario")(2).text = lastId
    
    gForm.Botonera.Boton("btImportGasto").Visible = False
    gForm.Botonera.Boton("btGenerarPed").Visible = False
    gForm.Botonera.Boton("btVerPed").Visible = False
    
  Else

    If gcn.dameValorCampo("select IdPedidoProv from Pers_GastosAgencia_Cabecera where IdGastoAgencia = "&gForm.Controls("TextoUsuario")(2).text&"") > 0 Then
      gForm.Botonera.Boton("btGenerarPed").Visible = False
      gForm.Botonera.Boton("btVerPed").Visible = True
    Else
      gForm.Botonera.Boton("btGenerarPed").Visible = True
      gForm.Botonera.Boton("btVerPed").Visible = False
    End If
  End If
  
  gForm.Controls("TextoUsuario")(5).CaptionLink = True
  gForm.Controls("ComboUsuario")(1).CaptionLink = True
  gForm.Controls("ComboUsuario")(2).CaptionLink = True

  CrearGridAgenciaLineas

End Sub

Sub Initialize()

  gform.Botonera.ActivarScripts = True 
  gform.Botonera.BotonAdd " Generar pedido", "btGenerarPed", , , , 340
  gform.Botonera.BotonAdd " Ver pedido", "btVerPed", , , , 340
  gform.Botonera.BotonAdd " Importar Excel Gasto", "btImportGasto", , , , 433
  gForm.Botonera.HabilitaBotones
  
End Sub

Sub CrearGridAgenciaLineas()
  
  Set lGrid = gForm.Controls.Add("AhoraOCX.cntGridUsuario", "GridAgenciaLineas",gForm.Controls("cntPanel")(2))
  
  gForm.Controls("cntPanel")(2).ResizeInterior = True
  gForm.Controls("cntPanel")(2).ResizeEnabled = True
  
  lGrid.Visible = True
  lGrid.AplicaEstilo
  lGrid.Top = 500
  lGrid.Width = gForm.Controls("cntPanel")(2).width 
  lGrid.height = gForm.Controls("cntPanel")(2).height
  
  With lGrid 
    If Not .Preparada Then
      '.Enabled=Not gForm.Eobjeto.ObjGlobal.Nuevo          
      .Agregar = True
      .Editar = False
      .Eliminar = True
      .CargaObjetos = False
      .EditarPorObjeto = False
      .Grid.HeadLines = 2
      .ActivarScripts = True
      
      .AgregaColumna "IdGastoAgencia", 0, "IdGastoAgencia",False
      .AgregaColumna "IdGastoAgenciaLinea", 0, "IdGastoAgenciaLinea",False
      .AgregaColumna "IdProyecto", 2000, "Codigo proyecto",False
      .AgregaColumna "IdProyectoAgencia", 2000, "Codigo proyecto interno a la agencia",False
      .AgregaColumna "Importe", 1000, "Importe",False,,,"#,##0.00"
      .AgregaColumna "@DescripProyecto", 5000, "Descripcion",True
      
      .FROM = "Pers_GastosAgencia_Lineas"
      .where = "Where IdGastoAgencia = '"&gForm.Controls("TextoUsuario")(2).text&"'"
      
      .Campo("@DescripProyecto").Sustitucion = "Select Descrip from Proyectos where IdProyecto = @IdProyecto"
      .campo("IdProyecto").Coleccion = "Proyectos"
      .campo("IdProyecto").ColeccionWhere = "Where IdProyecto = @IdProyecto"
      .campo("IdGastoAgencia").default = gForm.Controls("EObjeto").ObjGlobal.Propiedades("IdGastoAgencia")
      .campo("IdGastoAgenciaLinea").default = "Select isnull(max(IdGastoAgenciaLinea),0) +1 from Pers_GastosAgencia_Lineas"
      
      .ColumnaEscalada = "@DescripProyecto"
      .Refresca = True
    End If 
  End With
End Sub

Sub GenerarPedidosProveedor()
    Set lColparams = gcn.DameNewCollection
    
    IdEmpresa = gcn.IdEmpresa
    IdProveedor = gForm.Controls("ComboUsuario")(2).text                   
    Fecha = gForm.Controls("TextoUsuario")(5).text
    IdEmpleado = gcn.idEmpleado
    IdDepartamento = gcn.idDepartamento   
    IdGastoAgencia = gForm.Controls("EObjeto").ObjGlobal.Propiedades("IdGastoAgencia")
    IdMoneda = gForm.Controls("ComboUsuario")(1).text

                  
    lColparams.add IdEmpresa 
    lColparams.add IdProveedor 
    lColparams.add Fecha 
    lColparams.add IdEmpleado 
    lColparams.add IdDepartamento 
    lColparams.add IdGastoAgencia
    lColparams.add IdMoneda

    
    If Not gcn.EjecutaStoreCol("PPers_GenerarPedidoProveedor_From_Gastos", lColparams) Then
      MsgBox "No se ha podido crear el pedido proveedor asociado al proyecto numero : "&larr(i,lgrd.colindex("IdProyecto"))&"" , vbCritical, "Error creando pedido cliente"
    Else
      MsgBox "Pedido proveedor generado" , vbInformation, "Informacion"
      gForm.Botonera.Boton("btGenerarPed").Visible = False
      gForm.Botonera.Boton("btVerPed").Visible = True
    End If 
End Sub

Sub Botonera_BeforeExecute(aBotonera, aBoton, aCancel)

  If aBoton.Name = "botGuardar" Then
    
    'Comprobar que los campos obligatorios esten rellenos (da un fallo con la configuracion manual...)
    'Los campos obligatorios son : Cliente, Moneda y Fecha. Si el Id ingreso no esta relleno, hay que rellenarlo automaticamente
    
    vProveedor = gForm.Controls("ComboUsuario")(2).text
    vMoneda = gForm.Controls("ComboUsuario")(1).text
    vFechaIngreso = gForm.Controls("TextoUsuario")(5).text
        
    If Len(vProveedor) = 0 Or Len(vMoneda) = 0 Or Len(vFechaIngreso) = 0 Then
      aCancel = True
      MsgBox "No se ha podido guardar. Los campos Proveedor, Moneda y Fecha tiene que ser rellenados",vbExclamation,"Informacion"
    Else
      gForm.Botonera.Boton("btImportGasto").Visible=True
    End If  
  End If
End Sub

Sub Botonera_AfterExecute(aBotonera, aBoton)
  If aBoton.Name = "btGenerarPed" Then
    
    'codigo para genera x pedidos proveedores que contenga una linea con el importe que va al tercero dependiente del porcentage establecido al principio del proyecto
    GenerarPedidosProveedor
  End If

  If aBoton.Name = "btImportGasto" Then
    lFichero = SelectFile()
    
    Set fso = CreateObject("Scripting.FileSystemObject")
    
    If Not fso.FileExists(lFichero) Then
      MsgBox "Fichero " & lFichero & " no existente"
      Exit Sub
    End If
    
    ImportarExcel lFichero
    
  End If

  If aBoton.Name = "btVerPed" Then
    Set lColPedProv = gcn.obj.dameColeccion("PedidosProv","Where IdPedido in (select distinct IdPedidoProv from Pers_GastosAgencia_Cabecera where IdGastoAgencia = "&gForm.Controls("EObjeto").ObjGlobal.Propiedades("IdGastoAgencia")&" )")
     If Not lColPedProv Is Nothing Then 
      If lColPedProv.Count>0 Then
        lColPedProv.show
      End If
     End If
  End If
End Sub

Sub ImportarExcel(lFichero )
  'Abrir el fichero Excel
  Set objExcel = CreateObject("Excel.Application")
  Set objWorkbook = objExcel.Workbooks.Open(lFichero)
  
  row = 2
  claveImportacion = gcn.IdEmpleado & "_" & RandomString
  IdProveedor = gForm.Controls("ComboUsuario")(2).text
  IdGastoAgencia = gForm.Controls("TextoUsuario")(2).text
  
  'Selecionar la primera hoja
  objExcel.Worksheets(1).Activate
  
  'Comprobar que las 2 primeras columnas existen
  
  While Len("" & objExcel.ActiveSheet.Cells(row, 1)) > 0
    IdProyectoAgencia =  objExcel.ActiveSheet.Cells(row, 1)
    ImporteGasto = Replace(objExcel.ActiveSheet.Cells(row, 2),",",".")
    IdLineaImport = gcn.dameValorCampo("select isnull(max(IdLineaImportacion), 1) +1 from Pers_Log_Importacion_GastoAgencia")
    
    'Insertar en base de datos los datos para comprobar la integridad de los datos
    lSql = "insert into Pers_Log_Importacion_GastoAgencia(IdLineaImportacion, ClaveImportacion, IdGastoAgencia, IdProyectoAgencia, Importe) values ("&IdLineaImport&",'"&claveImportacion&"',"&IdGastoAgencia&",'"&IdProyectoAgencia&"',"&ImporteGasto&")"
    
    'Si el insert falla, sacar um mensaje de error y detener la importacion
    If Not gcn.executeSql(CStr(lSql),,,,False) Then 
      objworkbook.Saved = True 
      objWorkbook.Close
      objExcel.Quit  
      Set objExcel = Nothing         
      Exit Sub
    End If
    
    'Ir a la linea siguiente   
    row = row + 1
  Wend

  objExcel.Quit
  
  'Despues de la importacion de las lineas, abrir un formulario de mantenimiento para ver las limeas importadas y indicar con una regla de color si existe un error o no
  Set params = gcn.DameNewCollection
  params.Add claveImportacion
  params.Add IdProveedor
    
  If gcn.EjecutaStoreCol("pPers_Importar_Datos_ImportGasto", params) Then  
    gForm.Controls("GridAgenciaLineas").Refrescar
    
    If gcn.dameValorCampo("select count(IdGastoAgenciaLinea) from Pers_GastosAgencia_Lineas where IdGastoAgencia = "&gForm.Controls("TextoUsuario")(2).text&"") > 0 Then
      gForm.Botonera.Boton("btGenerarPed").Visible = True
    End If
    
    If MsgBox("Importacion terminada, quereis ver el importe de inportacion ?", vbYesNo, "Confirmacion") = vbYes Then
       AbrirFormImportacion(claveImportacion)
    End If
  End If

  gForm.Controls("GridAgenciaLineas").Refrescar

  gform.Eobjeto.Refresh

End Sub

Sub AbrirFormImportacion(lClaveUser)

  Set lFrm = gcn.ahoraproceso ("NewFrmMantenimiento",False,gcn)
  lfrm.Form.NombreForm = "Pers_frmMant_Import"
  With lFrm.Grid("Comprobacion de los datos a importar") ' NO_TRADUCIR_TAG
      .Agregar = True
      .Editar = True
      .Eliminar = True
      .CargaObjetos = False
      .EditarPorObjeto = False
      .Grid.HeadLines = 2
      .AgregaColumna "IdLineaImportacion", 0, "Id.LineaImportacion", False
      .AgregaColumna "ClaveImportacion", 0, "Clave importacion", False
      .AgregaColumna "IdGastoAgencia", 0, "Id Gasto Agencia", False
      .AgregaColumna "IdProyectoAgencia", 1000, "Id proyecto",False
      .AgregaColumna "Importe", 1000, "Importe",False,,,"#,##0.00"
      .AgregaColumna "Texto_error", 2500, "Error",True
      
      .From = "Pers_Log_Importacion_GastoAgencia" 
      .Where = "Where ClaveImportacion = '"&lClaveUser&"'"
      
      .ColumnaEscalada = "Texto_error"
      .OrdenMultiple = "IdLineaImportacion"
      .RefrescaSinLoad = True 
      .Refresca = True
    End With
    lFrm.Form.Caption = "Comprobar los datos"
    lFrm.Carga , False, 4
End Sub

Function SelectFile()
  Set wShell=CreateObject("WScript.Shell")
  Set oExec=wShell.Exec("mshta.exe ""about:<input type=file id=FILE><script>FILE.click();new ActiveXObject('Scripting.FileSystemObject').GetStandardStream(1).WriteLine(FILE.value);close();resizeTo(0,0);</script>""")
  sFileSelected = oExec.StdOut.ReadLine
  SelectFile = sFileSelected   
End Function

Function RandomString()
  Dim max,min
  max=10000
  min=1
  Randomize
  RandomString = CStr(Int((max-min+1)*Rnd+min))
End Function


