// Programa   : DPUNDMEDCON
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

   cTitle:="Menú de Consulta "+GetFromVar("{oDp:DPUNDMED}")

   DpMdi(cTitle,"oUNDMEDCON","")

   oUNDMEDCON:cCodigo   :=cCodigo
   oUNDMEDCON:cNombre   :=cNombre
   oUNDMEDCON:lSalir    :=.F.
   oUNDMEDCON:nHeightD  :=45
   oUNDMEDCON:cTitle    :=cTitle
   oUNDMEDCON:lMsgBar   :=.F.
   oUNDMEDCON:oFrm      :=oFrm
   oUNDMEDCON:nNumMemo  :=nNumMemo

   SetScript("DPUNDMEDCON")

   oUNDMEDCON:Windows(0,0,540,410)


   @ 48, -1 OUTLOOK oUNDMEDCON:oOut ;
     SIZE 150+250, oUNDMEDCON:oWnd:nHeight()-90 ;
     PIXEL ;
     FONT oFont ;
     OF oUNDMEDCON:oWnd;
     COLOR CLR_BLACK,oDp:nGris2


   DEFINE GROUP OF OUTLOOK oUNDMEDCON:oOut PROMPT "&Opciones"

   DEFINE BITMAP OF OUTLOOK oUNDMEDCON:oOut ;
          BITMAP "BITMAPS\VIEW.BMP" ;
          PROMPT "Consultar Registro" ;
          ACTION  (oUNDMEDCON:REGAUDITORIA("Consultar Registro"),;
                   EJECUTAR("DPUNDMED",0,oUNDMEDCON:cCodigo))

  DEFINE BITMAP OF OUTLOOK oUNDMEDCON:oOut ;
          BITMAP "BITMAPS\PRODUCTO.BMP" ;
          PROMPT "Consultar Productos" ;
          ACTION  (oUNDMEDCON:REGAUDITORIA("Consultar Registro"),;
                   EJECUTAR("BRINVUNDMED","IME_UNDMED"+GetWhere("=",oUNDMEDCON:cCodigo),NIL,NIL,NIL,NIL,"Unidad de Medida: "+oCursor:UND_CODIGO+" "+oCursor:UND_DESCRI,oUNDMEDCON:cCodigo))


  DEFINE BITMAP OF OUTLOOK oUNDMEDCON:oOut ;
          BITMAP "BITMAPS\PRECIOS.BMP" ;
          PROMPT "Consultar Precios" ;
          ACTION  (oUNDMEDCON:REGAUDITORIA("Consultar Registro"),;
                   EJECUTAR("BRUNDMEDPRECIOS","PRE_UNDMED"+GetWhere("=",oUNDMEDCON:cCodigo),NIL,NIL,NIL,NIL,"Unidad de Medida: "+oUNDMEDCON:cCodigo+" "+oUNDMEDCON:cNombre))



// BTN11_ACTION :=EJECUTAR("BRUNDMEDPRECIOS","PRE_UNDMED"+GetWhere("=",oCursor:UND_CODIGO),NIL,NIL,NIL,NIL,"Unidad de Medida: "+oCursor:UND_CODIGO+" "+oCursor:UND_DESCRI)
// EJECUTAR("BRDPINVPRECIO","PRE_LISTA"+GetWhere("=",oUNDMEDCON:cCodigo),2,3,4,5," Código: ["+oUNDMEDCON:cCodigo+" "+oUNDMEDCON:cNombre+"]"))

