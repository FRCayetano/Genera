Sub Show()
  
  If gForm.Controls("EObjeto").ObjGlobal.Propiedades("IdIngresoAgencia") = "" Then
  
    lastId = gcn.dameValorCampo("select isnull(max(IdIngresoAgencia),0) + 1 from Pers_IngresoAgencia_Cabecera")
    gForm.Controls("TextoUsuario")(1).text = lastId
    
    gForm.Botonera.Boton("btImportIngreso").Visible = False
    gForm.Botonera.Boton("btGenerarPed").Visible = False
    gForm.Botonera.Boton("btVerPedCli").Visible = False
    gForm.Botonera.Boton("btVerPedPro").Visible = False
    
  Else

    'Si la cebecera de IngresoAgencia ya tiene un nuñero de pedido o si no hay lineas en las lineas del Ingreso, no mostrar el boton para Generar los pedidos'
    If gcn.dameValorCampo("select IdPedido from Pers_IngresoAgencia_Cabecera where IdIngresoAgencia = "&gForm.Controls("EObjeto").ObjGlobal.Propiedades("IdIngresoAgencia")&"") > 0 Or gcn.dameValorCampo("select count(IdIngresoAgenciaLinea) from Pers_IngresoAgencia_Lineas where IdIngresoAgencia = "&gForm.Controls("EObjeto").ObjGlobal.Propiedades("IdIngresoAgencia")&"") = 0 Then
      gForm.Botonera.Boton("btGenerarPed").Visible = False
    Else
      gForm.Botonera.Boton("btGenerarPed").Visible = True
    End If
   
   
    If gcn.dameValorCampo("select IdPedido from Pers_IngresoAgencia_Cabecera where IdIngresoAgencia = "&gForm.Controls("EObjeto").ObjGlobal.Propiedades("IdIngresoAgencia")&"") > 0 Or gcn.dameValorCampo("select count(IdPedidoProv) from Pers_Mapeo_Ingreso_PedidoProv where IdIngresoAgencia = "&gForm.Controls("EObjeto").ObjGlobal.Propiedades("IdIngresoAgencia")&"") > 0 Then
      gForm.Botonera.Boton("btGenerarPed").Visible = False
    End If

    If gcn.dameValorCampo("select IdPedido from Pers_IngresoAgencia_Cabecera where IdIngresoAgencia = "&gForm.Controls("EObjeto").ObjGlobal.Propiedades("IdIngresoAgencia")&"") > 0 Then
      gForm.Botonera.Boton("btVerPedCli").Visible = True
    Else
      gForm.Botonera.Boton("btVerPedCli").Visible = False
    End If
    
    If gcn.dameValorCampo("select count(IdPedidoProv) from Pers_Mapeo_Ingreso_PedidoProv where IdIngresoAgencia = "&gForm.Controls("EObjeto").ObjGlobal.Propiedades("IdIngresoAgencia")&"") > 0 Then
      gForm.Botonera.Boton("btVerPedPro").Visible = True
    Else
      gForm.Botonera.Boton("btVerPedPro").Visible = False
    End If
  End If
  
  gForm.Controls("TextoUsuario")(4).CaptionLink = True
  gForm.Controls("ComboUsuario")(1).CaptionLink = True
  gForm.Controls("ComboUsuario")(2).CaptionLink = True
  
  CrearGridAgenciaLineas

End Sub

Sub Initialize()

  gform.Botonera.ActivarScripts = True
  gform.Botonera.BotonAdd " Generar pedido", "btGenerarPed", , , , 340
  gform.Botonera.BotonAdd " Ver pedido Cliente", "btVerPedCli", , , , 340
  gform.Botonera.BotonAdd " Ver pedido Proveedor", "btVerPedPro", , , , 340
  gform.Botonera.BotonAdd " Importar Excel Ingreso", "btImportIngreso", , , , 433
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
      
      .AgregaColumna "IdIngresoAgencia", 0, "IdIngresoAgencia",False
      .AgregaColumna "IdIngresoAgenciaLinea", 0, "IdIngresoAgenciaLinea",False
      .AgregaColumna "IdProyecto", 2000, "Codigo proyecto",False
      .AgregaColumna "IdProyectoAgencia", 2000, "Codigo proyecto interno a la agencia",False
      .AgregaColumna "Importe", 1000, "Importe",False,,,"#,##0.00"
      .AgregaColumna "@DescripProyecto", 5000, "Descripcion",True
      
      .FROM = "Pers_IngresoAgencia_Lineas"
      .where = "Where IdIngresoAgencia = "&gForm.Controls("TextoUsuario")(1).text&""
      
      .Campo("@DescripProyecto").Sustitucion = "Select Descrip from Proyectos where IdProyecto = @IdProyecto"
      .campo("IdProyecto").Coleccion = "Proyectos"
      .campo("IdProyecto").ColeccionWhere = "Where IdProyecto = @IdProyecto"
      .campo("IdIngresoAgencia").default = gForm.Controls("TextoUsuario")(1).text
      .campo("IdIngresoAgenciaLinea").default = "Select isnull(max(IdIngresoAgenciaLinea),0) +1 from Pers_IngresoAgencia_Lineas"
      .ActivarScripts = True
      
      .ColumnaEscalada = "@DescripProyecto"
      .Refresca = True
    End If 
  End With
