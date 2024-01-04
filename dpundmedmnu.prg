// Programa   : DPUNDMEDMNU
// Fecha/Hora : 06/05/2016 10:28:35
// Prop¢sito  : Menu de DPUNDMED	
// Creado Por : DPXBASE
// Llamado por: DPUNDMED.LBX
// Aplicaci¢n : Menú de consulta DPUNDMED
// Tabla      : DPUNDMED

#INCLUDE "DPXBASE.CH"
#include "outlook.ch"
#include "splitter.Ch"

PROCE MAIN(cCodigo,cNombre,oFrm)
   LOCAL oFont,oOut,oBar,oBtn,oBar,nGroup,cTitle,nNumMain:=0,nNumMemo:=0
   LOCAL lField_Dig:=.F.
   LOCAL lField_Mem:=.F.

   DEFAULT cCodigo:=SQLGET("DPUNDMED","UND_CODIGO") 

   DEFAULT cNombre:=SQLGET("DPUNDMED","UND_DESCRI")

   IF Empty(cNombre) .AND. ISFIELD("DPUNDMED","UND_DESCRI")
      // Busca Nombre de Descripcion o Nombre
      cNombre:=SQLGET("DPUNDMED","UND_DESCRI","UND_CODIGO          "+GetWhere("=",cCodigo))
   ENDIF

   DEFINE FONT oFont    NAME "Tahoma" SIZE 0,-14 
   DEFINE FONT oFontBrw NAME "Tahoma" SIZE 0,-10 BOLD

   cTitle:="Menú de Funciones "+GetFromVar("{oDp:DPUNDMED}")

   DpMdi(cTitle,"oUNDMEDMNU","")

   oUNDMEDMNU:cCodigo   :=cCodigo
   oUNDMEDMNU:cNombre   :=cNombre
   oUNDMEDMNU:lSalir    :=.F.
   oUNDMEDMNU:nHeightD  :=45
   oUNDMEDMNU:cTitle    :=cTitle
   oUNDMEDMNU:lMsgBar   :=.F.
   oUNDMEDMNU:oFrm      :=oFrm
   oUNDMEDMNU:nNumMemo  :=nNumMemo

   SetScript("DPUNDMEDCON")

   oUNDMEDMNU:Windows(0,0,540,410)


   @ 48, -1 OUTLOOK oUNDMEDMNU:oOut ;
     SIZE 150+250, oUNDMEDMNU:oWnd:nHeight()-90 ;
     PIXEL ;
     FONT oFont ;
     OF oUNDMEDMNU:oWnd;
     COLOR CLR_BLACK,oDp:nGris2


   DEFINE GROUP OF OUTLOOK oUNDMEDMNU:oOut PROMPT "&Opciones"

   DEFINE BITMAP OF OUTLOOK oUNDMEDMNU:oOut ;
          BITMAP "BITMAPS\XDELETE.BMP" ;
          PROMPT "Eliminar Medidas y Precios" ;
          ACTION  (oUNDMEDMNU:REGAUDITORIA("Eliminar Precios"),;
                   EJECUTAR("DPUNDMEDDELPRECIO",oUNDMEDMNU:cCodigo))

   DEFINE BITMAP OF OUTLOOK oUNDMEDMNU:oOut ;
          BITMAP "BITMAPS\PROGRAMA.BMP" ;
          PROMPT "Programa fuente" ;
          ACTION  (oUNDMEDMNU:REGAUDITORIA("Programa Fuente"),;
                   oUNDMEDMNU:MEDDPXBASE())


   DEFINE BITMAP OF OUTLOOK oUNDMEDMNU:oOut ;
          BITMAP "BITMAPS\XSALIR.BMP";
          PROMPT "Salir";
          ACTION oUNDMEDMNU:CLOSE()


   DEFINE DIALOG oUNDMEDMNU:oDlg FROM 0,oUNDMEDMNU:oOut:nWidth() TO oUNDMEDMNU:nHeightD,700;
          TITLE "" STYLE WS_CHILD OF oUNDMEDMNU:oWnd;
          PIXEL COLOR NIL,oDp:nGris

   @ .1,.2 GROUP oUNDMEDMNU:oGrp TO 10,10 PROMPT "Código ["+oUNDMEDMNU:cCodigo+"]" FONT oFont

   @ .5,.5 SAY oUNDMEDMNU:cNombre SIZE 190,10;
           COLOR CLR_WHITE,12615680;
           FONT oFont

   ACTIVATE DIALOG oUNDMEDMNU:oDlg NOWAIT VALID .F.

   oUNDMEDMNU:Activate("oUNDMEDMNU:FRMINIT()")

 
