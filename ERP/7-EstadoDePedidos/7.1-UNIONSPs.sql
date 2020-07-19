--Formato a seguir:
--SELECT Campo1, Campo2 FROM Tabla1
--UNION ALL SELECT Campo1, Campo2 FROM Tabla2
--UNION ALL SELECT Campo1, Campo2 FROM Tabla3;

SELECT * 
FROM 

--Query SP1 (Tabla1):
(
SELECT DISTINCT
	   PRHA.REQUISITION_NUMBER							AS SP
	   ,PRHA.ATTRIBUTE1 								AS TIPO_SP
	   ,PRHA.DOCUMENT_STATUS 							AS ESTADO_SP
	   
	   --4 columnas agregadas:
	   ,PRHA.ATTRIBUTE3 								AS INTEGRACION
	   ,EXTERNALLY_MANAGED_FLAG 						AS SP_EXTERNA
	   ,PRLA.ATTRIBUTE3 								AS MARCA_EXIGIDA
	   ,PRLA.NOTE_TO_SUPPLIER 							AS DATOS_AFILIADO
	   
	   ,(SELECT FULL_NAME
           FROM PER_PERSON_NAMES_F
          WHERE 1=1
		        AND PERSON_ID = PRHA.PREPARER_ID 
			    AND NAME_TYPE = 'GLOBAL') 				AS SOLICITANTE
	   ,TO_CHAR(PRHA.CREATION_DATE,'dd/mm/yyyy') 		AS SP_FECHA_C
	   --,TO_CHAR(PRHA.APPROVED_DATE,'dd/mm/yyyy') 		AS SP_FECHA_A
	   ,PRLA.LINE_NUMBER 								AS LINEA_SP
	   ,ESI.ITEM_NUMBER 								AS ARTICULO
	   ,PRLA.ITEM_DESCRIPTION							AS DESCRIPCION
	   ,PRLA.QUANTITY									AS CANTIDAD
	   ,PRLA.UOM_CODE									AS UOM
	   ,PHA.SEGMENT1 									AS OC
	   ,HOU.NAME 										AS UG
	   ,PHA.DOCUMENT_STATUS								AS ESTADO_OC
	   ,'PROCESADA MANUALMENTE'							AS PROCESAMIENTO
	   ,(SELECT FULL_NAME 
           FROM PER_PERSON_NAMES_F
          WHERE PERSON_ID = PHA.AGENT_ID 
            AND NAME_TYPE = 'GLOBAL') 					AS COMPRADOR
	   ,TO_CHAR(PHA.CREATION_DATE,'dd/mm/yyyy')			AS OC_FECHA_C
	   ,TO_CHAR(PHA.APPROVED_DATE,'dd/mm/yyyy')			AS OC_FECHA_A
	   ,PS.VENDOR_NAME 									AS PROVEEDOR
	   ,PLA.LINE_NUM 									AS LINEA_OC
	   ,PLA.LINE_STATUS									AS ESTADO_LINEA_OC
	   --,ROUND(PLA.QUANTITY*PLA.UNIT_PRICE,2)			AS MONTO_LINEA_OC
	   ,(SELECT SEGMENT1
		   FROM PO_HEADERS_ALL
		  WHERE PO_HEADER_ID = PLA.FROM_HEADER_ID)		AS ACUERDO 
	   ,PRHA.CREATION_DATE								AS ORDERDATE

FROM POR_REQUISITION_HEADERS_ALL 	PRHA
	 ,POR_REQUISITION_LINES_ALL 	PRLA
	 ,PO_HEADERS_ALL 				PHA
	 ,PO_LINES_ALL 					PLA
	 ,HR_ORGANIZATION_UNITS_F_TL 	HOU
	 ,POZ_SUPPLIERS_V 				PS
	 ,EGP_SYSTEM_ITEMS_B 			ESI
	 ,INV_UNITS_OF_MEASURE 			IUM

WHERE 1=1
  AND PHA.PO_HEADER_ID			 = PLA.PO_HEADER_ID
  AND PRHA.REQ_BU_ID 			 = HOU.ORGANIZATION_ID
  AND PHA.VENDOR_ID 			 = PS.VENDOR_ID
  AND PRLA.ITEM_ID          	 = ESI.INVENTORY_ITEM_ID
  AND PRHA.REQUISITION_HEADER_ID = PRLA.REQUISITION_HEADER_ID
  AND PRLA.PO_LINE_ID 			 = PLA.PO_LINE_ID
  AND PLA.UOM_CODE				 = IUM.UOM_CODE
  AND HOU.LANGUAGE 				 = 'E'
  AND PRHA.ATTRIBUTE3			 = 'Medicamentos de Alto Costo'
  --AND PHA.DOCUMENT_STATUS = 'OPEN'
 
  --Parametros:
	AND PRHA.REQUISITION_NUMBER    	= NVL(:SP, PRHA.REQUISITION_NUMBER )
	AND PHA.SEGMENT1  			   	= NVL(:OC, PHA.SEGMENT1 )
	AND TRUNC(PRHA.CREATION_DATE)  	= NVL(:P_FECHA_C, TRUNC(PRHA.CREATION_DATE) )
	
	AND 'PROCESADA MANUALMENTE'		= NVL(:PROCESAMIENTO,'PROCESADA MANUALMENTE')  
	AND HOU.NAME					= NVL(:UG,HOU.NAME )
	AND PHA.AGENT_ID 				= NVL(:COMPRADOR, PHA.AGENT_ID)
	AND PS.VENDOR_NAME 				= NVL(:PROVEEDOR,PS.VENDOR_NAME  )
	AND (SELECT SEGMENT1  FROM PO_HEADERS_ALL WHERE PO_HEADER_ID = PLA.FROM_HEADER_ID) 
									= NVL(:ACUERDO, 	(SELECT SEGMENT1  FROM PO_HEADERS_ALL WHERE PO_HEADER_ID = PLA.FROM_HEADER_ID) )
		  
)