End Sub

Sub GenerarPedidosProveedor()
             
  Set lColparams = gcn.DameNewCollection
   
  IdEmpresa = gcn.IdEmpresa
  Fecha = gForm.Controls("TextoUsuario")(4).text
  IdEmpleado = gcn.IdEmpleado
  IdDepartamento = gcn.IdDepartamento
  IdIngresoAgencia = gForm.Controls("TextoUsuario")(1).text
  IdMoneda = gForm.Controls("ComboUsuario")(2).text
      
  lColparams.add IdEmpresa 
  lColparams.add Fecha  
  lColparams.add IdEmpleado 
  lColparams.add IdDepartamento 
  lColparams.add IdIngresoAgencia
  lColparams.add IdMoneda
        
  If Not gcn.EjecutaStoreCol("PPers_GenerarPedidoProveedor_From_Ingreso", lColparams) Then
    MsgBox "No se ha podido crear el pedido proveedor asociado al proyecto numero : "&larr(i,lgrd.colindex("IdProyecto"))&"" , vbCritical, "Error creando pedido proveedor"
  Else
    MsgBox "Pedidos proveedores generados", vbInformation, "Informacion"
    gForm.Botonera.Boton("btVerPedPro").Visible = True
    gForm.Botonera.Boton("btGenerarPed").Visible = False
  End If
End Sub

Sub GenerarPedidoCliente()
    
    Set lColparams = gcn.DameNewCollection
      
    vFecha = gForm.Controls("TextoUsuario")(4).text
    vIdCliente = gForm.Controls("ComboUsuario")(1).text
    vDescripcionPed = gForm.Controls("TextoUsuario")(2).text & " / Ingreso numero : " & gForm.Controls("TextoUsuario")(1).text
    vIdEmpleado = gcn.IdEmpleado
    vIdMoneda = gForm.Controls("ComboUsuario")(2).text
    vIdIngreso = gForm.Controls("TextoUsuario")(1).text
    
    lColparams.add vFecha
    lColparams.add vIdCliente
    lColparams.add vDescripcionPed
    lColparams.add vIdEmpleado
    lColparams.add vIdMoneda
    lColparams.add vIdIngreso
    
    If Not gcn.EjecutaStoreCol("PPers_GenerarPedidoCliente_From_Ingreso", lColparams) Then
      MsgBox "No se ha podido crear el pedido cliente asociado al proyecto numero : "&larr(i,lgrd.colindex("IdProyecto"))&"" , vbCritical, "Error creando pedido cliente"
    Else
      MsgBox "Pedido cliente generado" , vbInformation, "Informacion"
      gForm.Botonera.Boton("btVerPedCli").Visible = True
      gForm.Botonera.Boton("btGenerarPed").Visible = False
    End If 
End Sub


Sub Botonera_BeforeExecute(aBotonera, aBoton, aCancel)

  If aBoton.Name = "botGuardar" Then
    
    'Comprobar que los campos obligatorios esten rellenos (da un fallo con la configuracion manual...)
    'Los campos obligatorios son : Cliente, Moneda y Fecha. Si el Id ingreso no esta relleno, hay que rellenarlo automaticamente
    
    vCliente = gForm.Controls("ComboUsuario")(1).text
    vMoneda = gForm.Controls("ComboUsuario")(2).text
    vFechaIngreso = gForm.Controls("TextoUsuario")(4).text
        
    If Len(vCliente) = 0 Or Len(vMoneda) = 0 Or Len(vFechaIngreso) = 0 Then
      aCancel = True
      MsgBox "No se ha podido guardar. Los campos Cliente, Moneda y Fecha tiene que ser rellenados",vbExclamation,"Informacion"
    Else
      gForm.Botonera.Boton("btImportIngreso").Visible=True
    End If  
  End If
End Sub

