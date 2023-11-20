// Programa   : INVSERDISPON	
// Fecha/Hora : 13/03/2006 16:53:37
// Propósito  : Visualizar Seriales Disponibles
// Creado Por : Juan Navas
// Llamado por: DPINVCON
// Aplicación : Inventario
// Tabla      : DPMOVINV

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodigo,cCodSuc,cNombre)

  LOCAL aData:={},oCol,oTable,nSerial:=0
  LOCAL cSql:="",cWhere:="",cTitle

  IF Type("oSerDisp")="O" .AND. oSerDisp:oWnd:hWnd>0
     RETURN EJECUTAR("BRRUNNEW",oSerDisp,GetScript())
  ENDIF


  DEFAULT cCodigo:=SQLGET("DPINV","INV_CODIGO","INV_METCOS"+GetWhere("=","S")),;
          cCodSuc:=oDp:cSucursal,;
          cNombre:=SQLGET("DPINV","INV_DESCRI","INV_CODIGO"+GetWhere("=",cCodigo))
 
  cSql:=" SELECT MOV_CODALM , MSR_SERIAL , SUM(MOV_FISICO*MOV_INVACT) , COUNT(MSR_SERIAL) , MAX(MOV_FECHA) "+;
        " FROM DPMOVSERIAL "+;
        " INNER JOIN DPMOVINV ON MSR_CODSUC=MOV_CODSUC AND "+;
        "                        MSR_CODALM=MOV_CODALM AND "+;
        "                        MSR_TIPDOC=MOV_TIPDOC AND "+;
        "                        MSR_NUMDOC=MOV_DOCUME AND "+;
        "                        MSR_CODCTA=MOV_CODCTA AND "+;
        "                        MSR_ITEM  =MOV_ITEM       "+;
        " WHERE MOV_CODIGO"+GetWhere("=",cCodigo)+;
        "   AND MOV_CODSUC"+GetWhere("=",cCodSuc)+;
        " GROUP BY MOV_CODALM, MSR_SERIAL  "+;
        " HAVING SUM(MOV_FISICO*MOV_INVACT) > 0 "
        " ORDER BY MOV_ALMACE,MSR_SERIAL "
 
  aData:=ASQL(cSql)

  IF LEN(aData)=0
     MensajeErr("Producto ["+ALLTRIM(cCodigo)+"] no posee Seriales Disponibles")
     RETURN .F.
  ENDIF

  AEVAL(aData,{|a,n|aData[n,5]:=SQLTODATE(a[5]),nSerial:=nSerial+a[3]})

  cTitle:="Seriales Disponibles "
  ViewData(aData,cCodigo,cTitle)

RETURN .T.