UNION ALL SELECT * 

FROM 
--Query SP2 (Tabla2):
(
SELECT DISTINCT
		
	   PRHA.REQUISITION_NUMBER							AS SP
	   ,PRHA.ATTRIBUTE1 								AS TIPO_SP
	   ,PRHA.DOCUMENT_STATUS 							AS ESTADO_SP
	   
	   	--4 columnas agregadas:
	   ,PRHA.ATTRIBUTE3 								AS INTEGRACION
	   ,EXTERNALLY_MANAGED_FLAG 						AS SP_EXTERNA
	   ,PRLA.ATTRIBUTE3 								AS MARCA_EXIGIDA
	   ,PRLA.NOTE_TO_SUPPLIER 							AS DATOS_AFILIADO
	   
	   ,(SELECT FULL_NAME
           FROM PER_PERSON_NAMES_F
          WHERE 1=1
		        AND PERSON_ID = PRHA.PREPARER_ID 
			    AND NAME_TYPE = 'GLOBAL') 				AS SOLICITANTE
	   ,TO_CHAR(PRHA.CREATION_DATE,'dd/mm/yyyy') 		AS SP_FECHA_C
	   --,TO_CHAR(PRHA.APPROVED_DATE,'dd/mm/yyyy') 		AS SP_FECHA_A
	   ,PRLA.LINE_NUMBER 								AS LINEA_SP
	   ,ESI.ITEM_NUMBER 								AS ARTICULO
	   ,PRLA.ITEM_DESCRIPTION							AS DESCRIPCION
	   ,PRLA.QUANTITY									AS CANTIDAD
	   ,PRLA.UOM_CODE									AS UOM
	   
	   --Agregamos los CAMPOS NULL:
		,to_number(null)								AS OC  --to_number(null) ya que el campo OC es numerico.
		--,PHA.SEGMENT1 								AS OC
		,HOU.NAME 										AS UG
		,null 											AS ESTADO_OC
	   --,PHA.DOCUMENT_STATUS							AS ESTADO_OC
		,'SIN PROCESAR'									AS PROCESAMIENTO
		,null 											AS COMPRADOR
		,null 											AS OC_FECHA_C
		,null 											AS OC_FECHA_A
		,null 											AS PROVEEDOR
		,null 											AS LINEA_OC
		,null 											AS ESTADO_LINEA_OC
		,null 											AS ACUERDO
		
	   --,(SELECT FULL_NAME 
          -- FROM PER_PERSON_NAMES_F
          --WHERE PERSON_ID = PHA.AGENT_ID 
            --AND NAME_TYPE = 'GLOBAL') 				AS COMPRADOR
	   --,TO_CHAR(PHA.CREATION_DATE,'dd/mm/yyyy')		AS OC_FECHA_C
	   --,TO_CHAR(PHA.APPROVED_DATE,'dd/mm/yyyy')		AS OC_FECHA_A
	   --,PS.VENDOR_NAME 								AS PROVEEDOR
	   --,PLA.LINE_NUM 									AS LINEA_OC
	   --,PLA.LINE_STATUS								AS ESTADO_LINEA_OC
	   --,ROUND(PLA.QUANTITY*PLA.UNIT_PRICE,2)			AS MONTO_LINEA_OC
	   --,(SELECT SEGMENT1
		   --FROM PO_HEADERS_ALL
		  --WHERE PO_HEADER_ID = PLA.FROM_HEADER_ID)	AS ACUERDO
		  
	   ,PRHA.CREATION_DATE								AS ORDERDATE

FROM POR_REQUISITION_HEADERS_ALL 	PRHA
	 ,POR_REQUISITION_LINES_ALL 	PRLA
	 --,PO_HEADERS_ALL 				PHA
	 --,PO_LINES_ALL 				PLA
	 ,HR_ORGANIZATION_UNITS_F_TL 	HOU
	 --,POZ_SUPPLIERS_V 			PS
	 ,EGP_SYSTEM_ITEMS_B 			ESI
	 ,INV_UNITS_OF_MEASURE 			IUM

WHERE 1=1
  --AND PHA.PO_HEADER_ID		 = PLA.PO_HEADER_ID
  AND PRHA.REQ_BU_ID 			 = HOU.ORGANIZATION_ID
  --AND PHA.VENDOR_ID 			 = PS.VENDOR_ID
  AND PRLA.ITEM_ID          	 = ESI.INVENTORY_ITEM_ID
  AND PRHA.REQUISITION_HEADER_ID = PRLA.REQUISITION_HEADER_ID
  --AND PRLA.PO_LINE_ID 		 = PLA.PO_LINE_ID (+)
  --AND PLA.UOM_CODE			 = IUM.UOM_CODE
  AND HOU.LANGUAGE 			     = 'E'
  AND PRHA.ATTRIBUTE3			 = 'Medicamentos de Alto Costo'
  AND PRLA.PO_HEADER_ID IS NULL
  AND PRHA.DOCUMENT_STATUS 		!= 'CANCELED'
  --AND PHA.DOCUMENT_STATUS 	 = 'OPEN'
  
  --Parametros:
	AND PRHA.REQUISITION_NUMBER   	= NVL(:SP, PRHA.REQUISITION_NUMBER )
	AND TRUNC(PRHA.CREATION_DATE)  	= NVL(:P_FECHA_C, TRUNC(PRHA.CREATION_DATE))
	AND 'SIN PROCESAR'				= NVL(:PROCESAMIENTO,'SIN PROCESAR')   
	AND HOU.NAME					= NVL(:UG,HOU.NAME )

)