Sub Botonera_AfterExecute(aBotonera, aBoton)
  If aBoton.Name = "btGenerarPed" Then
    'codigo para generar el pedido cliente que contenga una linea por cada proyecto presente en el la agencia
    GenerarPedidoCliente
    
    'codigo para genera x pedidos proveedores que contenga una linea con el importe que va al tercero dependiente del porcentage establecido al principio del proyecto
    GenerarPedidosProveedor
  End If

  If aBoton.Name = "btImportIngreso" Then
    lFichero = SelectFile()
    
    Set fso = CreateObject("Scripting.FileSystemObject")
    
    If Not fso.FileExists(lFichero) Then
      MsgBox "Fichero " & lFichero & "no existe"
      Exit Sub
    End If
    
    ImportarExcel lFichero 
    
  End If
  
  If aBoton.Name = "btVerPedCli" Then
     Set lColPedCli = gcn.obj.dameColeccion("Pedidos","where IdPedido in (select distinct idPedido from Pers_IngresoAgencia_Cabecera where IdIngresoAgencia = "&gForm.Controls("EObjeto").ObjGlobal.Propiedades("IdIngresoAgencia")&" )")
     If Not lColPedCli Is Nothing Then 
      If lColPedCli.Count>0 Then
        lColPedCli.show
      End If
     End If
  End If
  
  If aBoton.Name = "btVerPedPro" Then 
    Set lColPedProv = gcn.obj.dameColeccion("PedidosProv","where IdPedido in (select distinct idPedidoProv from Pers_Mapeo_Ingreso_PedidoProv where IdIngresoAgencia = "&gForm.Controls("EObjeto").ObjGlobal.Propiedades("IdIngresoAgencia")&" )")
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
  claveImportacion = gcn.IdEmpleado & "_" & RandomString & "_" & Second(Now())
  IdIngresoAgencia = gForm.Controls("TextoUsuario")(1).text
  
  'Selecionar la primera hoja
  objExcel.Worksheets(1).Activate
  
  'Comprobar que las 2 primeras columnas existen

  While Len("" & objExcel.ActiveSheet.Cells(row, 1)) > 0
    IdProyectoAgencia =  objExcel.ActiveSheet.Cells(row, 1)
    ImporteProyecto = Replace(objExcel.ActiveSheet.Cells(row, 2),",",".")
    IdLineaImport = gcn.dameValorCampo("select isnull(max(IdLineaImportacion), 1) +1 from Pers_Log_Importacion_IngresoAgencia")
    
    'Insertar en base de datos los datos para comprobar la integridad de los datos
    lSql = "insert into Pers_Log_Importacion_IngresoAgencia(IdLineaImportacion, ClaveImportacion, IdIngresoAgencia, IdProyectoAgencia, Importe) values ("&IdLineaImport&",'"&claveImportacion&"',"&IdIngresoAgencia&",'"&IdProyectoAgencia&"','"&ImporteProyecto&"')"


    
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
  Cliente = gForm.Controls("ComboUsuario")(1).text
  params.Add claveImportacion
  params.Add Cliente
    
  If gcn.EjecutaStoreCol("pPers_Importar_Datos_ImportIngreso", params) Then
    gForm.Controls("GridAgenciaLineas").Refrescar 
    
    If gcn.dameValorCampo("select count(IdIngresoAgenciaLinea) from Pers_IngresoAgencia_Lineas where IdIngresoAgencia = "&gForm.Controls("TextoUsuario")(1).text&"") > 0 Then
      gForm.Botonera.Boton("btGenerarPed").Visible=True
    End If
    
    If MsgBox("Importacion terminada, quereis ver el importe de la importacion del Excel ?", vbYesNo, "Confirmacion") = vbYes Then
       AbrirFormImportacion(claveImportacion)
    End If
  End If
  
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
      .AgregaColumna "IdIngresoAgencia", 0, "Id Ingreso Agencia", False
      .AgregaColumna "IdProyectoAgencia", 1000, "Id proyecto",False
      .AgregaColumna "Importe", 1000, "Importe",False,,,"#,##0.00"
      .AgregaColumna "Texto_error", 2500, "Error",True
      
      .From = "Pers_Log_Importacion_IngresoAgencia" 
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

'Para Activar este evento hay que configurar la grid. Poner en el sub Initialize por ejemplo: gForm.grdLineas.ActivarScripts = True
Sub Grid_BeforeDelete(aGrid,aCancel)
  If aGrid.Name = "GridAgenciaLineas" Then
    TipoObj = "IngresoAgencia"
    IdIngreso = aGrid.GetValue("IdIngresoAgencia")
    IdLinea = aGrid.GetValue("IdIngresoAgenciaLinea")
    Return = ""
    
    Set params = gcn.DameNewCollection
    params.Add IdIngreso
    params.Add IdLinea
    params.Add TipoObj
    params.Add Return
    
    If Not gcn.EjecutaStoreCol("pPers_DespuesEliminar_IngresoLinea", params) Then 
      MsgBox "Fallo durante la actualizacion del importe total", vbError
      aCancel = True
    End If
        
    gform.Eobjeto.Refresh
    
  End If
End Sub


