// Programa   : DPUNDMEDDELPRECIO
// Fecha/Hora : 05/01/2024 05:48:28
// Propósito  : Remover Unidades de Medidas y Precios
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cUndMed)
   LOCAL cSql,oDb:=OpenOdbc(oDp:cDsnData)
   LOCAL cPrecio:="DPPRECIOS_"+LSTR(SECONDS(),8,0)
   LOCAL cInvMed:="DPINVMED_"   +LSTR(SECONDS(),8,0)

   DEFAULT cUndMed:=SQLGET("DPUNDMED","UND_CODIGO")

   IF !MsgNoYes("Desea Remover Precios y Unidades de Medida ["+cUndMed+"]")
      RETURN NIL
   ENDIF

   /*
   // Primero los Precios
   */
   cSql:=" CREATE TABLE "+cPrecio+" SELECT * FROM DPPRECIOS "+;
         " WHERE PRE_UNDMED"+GetWhere("=",cUndMed)

   oDb:EXECUTE(cSql)

   SQLDELETE("DPPRECIOS","PRE_UNDMED"+GetWhere("=",cUndMed))

   /*
   // Unidades de Medida
   */
   cSql:=" CREATE TABLE "+cInvMed+" SELECT * FROM DPINVMED "+;
         " WHERE IME_UNDMED"+GetWhere("=",cUndMed)

   oDb:EXECUTE(cSql)

   SQLDELETE("DPINVMED","IME_UNDMED"+GetWhere("=",cUndMed))

   MsgMemo("Proceso Ejecutado")

RETURN .T.
// EOF