RETURN

FUNCTION FRMINIT()

   oUNDMEDMNU:oWnd:bResized:={||oUNDMEDMNU:oDlg:Move(0,0,oUNDMEDMNU:oWnd:nWidth(),50,.T.),;
                             oUNDMEDMNU:oGrp:Move(0,0,oUNDMEDMNU:oWnd:nWidth()-15,oUNDMEDMNU:nHeightD,.T.)}


   EVal(oUNDMEDMNU:oWnd:bResized)

RETURN .T.

FUNCTION MNUDIGITALIZAR()

   LOCAL nNumMain:=SQLGET("DPUNDMED","                    ","UND_CODIGO          "+GetWhere("=",oUNDMEDMNU:cCodigo))

   oUNDMEDMNU:REGAUDITORIA("Consultar Registro de Digitalización "+LSTR(nNumMain))

   nNumMain:=EJECUTAR("DPFILEEMPMAIN",nNumMain,NIL,NIL,.T.,.T.)

   SQLUPDATE("DPUNDMED","                    ",nNumMain,"UND_CODIGO          "+GetWhere("=",oUNDMEDMNU:cCodigo))

RETURN .F.

FUNCTION REGMEMOS()
   LOCAL cTitle,cWhere

   oUNDMEDMNU:REGAUDITORIA("Consultar Registro Memo "+LSTR(oUNDMEDMNU:nNumMemo))

   EJECUTAR("DPMEMOMDIEDIT","DPUNDMED","UND_CODIGO          ","                    ",oUNDMEDMNU:cCodigo,cTitle,cWhere,.T.)

RETURN .F.

FUNCTION REGAUDITORIA(cConsulta)
RETURN EJECUTAR("AUDITORIA","DCON",.F.,"DPUNDMED",oUNDMEDMNU:cCodigo,NIL,NIL,NIL,NIL,cConsulta)

FUNCTION MEDDPXBASE()
   LOCAL bRun,cWhere,cCodigo:="",cPrg:="",cMemo:=""

   HrbLoad("DPXBASE.HRB") // Carga M?dulo DpXbase

   cPrg  :=[/]+[*]+CRLF+;
           [ Calcular Volumen para la Unidad de Medida ]+CRLF+;
           [*]+[/]+CRLF+;
           [#INCLUDE "DPXBASE.CH" ]+CRLF+;
           []+CRLF+;
           [PROCE MAIN(oGrid) ]+CRLF+;
           [  LOCAL X:=oGrid:MOV_X,Y:=oGrid:MOV_Y,Z:=oGrid:MOV_Z,W:=oGrid:MOV_W ]+CRLF+;
           [  LOCAL R:=0   ]+CRLF+;
           [  R    :=X*Y*Z ]+CRLF+;
           [  oGrid:SET("MOV_CANTID",R,.T.) ]+CRLF+;
           [RETURN .T. ]

   bRun  :={||MensajeErr("FINAL")}
   cWhere:="UND_CODIGO"+GetWhere("=",oUNDMEDMNU:cCodigo)
   cMemo :=SQLGET("DPUNDMED","UND_PRG",cWhere)
   cMemo :=IF(Empty(cMemo),cPrg,ALLTRIM(cMemo))

   DPXBASEEDIT(3,cCodigo,bRun,NIL,cMemo,"DPUNDMED","UND_PRG",cWhere)

RETURN .T.
// EOF