UNION ALL SELECT * 

FROM 
--Query SP3 (Tabla3):
(
SELECT DISTINCT
	   PRHA.REQUISITION_NUMBER							AS SP
	   ,PRHA.ATTRIBUTE1 								AS TIPO_SP
	   ,PRHA.DOCUMENT_STATUS 							AS ESTADO_SP
	   
	   	--4 columnas agregadas:
	   ,PRHA.ATTRIBUTE3 								AS INTEGRACION
	   ,EXTERNALLY_MANAGED_FLAG 						AS SP_EXTERNA
	   ,PRLA.ATTRIBUTE3 								AS MARCA_EXIGIDA
	   ,PRLA.NOTE_TO_SUPPLIER 							AS DATOS_AFILIADO
	   
	   ,(SELECT FULL_NAME
           FROM PER_PERSON_NAMES_F
          WHERE 1=1
		        AND PERSON_ID = PRHA.PREPARER_ID 
			    AND NAME_TYPE = 'GLOBAL') 				AS SOLICITANTE
	   ,TO_CHAR(PRHA.CREATION_DATE,'dd/mm/yyyy') 		AS SP_FECHA_C
	   --,TO_CHAR(PRHA.APPROVED_DATE,'dd/mm/yyyy') 		AS SP_FECHA_A
	   ,PRLA.LINE_NUMBER 								AS LINEA_SP
	   ,ESI.ITEM_NUMBER 								AS ARTICULO
	   ,PRLA.ITEM_DESCRIPTION							AS DESCRIPCION
	   ,PRLA.QUANTITY									AS CANTIDAD
	   ,PRLA.UOM_CODE									AS UOM
	   ,PHA.SEGMENT1 									AS OC
	   ,HOU.NAME 										AS UG
	   ,PHA.DOCUMENT_STATUS								AS ESTADO_OC
	   ,'PROCESADO POR DESARROLLO'						AS PROCESAMIENTO
	   ,(SELECT FULL_NAME 
           FROM PER_PERSON_NAMES_F
          WHERE PERSON_ID = PHA.AGENT_ID 
            AND NAME_TYPE = 'GLOBAL') 					AS COMPRADOR
	   ,TO_CHAR(PHA.CREATION_DATE,'dd/mm/yyyy')			AS OC_FECHA_C
	   ,TO_CHAR(PHA.APPROVED_DATE,'dd/mm/yyyy')			AS OC_FECHA_A
	   ,PS.VENDOR_NAME 									AS PROVEEDOR
	   ,PLA.LINE_NUM 									AS LINEA_OC
	   ,PLA.LINE_STATUS									AS ESTADO_LINEA_OC
	   --,ROUND(PLA.QUANTITY*PLA.UNIT_PRICE,2)			AS MONTO_LINEA_OC
	   ,(SELECT SEGMENT1
		   FROM PO_HEADERS_ALL
		  WHERE PO_HEADER_ID = PLA.FROM_HEADER_ID)		AS ACUERDO 
	   ,PRHA.CREATION_DATE								AS ORDERDATE

FROM POR_REQUISITION_HEADERS_ALL 	PRHA
	 ,POR_REQUISITION_LINES_ALL 	PRLA
	 ,PO_HEADERS_ALL 				PHA
	 ,PO_LINES_ALL 					PLA
	 ,HR_ORGANIZATION_UNITS_F_TL 	HOU
	 ,POZ_SUPPLIERS_V 				PS
	 ,EGP_SYSTEM_ITEMS_B 			ESI
	 ,INV_UNITS_OF_MEASURE 			IUM

WHERE 1=1
  AND PHA.PO_HEADER_ID			 = PLA.PO_HEADER_ID
  AND PRHA.REQ_BU_ID 			 = HOU.ORGANIZATION_ID
  AND PHA.VENDOR_ID 			 = PS.VENDOR_ID
  AND PRLA.ITEM_ID          	 = ESI.INVENTORY_ITEM_ID
  AND PRHA.REQUISITION_HEADER_ID = PRLA.REQUISITION_HEADER_ID
  AND PRHA.REQUISITION_NUMBER	 = PHA.ATTRIBUTE3
  AND PLA.UOM_CODE				 = IUM.UOM_CODE
  AND HOU.LANGUAGE				 = 'E'
  AND PRHA.ATTRIBUTE3			 = 'Medicamentos de Alto Costo'
  AND PRHA.DOCUMENT_STATUS 		 = 'CANCELED'
  AND PRLA.LINE_NUMBER			 = PLA.LINE_NUM
  --AND PHA.DOCUMENT_STATUS = 'OPEN'
 
   --Parametros:
	AND PRHA.REQUISITION_NUMBER   		= NVL(:SP, PRHA.REQUISITION_NUMBER )
	AND PHA.SEGMENT1  					= NVL(:OC, PHA.SEGMENT1 )
	AND TRUNC(PRHA.CREATION_DATE) 		= NVL(:P_FECHA_C, TRUNC(PRHA.CREATION_DATE))
	AND 'PROCESADO POR DESARROLLO'		= NVL(:PROCESAMIENTO,'PROCESADO POR DESARROLLO')  
	AND HOU.NAME						= NVL(:UG,HOU.NAME )
	AND PHA.AGENT_ID 					= NVL(:COMPRADOR, PHA.AGENT_ID)
	AND PS.VENDOR_NAME 					= NVL(:PROVEEDOR,PS.VENDOR_NAME )
	AND (SELECT SEGMENT1  FROM PO_HEADERS_ALL WHERE PO_HEADER_ID = PLA.FROM_HEADER_ID) 
										= NVL(:ACUERDO, 	(SELECT SEGMENT1  FROM PO_HEADERS_ALL WHERE PO_HEADER_ID = PLA.FROM_HEADER_ID) )

 )
 
   --Lo ordenamos por PRHA.CREATION_DATE (campo ORDERDATE - 26) DESC, PRLA.LINE_NUMBER (campo LINEA_SP - 10) ASC.":
 ORDER BY 26 DESC, 10 ASC
 
 --El 23 es el número del ORDERDATE, el cual usa PRHA.CREATION_DATE.
 --El 6 es el campo LINEA_SP, que usa PRLA.LINE_NUMBER.
 
  --Le saque a las 3 SPs al final este order by: ORDER BY ORDERDATE DESC,LINEA_SP ASC.
  --Y se lo puse a lo último de los 3 union entonces, hice lo mismo que hicieron.
  
 -----------------------------------------------------------------------------------------------------------------------------------------------------------
 
 --Parametros:
 
 --NVL EN TODOS?: SI (menos en PROCESAMIENTO).
 
