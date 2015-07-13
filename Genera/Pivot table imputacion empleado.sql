--C

DECLARE @cols AS NVARCHAR(MAX),
    @query  AS NVARCHAR(MAX)
    
    select @cols = STUFF((SELECT ',' + QUOTENAME(IdProyecto) 
                    from Pers_Importa_Dedicacion_Empleado_Proyecto_Lineas
                    group by IdProyecto
                    order by IdProyecto
            FOR XML PATH(''), TYPE
            ).value('.', 'NVARCHAR(MAX)') 
        ,1,1,'')


IF EXISTS (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS
         WHERE TABLE_NAME = 'vPers_Imputaciones_Empleado')
   DROP VIEW vPers_Imputaciones_Empleado

set @query = N'Create view vPers_Imputaciones_Empleado as SELECT IdEmpleado, ' + @cols + N' from 
             (
                select IdEmpleado, IdProyecto, PorcentajeDedic
                from Pers_Importa_Dedicacion_Empleado_Proyecto_Lineas
            ) x
            pivot 
            (
                min(PorcentajeDedic)
                for IdProyecto in (' + @cols + N')
            ) p '

exec sp_executesql @query

set @query = 'zpermisos vPers_Imputaciones_Empleado'

exec sp_executesql @query

select * from vPers_Imputaciones_Empleado