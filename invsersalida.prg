// Programa   : INVSERSALIDA	
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

  IF Type("oSerEnt")="O" .AND. oSerEnt:oWnd:hWnd>0
     RETURN EJECUTAR("BRRUNNEW",oSerEnt,GetScript())
  ENDIF


  DEFAULT cCodigo:=SQLGET("DPINV","INV_CODIGO","INV_METCOS"+GetWhere("=","S")),;
          cCodSuc:=oDp:cSucursal,;
          cNombre:=SQLGET("DPINV","INV_DESCRI","INV_CODIGO"+GetWhere("=",cCodigo))

  cSql:=" SELECT MOV_CODALM , MSR_SERIAL , MOV_TIPDOC , MOV_CODCTA,MOV_DOCUME,CLI_NOMBRE,MOV_FECHA "+;
        " FROM DPMOVSERIAL "+;
        " INNER JOIN DPMOVINV ON MSR_CODSUC=MOV_CODSUC AND "+;
        "                        MSR_CODALM=MOV_CODALM AND "+;
        "                        MSR_TIPDOC=MOV_TIPDOC AND "+;
        "                        MSR_NUMDOC=MOV_DOCUME AND "+;
        "                        MSR_CODCTA=MOV_CODCTA AND "+;
        "                        MSR_ITEM  =MOV_ITEM       "+;
        " LEFT JOIN DPCLIENTES ON MOV_CODCTA=CLI_CODIGO "+;
        " WHERE MOV_CODIGO"+GetWhere("=",cCodigo)+;
        "   AND MOV_CODSUC"+GetWhere("=",cCodSuc)+;
        "   AND MOV_FISICO=-1 AND MOV_INVACT<>0 "

  aData:=ASQL(cSql)

  IF LEN(aData)=0
     MensajeErr("Producto ["+ALLTRIM(cCodigo)+"] no posee Salida de Seriales")
     RETURN .F.
  ENDIF

  AEVAL(aData,{|a,n|aData[n,5]:=SQLTODATE(a[5]),nSerial:=nSerial+a[3]})

  cTitle:="Salida de Seriales "

  ViewData(aData,cCodigo,cTitle)

RETURN .T.