--Para los campos NULL de SP2, directamente NO ponemos nada en el where. Osea estos: ACUERDO, PROVEEDOR, COMPRADOR, OC. 
 
 --Los parametros hay que ponerlos en los 3 select de arriba (en el WHERE de SP1 y SP3):
 
								 --PRHA.REQUISITION_NUMBER   = NVL(:SP, PRHA.REQUISITION_NUMBER )

								-- PHA.SEGMENT1  = NVL(:OC, PHA.SEGMENT1 )

								-- TO_CHAR(PRHA.CREATION_DATE,'dd/mm/yyyy')  = NVL(:SP_FECHA_C, TO_CHAR(PRHA.CREATION_DATE,'dd/mm/yyyy')  )

								--    ALGO= :PROCESAMIENTO  --Aca no usamos NVL.
									--ALGO:
										--'PROCESADA MANUALMENTE' para SP1.
										--'SIN PROCESAR' para SP2.
										--'PROCESADO POR DESARROLLO' para SP3.

								--    HOU.NAME= NVL(:UG,HOU.NAME )

								--    (SELECT FULL_NAME  FROM PER_PERSON_NAMES_F
								--  WHERE PERSON_ID = PHA.AGENT_ID 
								 --           AND NAME_TYPE = 'GLOBAL') 	= NVL(:COMPRADOR, (SELECT FULL_NAME  FROM PER_PERSON_NAMES_F WHERE PERSON_ID = PHA.AGENT_ID AND NAME_TYPE = 'GLOBAL') )

								--   	PS.VENDOR_NAME = NVL(:PROVEEDOR,PS.VENDOR_NAME  )

								--    	(SELECT SEGMENT1
								--		   FROM PO_HEADERS_ALL
								--		  WHERE PO_HEADER_ID = PLA.FROM_HEADER_ID)=NVL(:ACUERDO, (SELECT SEGMENT1 FROM PO_HEADERS_ALL WHERE PO_HEADER_ID = PLA.FROM_HEADER_ID) )

