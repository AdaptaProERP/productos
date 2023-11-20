// Programa   : INVSERENTRADA	
// Fecha/Hora : 13/03/2006 16:53:37
// Propósito  : Visualizar Seriales Disponibles
// Creado Por : Juan Navas
// Llamado por: DPINVCON
// Aplicación : Inventario
// Tabla      : DPMOVINV

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodigo,cCodSuc,cNombre,cSerial)
  LOCAL aData:={},oCol,oTable,nSerial:=0
  LOCAL cSql:="",cWhere:="",cTitle

  DEFAULT cCodigo:=SQLGET("DPINV","INV_CODIGO","INV_METCOS"+GetWhere("=","S")),;
          cCodSuc:=oDp:cSucursal,;
          cNombre:=SQLGET("DPINV","INV_DESCRI","INV_CODIGO"+GetWhere("=",cCodigo))


  IF Type("oSerEnt")="O" .AND. oSerEnt:oWnd:hWnd>0
     RETURN EJECUTAR("BRRUNNEW",oSerEnt,GetScript())
  ENDIF

  IF !Empty(cSerial)
     cWhere:="MSR_SERIAL"+GetWhere("=",cSerial)
  ENDIF

  cSql:=" SELECT MOV_CODALM , MSR_SERIAL,MOV_TIPDOC,MOV_CODCTA,MOV_DOCUME,PRO_NOMBRE, MOV_FECHA "+;
        " FROM DPMOVSERIAL "+;
        " INNER JOIN DPMOVINV ON MSR_CODSUC=MOV_CODSUC AND "+;
        "                        MSR_CODALM=MOV_CODALM AND "+;
        "                        MSR_TIPDOC=MOV_TIPDOC AND "+;
        "                        MSR_NUMDOC=MOV_DOCUME AND "+;
        "                        MSR_CODCTA=MOV_CODCTA AND "+;
        "                        MSR_ITEM  =MOV_ITEM       "+;
        " LEFT JOIN DPPROVEEDOR ON PRO_CODIGO=MOV_CODCTA "+;
        " WHERE MOV_CODIGO"+GetWhere("=",cCodigo)+;
        "   AND MOV_CODSUC"+GetWhere("=",cCodSuc)+;
        IF(Empty(cWhere) ,"" ," AND "+cWhere )+;
        "   AND MOV_FISICO=1 AND MOV_INVACT<>0 "
 
  aData:=ASQL(cSql)

  IF LEN(aData)=0
     MensajeErr("Producto ["+ALLTRIM(cCodigo)+"] no posee Entrada de Seriales")
     RETURN .F.
  ENDIF

  AEVAL(aData,{|a,n|aData[n,5]:=SQLTODATE(a[5]),nSerial:=nSerial+a[3]})

  cTitle:="Entrada de Seriales "
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

   DpMdi(cTitle,"oSerEnt","INVSERENTRADA.EDT")
   oSerEnt:Windows(0,0,aCoors[3]-160,MIN(900,aCoors[4]-10),.T.) // Maximizado