FUNCTION ViewData(aData,cCodigo,cTitle)
   LOCAL oBrw,oCol
   LOCAL I,nMonto:=0
   LOCAL cSql,oTable
   LOCAL oFont,oFontB
   LOCAL nDebe:=0,nHaber:=0,aTotal:=ATOTALES(aData)
   LOCAL aCoors:=GetCoors( GetDesktopWindow() )

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 
   DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD

   //   oSerDisp:=DPEDIT():New(cTitle,"INVSERDISPON.EDT","oSerDisp",.T.)

   DpMdi(cTitle,"oSerDisp","INVSERDISPON.EDT")
   oSerDisp:Windows(0,0,aCoors[3]-160,MIN(530,aCoors[4]-10),.T.) // Maximizado

   oSerDisp:cCodigo:=cCodigo
   oSerDisp:cNombre:=cNombre
   oSerDisp:lMsgBar:=.F.
   oSerDisp:cCodigo  :=cCodigo
   oSerDisp:cNombre  :=cNombre
   oSerDisp:cCodSuc  :=cCodSuc

   oSerDisp:nClrPane1:=oDp:nClrPane1
   oSerDisp:nClrPane2:=oDp:nClrPane2

   oSerDisp:oBrw:=TXBrowse():New( oSerDisp:oDlg )
   oSerDisp:oBrw:SetArray( aData, .F. )
   oSerDisp:oBrw:SetFont(oFont)
   oSerDisp:oBrw:lFooter     :=.T.
   oSerDisp:oBrw:lHScroll    :=.F.
   oSerDisp:oBrw:nHeaderLines:= 1
   oSerDisp:oBrw:lFooter     :=.T.


   AEVAL(oSerDisp:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

   oCol:=oSerDisp:oBrw:aCols[1]   
   oCol:cHeader      :="Alm"
   oCol:nWidth       :=040

   oCol:=oSerDisp:oBrw:aCols[2]   
   oCol:cHeader      :="Número"
   oCol:nWidth       :=180

   oCol:=oSerDisp:oBrw:aCols[3]  
   oCol:nDataStrAlign:= AL_RIGHT
   oCol:nHeadStrAlign:= AL_RIGHT
   oCol:nFootStrAlign:= AL_RIGHT
   oCol:cHeader      :="# Disp."
   oCol:nWidth       :=80
   oCol:bStrData     :={|nMonto|nMonto:=oSerDisp:oBrw:aArrayData[oSerDisp:oBrw:nArrayAt,3],;
                                TRAN(nMonto,"9999")}
   oCol:cFooter      := TRAN(aTotal[3],"9999")

   oCol:=oSerDisp:oBrw:aCols[4]  
   oCol:nDataStrAlign:= AL_RIGHT
   oCol:nHeadStrAlign:= AL_RIGHT
   oCol:nFootStrAlign:= AL_RIGHT
   oCol:cHeader      :="# Trans"
   oCol:nWidth       :=80
   oCol:bStrData     :={|nMonto|nMonto:=oSerDisp:oBrw:aArrayData[oSerDisp:oBrw:nArrayAt,4],;
                                TRAN(nMonto,"9999")}

   oCol:=oSerDisp:oBrw:aCols[5]   
   oCol:cHeader      :="Fecha"
   oCol:nWidth       :=80

   oSerDisp:oBrw:bClrStd  := {|oBrw,nClrText,aData|oBrw:=oSerDisp:oBrw,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                                  nClrText:=0,;
                                                  {nClrText,iif( oBrw:nArrayAt%2=0, oSerDisp:nClrPane1, oSerDisp:nClrPane2 ) } }

   oSerDisp:oBrw:bClrHeader:= {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oSerDisp:oBrw:bClrFooter:= {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

   oSerDisp:oBrw:bLDblClick:={|| oSerDisp:INVSERENTRADA()}

   oSerDisp:oBrw:CreateFromCode()

   oSerDisp:oWnd:oClient := oSerDisp:oBrw
  
   oSerDisp:Activate({||oSerDisp:ViewDatBar()})

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar()
   LOCAL oCursor,oBar,oBtn,oFont,oCol,nDif
   LOCAL nWidth :=0 // Ancho Calculado seg£n Columnas
   LOCAL nHeight:=0 // Alto
   LOCAL nLines :=0 // Lineas
   LOCAL oDlg:=oSerDisp:oDlg

   oSerDisp:oBrw:GoTop(.T.)

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -10 BOLD 

   DEFINE CURSOR oCursor HAND
   IF !oDp:lBtnText 
     DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   ELSE 
     DEFINE BUTTONBAR oBar SIZE oDp:nBtnWidth,oDp:nBarnHeight+6+40 OF oDlg 3D CURSOR oCursor 
   ENDIF 


   oSerDisp:oFontBtn   :=oFont    
   oSerDisp:nClrPaneBar:=oDp:nGris
   oSerDisp:oBrw:oLbx  :=oSerDisp

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XPRINT.BMP";
          TOP PROMPT "Imprimir"; 
          ACTION  (oSerDisp:oRep:=REPORTE("SERDISPON"),;
                   oSerDisp:oRep:SetRango(1,oSerDisp:cCodigo,oSerDisp:cCodigo))

   oBtn:cToolTip:="Imprimir Seriales Disponibles"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
            TOP PROMPT "Buscar"; 
              ACTION  EJECUTAR("BRWSETFIND",oSerDisp:oBrw)

   oBtn:cToolTip:="Buscar"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\EXCEL.BMP";
            TOP PROMPT "Excel"; 
              ACTION  (EJECUTAR("BRWTOEXCEL",oSerDisp:oBrw,oSerDisp:cTitle,oSerDisp:cNombre))

   oBtn:cToolTip:="Exportar hacia Excel"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
          MENU EJECUTAR("BRBTNMENUFILTER",oSerDisp:oBrw,oSerDisp);
          TOP PROMPT "Filtrar"; 
          ACTION  EJECUTAR("BRWSETFILTER",oSerDisp:oBrw)

   oBtn:cToolTip:="Filtrar Registros"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          TOP PROMPT "Primero"; 
          ACTION  (oSerDisp:oBrw:GoTop(),oSerDisp:oBrw:Setfocus())

/*
   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xSIG.BMP";
            TOP PROMPT "Avance"; 
              ACTION  (oSerDisp:oBrw:PageDown(),oSerDisp:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xANT.BMP";
            TOP PROMPT "Anterior"; 
              ACTION  (oSerDisp:oBrw:PageUp(),oSerDisp:oBrw:Setfocus())
*/

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          TOP PROMPT "Ultimo"; 
          ACTION  (oSerDisp:oBrw:GoBottom(),oSerDisp:oBrw:Setfocus())


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          TOP PROMPT "Cerrar"; 
          ACTION  oSerDisp:Close()

  oSerDisp:oBrw:SetColor(0,oSerDisp:nClrPane1)

  oBar:SetColor(CLR_BLACK,oDp:nGris)
  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})
  
  oSerDisp:SETBTNBAR(52,60,oBar)

  @ 10+55,27 SAY " "+oSerDisp:cCodigo OF oBar BORDER SIZE 345-15,18 COLOR oDp:nClrYellowText,oDp:nClrYellow PIXEL
  @ 30+55,27 SAY " "+oSerDisp:cNombre OF oBar BORDER SIZE 345-15,18 COLOR oDp:nClrYellowText,oDp:nClrYellow PIXEL


RETURN .T.

FUNCTION INVSERENTRADA()
  LOCAL aLine  :=oSerDisp:oBrw:aArrayData[oSerDisp:oBrw:nArrayAt]
  LOCAL cSerial:=aLine[1]

EJECUTAR("INVSERENTRADA",oSerDisp:cCodigo,oDp:cSucursal,NIL,cSerial)


// EOF

