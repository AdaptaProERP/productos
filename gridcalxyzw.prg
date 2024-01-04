// Programa   : GRIDCALXYZW
// Fecha/Hora : 04/01/2024 12:40:43
// Propósito  : Calcular Fórmula de Medidas
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oGrid)
   LOCAL X,Y,Z,W,cFormula,R:=0

   IF !ValType(oGrid)="O"
      RETURN .T.
   ENDIF

   IF !Empty(oGrid:UND_PRG)
     EJECUTAR("ISRUNMEMO",oGrid:UND_PRG,oGrid)
     RETURN .T.
   ENDIF

   cFormula:=oGrid:UND_FORMUL

   IF Empty(cFormula) .AND. "*"$oGrid:UND_FORMA
      cFormula:=oGrid:UND_FORMA
   ENDIF
 
   X:=oGrid:MOV_X
   Y:=oGrid:MOV_Y
   Z:=oGrid:MOV_Z
   W:=oGrid:MOV_W
   R:=MACROEJE(cFormula)

   IF ValType(R)="N"
     oGrid:SET("MOV_CANTID",R,.T.)
   ENDIF

RETURN .T.
// EOF