FUNCTION ViewData(aData,cCodigo,cTitle)
   LOCAL oBrw,oCol
   LOCAL I,nMonto:=0
   LOCAL cSql,oTable
   LOCAL oFont,oFontB
   LOCAL nDebe:=0,nHaber:=0
   LOCAL aCoors:=GetCoors( GetDesktopWindow() )

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 
   DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD

   // oSerEnt:=DPEDIT():New(cTitle,"INVSERSALIDA.EDT","oSerSal",.T.)

   DpMdi(cTitle,"oSerSal","INVSERENTRADA.EDT")

   oSerSal:Windows(0,0,aCoors[3]-160,MIN(900,aCoors[4]-10),.T.) // Maximizado

   oSerSal:lMsgBar:=.F.
   oSerSal:cCodigo  :=cCodigo
   oSerSal:cNombre  :=cNombre
   oSerSal:cCodSuc  :=cCodSuc

   oSerSal:nClrPane1:=oDp:nClrPane1
   oSerSal:nClrPane2:=oDp:nClrPane2

   oSerSal:oBrw:=TXBrowse():New( oSerSal:oDlg )
   oSerSal:oBrw:SetArray( aData, .F. )
   oSerSal:oBrw:SetFont(oFont)
   oSerSal:oBrw:lFooter     :=.F.
   oSerSal:oBrw:lHScroll    :=.F.
   oSerSal:oBrw:nHeaderLines:= 2
   oSerSal:oBrw:lFooter     :=.T.




   AEVAL(oSerSal:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

   oCol:=oSerSal:oBrw:aCols[1]   
   oCol:cHeader      :="Alm"
   oCol:nWidth       :=040

   oCol:=oSerSal:oBrw:aCols[2]   
   oCol:cHeader      :="Número"
   oCol:nWidth       :=180

   oCol:=oSerSal:oBrw:aCols[3]  
   oCol:cHeader      :="Tipo"
   oCol:nWidth       :=80

   oCol:=oSerSal:oBrw:aCols[4]  
   oCol:cHeader      :="Código"
   oCol:nWidth       :=80

   oCol:=oSerSal:oBrw:aCols[5]  
   oCol:cHeader      :="Número"+CRLF+"Doc."
   oCol:nWidth       :=80

   oCol:=oSerSal:oBrw:aCols[6]  
   oCol:cHeader      :="Nombre del Cliente"
   oCol:nWidth       :=80

   oCol:=oSerSal:oBrw:aCols[7]   
   oCol:cHeader      :="Fecha"
   oCol:nWidth       :=80

   oSerSal:oBrw:bClrStd  := {|oBrw,nClrText,aData|oBrw:=oSerSal:oBrw,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                                  nClrText:=0,;
                                                  {nClrText,iif( oBrw:nArrayAt%2=0, oSerSal:nClrPane1, oSerSal:nClrPane2 ) } }


   oSerSal:oBrw:bClrHeader:= {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oSerSal:oBrw:bClrFooter:= {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

/*
   oSerSal:oBrw:bLDblClick:={|aLine| aLine:=oSerSal:oBrw:aArrayData[ oSerSal:oBrw:nArrayAt ],;
                                      EJECUTAR("INVVIEWSERIAL",;
                                      oSerSal:cCodigo,;
                                      oSerSal:cCodSuc,;
                                      aLine[1],;
                                      aLine[2],;
                                      oSerSal:cNombre)}
*/

   oSerSal:oBrw:CreateFromCode()

   oSerSal:oWnd:oClient := oSerSal:oBrw


   oSerSal:Activate({||oSerSal:ViewDatBar(oSerSal)})

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar(oSerSal)
   LOCAL oCursor,oBar,oBtn,oFont,oCol,nDif
   LOCAL nWidth :=0 // Ancho Calculado seg£n Columnas
   LOCAL nHeight:=0 // Alto
   LOCAL nLines :=0 // Lineas
   LOCAL oDlg:=oSerSal:oDlg

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -10 BOLD 

   oSerSal:oBrw:GoTop(.T.)

   DEFINE CURSOR oCursor HAND
   IF !oDp:lBtnText 
     DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   ELSE 
     DEFINE BUTTONBAR oBar SIZE oDp:nBtnWidth,oDp:nBarnHeight+6+40 OF oDlg 3D CURSOR oCursor 
   ENDIF 


   oSerSal:oFontBtn   :=oFont    
   oSerSal:nClrPaneBar:=oDp:nGris
   oSerSal:oBrw:oLbx  :=oSerSal

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CLIENTE.BMP",NIL,"BITMAPS\CLIENTEG.BMP";
          TOP PROMPT "Cliente"; 
          ACTION EJECUTAR("DPCLIENTES",0,oDPSERXCLI:oBrw:aArrayData[oDPSERXCLI:oBrw:nArrayAt,4]);
          WHEN !Empty(oSerSal:oBrw:aArrayData[1,1])
             
   oBtn:cToolTip:="Consultar Documento"



   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FORM.BMP",NIL,"BITMAPS\FACTURAVTAG.BMP";
          TOP PROMPT "Doc/Org"; 
          ACTION oSerSal:VERFACTURA();
          WHEN !Empty(oSerSal:oBrw:aArrayData[1,1])
             
   oBtn:cToolTip:="Consultar Documento"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\SERIAL_ENTRADA.BMP";
          TOP PROMPT "Entrada"; 
          ACTION oSerSal:SERENTRADA();
          WHEN .T.
             
   oBtn:cToolTip:="Serial Entrada"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XPRINT.BMP";
          TOP PROMPT "Imprimir"; 
          ACTION  (oSerSal:oRep:=REPORTE("SERDISPON"),;
                   oSerSal:oRep:SetRango(1,oSerSal:cCodigo,oSerSal:cCodigo))

   oBtn:cToolTip:="Imprimir Seriales Disponibles"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
            TOP PROMPT "Buscar"; 
              ACTION  EJECUTAR("BRWSETFIND",oSerSal:oBrw)

   oBtn:cToolTip:="Buscar"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\EXCEL.BMP";
            TOP PROMPT "Excel"; 
              ACTION  (EJECUTAR("BRWTOEXCEL",oSerSal:oBrw,oSerSal:cTitle,oSerSal:cNombre))

   oBtn:cToolTip:="Exportar hacia Excel"
/*
   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
            TOP PROMPT "Primero"; 
              ACTION  (oSerSal:oBrw:GoTop(),oSerSal:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xSIG.BMP";
            TOP PROMPT "Avance"; 
              ACTION  (oSerSal:oBrw:PageDown(),oSerSal:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xANT.BMP";
            TOP PROMPT "Anterior"; 
              ACTION  (oSerSal:oBrw:PageUp(),oSerSal:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
            TOP PROMPT "Ultimo"; 
              ACTION  (oSerSal:oBrw:GoBottom(),oSerSal:oBrw:Setfocus())

*/
   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
            TOP PROMPT "Cerrar"; 
              ACTION  oSerSal:Close()

  oSerSal:oBrw:SetColor(0,oSerSal:nClrPane1)

  oBar:SetColor(CLR_BLACK,oDp:nGris)
  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  oSerSal:SETBTNBAR(52,60,oBar)

  @ 10+55,27 SAY " "+oSerSal:cCodigo OF oBar BORDER SIZE 345-15,18 COLOR oDp:nClrYellowText,oDp:nClrYellow PIXEL
  @ 30+55,27 SAY " "+oSerSal:cNombre OF oBar BORDER SIZE 345-15,18 COLOR oDp:nClrYellowText,oDp:nClrYellow PIXEL

RETURN .T.

FUNCTION VERFACTURA()
   LOCAL cCodigo :=oDPSERXCLI:oBrw:aArrayData[oDPSERXCLI:oBrw:nArrayAt,4]
   LOCAL cTipDoc :=oDPSERXCLI:oBrw:aArrayData[oDPSERXCLI:oBrw:nArrayAt,7]
   LOCAL cNumero :=oDPSERXCLI:oBrw:aArrayData[oDPSERXCLI:oBrw:nArrayAt,8]

RETURN EJECUTAR("VERDOCCLI",oDp:cSucursal,cTipDoc,cCodigo,cNumero,"D")

FUNCTION SERENTRADA()
   LOCAL cSerial:=oSerSal:oBrw:aArrayData[oSerSal:oBrw:nArrayAt,2]

RETURN EJECUTAR("INVSERENTRADA",oSerSal:cCodigo,NIL,NIL,cSerial )


// EOF