// oSerEnt:=DPEDIT():New(cTitle,"INVSERENTRADA.EDT","oSerEnt",.T.)
   oSerEnt:cCodigo:=cCodigo
   oSerEnt:cNombre:=cNombre
   oSerEnt:lMsgBar:=.F.

   oSerEnt:cCodigo  :=cCodigo
   oSerEnt:cNombre  :=cNombre
   oSerEnt:cCodSuc  :=cCodSuc

   oSerEnt:nClrPane1:=oDp:nClrPane1
   oSerEnt:nClrPane2:=oDp:nClrPane2


   oSerEnt:oBrw:=TXBrowse():New( oSerEnt:oDlg )
   oSerEnt:oBrw:SetArray( aData, .F. )
   oSerEnt:oBrw:SetFont(oFont)
   oSerEnt:oBrw:lFooter     :=.F.
   oSerEnt:oBrw:lHScroll    :=.T.
   oSerEnt:oBrw:nHeaderLines:= 2
   oSerEnt:oBrw:lFooter     :=.F.


   AEVAL(oSerEnt:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

   oCol:=oSerEnt:oBrw:aCols[1]   
   oCol:cHeader      :="Alm"
   oCol:nWidth       :=040

   oCol:=oSerEnt:oBrw:aCols[2]   
   oCol:cHeader      :="Número"
   oCol:nWidth       :=180

   oCol:=oSerEnt:oBrw:aCols[3]  
   oCol:cHeader      :="Tipo"
   oCol:nWidth       :=80

   oCol:=oSerEnt:oBrw:aCols[4]  
   oCol:cHeader      :="Código"+CRLF+"Provee."
   oCol:nWidth       :=80

   oCol:=oSerEnt:oBrw:aCols[5]   
   oCol:cHeader      :="Número"+CRLF+"Doc."
   oCol:nWidth       :=80

   oCol:=oSerEnt:oBrw:aCols[6]   
   oCol:cHeader      :="Nombre del Proveedor"
   oCol:nWidth       :=220

   oCol:=oSerEnt:oBrw:aCols[7]   
   oCol:cHeader      :="Fecha"
   oCol:nWidth       :=80


   oSerEnt:oBrw:bClrStd  := {|oBrw,nClrText,aData|oBrw:=oSerEnt:oBrw,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                                  nClrText:=0,;
                                                  {nClrText,iif( oBrw:nArrayAt%2=0, oSerEnt:nClrPane1, oSerEnt:nClrPane2 ) } }


   oSerEnt:oBrw:bClrHeader:= {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oSerEnt:oBrw:bClrFooter:= {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

   oSerEnt:oBrw:bLDblClick:={|| oSerEnt:BRDPSERXCLI()}

/*
aLine| aLine:=oSerEnt:oBrw:aArrayData[ oSerEnt:oBrw:nArrayAt ],;
                                      EJECUTAR("INVVIEWSERIAL",;
                                      oSerEnt:cCodigo,;
                                      oSerEnt:cCodSuc,;
                                      aLine[1],;
                                      aLine[2],;
                                      oSerEnt:cNombre)}
*/

   oSerEnt:oBrw:CreateFromCode()

   oSerEnt:oWnd:oClient := oSerEnt:oBrw


   oSerEnt:Activate({||oSerEnt:ViewDatBar()})

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar()
   LOCAL oCursor,oBar,oBtn,oFont,oCol,nDif
   LOCAL nWidth :=0 // Ancho Calculado seg£n Columnas
   LOCAL nHeight:=0 // Alto
   LOCAL nLines :=0 // Lineas
   LOCAL oDlg:=oSerEnt:oDlg

   oSerEnt:oBrw:GoTop(.T.)

   DEFINE CURSOR oCursor HAND

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -09 BOLD

   IF !oDp:lBtnText 
     DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   ELSE 
     DEFINE BUTTONBAR oBar SIZE oDp:nBtnWidth,oDp:nBarnHeight+6+40 OF oDlg 3D CURSOR oCursor 
   ENDIF 


   oSerEnt:oFontBtn   :=oFont    
   oSerEnt:nClrPaneBar:=oDp:nGris
   oSerEnt:oBrw:oLbx  :=oSerEnt


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PROVEEDORES.BMP",NIL,"BITMAPS\PROVEEDORESG.BMP";
          TOP PROMPT "Provee."; 
          ACTION oSerEnt:VERPROVEEDOR();
          WHEN !Empty(oSerEnt:oBrw:aArrayData[1,1])
             
   oBtn:cToolTip:="Ver Proveedor"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FORM.BMP",NIL,"BITMAPS\FACTURAVTAG.BMP";
          TOP PROMPT "Doc/Org"; 
          ACTION oSerEnt:VERFACTURA();
          WHEN !Empty(oSerEnt:oBrw:aArrayData[1,1])
             
   oBtn:cToolTip:="Consultar Documento"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XBROWSE.BMP",NIL,"BITMAPS\XBROWSEG.BMP";
          TOP PROMPT "Detalles"; 
          ACTION oSerEnt:BRDPSERXCLI();
          WHEN !Empty(oSerEnt:oBrw:aArrayData[1,1])
             
   oBtn:cToolTip:="Consultar Documento"





   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XPRINT.BMP";
          TOP PROMPT "Imprimir"; 
          ACTION  (oSerEnt:oRep:=REPORTE("SERDISPON"),;
                   oSerEnt:oRep:SetRango(1,oSerEnt:cCodigo,oSerEnt:cCodigo))

   oBtn:cToolTip:="Imprimir Seriales Disponibles"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
          TOP PROMPT "Buscar"; 
          ACTION  EJECUTAR("BRWSETFIND",oSerEnt:oBrw)

   oBtn:cToolTip:="Buscar"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
          MENU EJECUTAR("BRBTNMENUFILTER",oSerEnt:oBrw,oSerEnt);
          TOP PROMPT "Filtrar"; 
          ACTION  EJECUTAR("BRWSETFILTER",oSerEnt:oBrw)

   oBtn:cToolTip:="Filtrar Registros"



   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\EXCEL.BMP";
          TOP PROMPT "Excel"; 
           ACTION  (EJECUTAR("BRWTOEXCEL",oSerEnt:oBrw,oSerEnt:cTitle,oSerEnt:cNombre))

   oBtn:cToolTip:="Exportar hacia Excel"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          TOP PROMPT "Primero"; 
          ACTION  (oSerEnt:oBrw:GoTop(),oSerEnt:oBrw:Setfocus())
/*
   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xSIG.BMP";
          TOP PROMPT "Avance"; 
          ACTION  (oSerEnt:oBrw:PageDown(),oSerEnt:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xANT.BMP";
            TOP PROMPT "Anterior"; 
              ACTION  (oSerEnt:oBrw:PageUp(),oSerEnt:oBrw:Setfocus())
*/

  DEFINE BUTTON oBtn;
         OF oBar;
         NOBORDER;
         FONT oFont;
         FILENAME "BITMAPS\xFIN.BMP";
         TOP PROMPT "Ultimo"; 
         ACTION  (oSerEnt:oBrw:GoBottom(),oSerEnt:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          TOP PROMPT "Cerrar"; 
          ACTION  oSerEnt:Close()

  oSerEnt:oBrw:SetColor(0,oSerEnt:nClrPane1)

  oBar:SetColor(CLR_BLACK,oDp:nGris)
  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  oSerEnt:SETBTNBAR(55,45,oBar)

  DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -09 BOLD

  @ 55+8,27 SAY " "+oSerEnt:cCodigo OF oBar BORDER SIZE 200,18 COLOR oDp:nClrYellowText,oDp:nClrYellow PIXEL FONT oFont
  @ 75+8,27 SAY " "+oSerEnt:cNombre OF oBar BORDER SIZE 360,18 COLOR oDp:nClrYellowText,oDp:nClrYellow PIXEL FONT oFont
 
RETURN .T.

FUNCTION VERFACTURA()
   LOCAL cTipDoc :=oSerEnt:oBrw:aArrayData[oSerEnt:oBrw:nArrayAt,3]
   LOCAL cCodigo :=oSerEnt:oBrw:aArrayData[oSerEnt:oBrw:nArrayAt,4]
   LOCAL cNumero :=oSerEnt:oBrw:aArrayData[oSerEnt:oBrw:nArrayAt,5]

RETURN EJECUTAR("VERDOCPRO",oDp:cSucursal,cTipDoc,cCodigo,cNumero)


FUNCTION BRDPSERXCLI()
   LOCAL cTipDoc :=oSerEnt:oBrw:aArrayData[oSerEnt:oBrw:nArrayAt,3]
   LOCAL cCodigo :=oSerEnt:oBrw:aArrayData[oSerEnt:oBrw:nArrayAt,4]
   LOCAL cNumero :=oSerEnt:oBrw:aArrayData[oSerEnt:oBrw:nArrayAt,5]
   LOCAL cSerial :=oSerEnt:oBrw:aArrayData[oSerEnt:oBrw:nArrayAt,2]
   LOCAL cWhere  :="MSR_CODIGO"+GetWhere("=",oSerEnt:cCodigo)+" AND MSR_SERIAL"+GetWhere("=",cSerial),cTitle:=NIL

RETURN EJECUTAR("BRDPSERXCLI",cWhere,oDp:cSucursal,oDp:nIndefinida,CTOD(""),CTOD(""),cTitle,cSerial)

FUNCTION VERPROVEEDOR()
   LOCAL cCodigo :=oSerEnt:oBrw:aArrayData[oSerEnt:oBrw:nArrayAt,4]

   EJECUTAR("DPPROVEEDOR",0,cCodigo)

RETURN .T.
// EOF