-------------
 --Para el Where del SP2 (campos nulls): ACUERDO, PROVEEDOR, COMPRADOR, OC.:
 
								--		PRHA.REQUISITION_NUMBER   = NVL(:SP, PRHA.REQUISITION_NUMBER )
								-- 	TO_CHAR(PRHA.CREATION_DATE,'dd/mm/yyyy')  = NVL(:SP_FECHA_C, TO_CHAR(PRHA.CREATION_DATE,'dd/mm/yyyy')  )
								--    'SIN PROCESAR'= :PROCESAMIENTO  --Aca no usamos NVL.
								--    HOU.NAME= NVL(:UG,HOU.NAME )


 --Y las querys para las listas de valores para los parámetros que pusimos en Cloud son...:
 	/*
	--Parametros del DM (las querys que puse):
	
	--Lista UGs:
	 select  HR_ORGANIZATION_UNITS_F_TL.NAME
	from HR_ORGANIZATION_UNITS_F_TL

	--Lista OCs:
	select  PO_HEADERS_ALL.SEGMENT1
	from PO_HEADERS_ALL

	--Lista Procesamientos:
	--Valores fijos:
	PROCESADA MANUALMENTE
	SIN PROCESAR
	PROCESADO POR DESARROLLO

	--Lista SPs:
	select POR_REQUISITION_HEADERS_ALL. REQUISITION_NUMBER
	from POR_REQUISITION_HEADERS_ALL

	--Lista acuerdos:
	select SEGMENT1, PO_HEADER_ID
	from PO_HEADERS_ALL
	
	--Lista proveedores:
	 select POZ_SUPPLIERS_V.VENDOR_NAME
	 from POZ_SUPPLIERS_V

	--Lista compradores:
	select FULL_NAME, PERSON_ID
	FROM PER_PERSON_NAMES_F 
	WHERE NAME_TYPE = 'GLOBAL'
*/

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
 
 --Para probar el union de SP1 y SP3...:
 --WHERE ARTICULO=01010468028557   (ver para que ande bien).
 
 --Campos que tienen SP1 y SP3 pero NO SP2:
 --1-ACUERDO
 --2-ESTADO_LINEA_OC
 --3-LINEA_OC
 --4-PROVEEDOR
 --5-OC_FECHA_A
 --6-OC_FECHA_C
 --7-COMPRADOR
 --8-ESTADO_OC
 --9-OC
 
 --Para esto en SP2 ponemos dichos campos como NULL. 
 
 --IMPORTANTE: LOS CAMPOS QUE PUSE NULL EN SP2 TIENEN QUE ESTAR EN LA MISMA POSICION QUE ESTAN EN SP1 Y SP3, SINO EL UNION NO ANDA, YA QUE 
 --COMPARA CAMPO POR CAMPO.  Por ej. 1ro SP, 2do TIPO_SP, 3ro ESTADO_SP y así.... y yo había puesto todos los campos null del SP2 al principio... y NO. 
 
 
 --Parametro....  --HOU.NAME AGREGAR LO DE LENGUAJE quizassssssss.