// Programa   : VTAGRIDSETUNDMED
// Fecha/Hora : 31/05/2022 05:46:38
// Propósito  : Asignar los Valores de Unidad de Medida en el Grid, Facilitando la Edición del campo Peso
// Creado Por :
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oGrid)
   LOCAL cForma,nCxUnd,oInvMed,cWhere

   IF oGrid=NIL
      RETURN NIL
   ENDIF

//   oGrid:lPesado:=SQLGET("DPUNDMED","UND_VARIA","UND_CODIGO"+GetWhere("=",oGrid:MOV_UNDMED))
//   oGrid:lPesado:=IF(ValType(oGrid:lPesado)<>"L",.F.,oGrid:lPesado)
// ? oGrid:MOV_UNDMED,"oGrid:MOV_UNDMED"

   oInvMed:=OpenTable("SELECT * FROM DPUNDMED WHERE UND_CODIGO"+GetWhere("=",oGrid:MOV_UNDMED),.T.)

// oInvMed:Browse()

   AEVAL(oInvMed:aFields,{|a,n| oGrid:Set(a[1],oInvMed:FieldGet(n))}) // 02/01/2024

   // oInvMed:Browse()
/*
   cForma:=SQLGET("DPUNDMED","UND_FORMA,UND_CANUND,UND_VARIA,UND_VALPES,UND_MARGEN,UND_PESO","UND_CODIGO"+GetWhere("=",oGrid:MOV_UNDMED))
   nCxUnd  :=DPSQLROW(2,0)

   oGrid:lUnd_Peso  :=DPSQLROW(3,.F.)   // Valor por Peso
   oGrid:lPesado    :=DPSQLROW(4,.F.)   // Prducto Pesado
   oGrid:nUnd_Margen:=DPSQLROW(5,0  )   // Margen de Tolerancia entre peso y Cantidad
   oGrid:nPeso      :=DPSQLROW(6,0  )   // Peso para Multiplicar los Bultos 30/01/2022
*/
   // 02/01/2024
   cForma           :=oInvMed:UND_FORMA  
   nCxUnd           :=oInvMed:UND_CANUND
   oGrid:lUnd_Peso  :=oInvMed:UND_VARIA  // DPSQLROW(3,.F.)   // Valor por Peso
   oGrid:lPesado    :=oInvMed:UND_VALPES // DPSQLROW(4,.F.)   // Prducto Pesado
   oGrid:nUnd_Margen:=oInvMed:UND_MARGEN // DPSQLROW(5,0  )   // Margen de Tolerancia entre peso y Cantidad
   oGrid:nPeso      :=oInvMed:UND_PESO   // DPSQLROW(6,0  )   // Peso para Multiplicar los Bultos 30/01/2022

   oInvMed:End()

   oGrid:lPesado:=IF(ValType(oGrid:lPesado)<>"L",.F.,oGrid:lPesado)

   IF oGrid:lUnd_Peso 
      oGrid:lReqPeso:=.T.
   ENDIF

   // Unidad de Medida personalizada por el Producto
   cWhere:=""
   IF oGrid:oHead:lVenta
     cWhere:=" AND IME_VENTA"+GetWhere("=","S")
   ENDIF

   oInvMed:=OpenTable("SELECT * FROM DPINVMED WHERE IME_CODIGO"+GetWhere("=",oGrid:MOV_CODIGO)+" AND IME_UNDMED"+GetWhere("=",oGrid:MOV_UNDMED)+cWhere)

   // 02/01/2024 Pasamos todos los campos para no tener necesidad de releerlo.
   AEVAL(oInvMed:aFields,{|a,n| oGrid:Set(a[1],oInvMed:FieldGet(n))})

   IF oInvMed:IME_CANTID>0
      nCxUnd:=oInvMed:IME_CANTID
   ENDIF

   // Peso debe ser Utilizado para Multiplicar 10 sacos de 40 kilos cada uno= 400 kilos. 40
   IF oInvMed:IME_PESO>0
      // oGrid:nPeso:=oInvMed:IME_PESO
      nCxUnd:=oInvMed:IME_PESO
   ENDIF

   oInvMed:End()

   oGrid:nCxUnd:=nCxUnd
   oGrid:Set("MOV_CXUND",nCxUnd            ,.T.)

RETURN .T.
// EOF