/*
   IF ISRELEASE("16.04")

     DEFINE BITMAP OF OUTLOOK oUNDMEDCON:oOut ;
            BITMAP "BITMAPS\PRECIOS.BMP";
            PROMPT "Consultar Precios";
            ACTION EJECUTAR("BRPRECIOS",NIL,NIL,NIL,NIL,NIL," ["+ALLTRIM(oUNDMEDCON:cNombre)+"] ",oUNDMEDCON:cCodigo,.F.)

   ENDIF
*/


   DEFINE BITMAP OF OUTLOOK oUNDMEDCON:oOut ;
          BITMAP "BITMAPS\\AUDITORIA.BMP" ;
          PROMPT "Auditoria del Registro" ;
          ACTION  (oUNDMEDCON:REGAUDITORIA("Consultar Auditoria por Registro"),;
                   EJECUTAR("VIEWAUDITOR","DPUNDMED",oUNDMEDCON:cCodigo,oUNDMEDCON:cNombre))

   DEFINE BITMAP OF OUTLOOK oUNDMEDCON:oOut ;
          BITMAP "BITMAPS\\AUDITORIA.BMP" ;
          PROMPT "Auditoria por Campo" ;
          ACTION  (oUNDMEDCON:REGAUDITORIA("Consultar Auditoria por Campo"),;
                   EJECUTAR("DPAUDITAEMC",oUNDMEDCON:oFrm,"DPUNDMED","DPUNDMED.SCG",oUNDMEDCON:cCodigo,oUNDMEDCON:cNombre,"UND_CODIGO          "+GetWhere("=",oUNDMEDCON:cCodigo)))


   IF lField_Dig .AND. nNumMain>0

      DEFINE BITMAP OF OUTLOOK oUNDMEDCON:oOut ;
             BITMAP "BITMAPS\\ADJUNTAR.BMP";
             PROMPT "Digitalización";
             ACTION oUNDMEDCON:MNUDIGITALIZAR()

   ENDIF

   IF lField_Mem

      DEFINE BITMAP OF OUTLOOK oUNDMEDCON:oOut ;
             BITMAP "BITMAPS\\XMEMO.BMP";
             PROMPT "Descripción Amplia";
             ACTION oUNDMEDCON:REGMEMOS()

   ENDIF


   DEFINE BITMAP OF OUTLOOK oUNDMEDCON:oOut ;
          BITMAP "BITMAPS\\XSALIR.BMP";
          PROMPT "Salir";
          ACTION oUNDMEDCON:CLOSE()


   DEFINE DIALOG oUNDMEDCON:oDlg FROM 0,oUNDMEDCON:oOut:nWidth() TO oUNDMEDCON:nHeightD,700;
          TITLE "" STYLE WS_CHILD OF oUNDMEDCON:oWnd;
          PIXEL COLOR NIL,oDp:nGris

   @ .1,.2 GROUP oUNDMEDCON:oGrp TO 10,10 PROMPT "Código ["+oUNDMEDCON:cCodigo+"]" FONT oFont

   @ .5,.5 SAY oUNDMEDCON:cNombre SIZE 190,10;
           COLOR CLR_WHITE,12615680;
           FONT oFont

   ACTIVATE DIALOG oUNDMEDCON:oDlg NOWAIT VALID .F.

   oUNDMEDCON:Activate("oUNDMEDCON:FRMINIT()")

 
RETURN

FUNCTION FRMINIT()

   oUNDMEDCON:oWnd:bResized:={||oUNDMEDCON:oDlg:Move(0,0,oUNDMEDCON:oWnd:nWidth(),50,.T.),;
                             oUNDMEDCON:oGrp:Move(0,0,oUNDMEDCON:oWnd:nWidth()-15,oUNDMEDCON:nHeightD,.T.)}


   EVal(oUNDMEDCON:oWnd:bResized)

RETURN .T.

FUNCTION MNUDIGITALIZAR()

   LOCAL nNumMain:=SQLGET("DPUNDMED","                    ","UND_CODIGO          "+GetWhere("=",oUNDMEDCON:cCodigo))

   oUNDMEDCON:REGAUDITORIA("Consultar Registro de Digitalización "+LSTR(nNumMain))

   nNumMain:=EJECUTAR("DPFILEEMPMAIN",nNumMain,NIL,NIL,.T.,.T.)

   SQLUPDATE("DPUNDMED","                    ",nNumMain,"UND_CODIGO          "+GetWhere("=",oUNDMEDCON:cCodigo))

RETURN .F.

FUNCTION REGMEMOS()
   LOCAL cTitle,cWhere

   oUNDMEDCON:REGAUDITORIA("Consultar Registro Memo "+LSTR(oUNDMEDCON:nNumMemo))

   EJECUTAR("DPMEMOMDIEDIT","DPUNDMED","UND_CODIGO          ","                    ",oUNDMEDCON:cCodigo,cTitle,cWhere,.T.)

RETURN .F.

FUNCTION REGAUDITORIA(cConsulta)
RETURN EJECUTAR("AUDITORIA","DCON",.F.,"DPUNDMED",oUNDMEDCON:cCodigo,NIL,NIL,NIL,NIL,cConsulta)



// EOF
