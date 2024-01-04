// Programa   : BRINVUNDMED
// Fecha/Hora : 13/11/2018 12:17:47
// Propósito  : "Productos Vinculados con Unidad de Medida"
// Creado Por : Automáticamente por BRWMAKER
// Llamado por: <DPXBASE>
// Aplicación : Gerencia 
// Tabla      : <TABLA>

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle,cUndMed)
   LOCAL aData,aFechas,cFileMem:="USER\BRINVUNDMED.MEM",V_nPeriodo:=4,cCodPar
   LOCAL V_dDesde:=CTOD(""),V_dHasta:=CTOD("")
   LOCAL cServer:=oDp:cRunServer
   LOCAL lConectar:=.F.

   DEFAULT cUndMed:=oDp:cUndMed,;
           cWhere :="IME_UNDMED"+GetWhere("=",cUndMed)

   oDp:cRunServer:=NIL

   IF !Empty(cServer)

     MsgRun("Conectando con Servidor "+cServer+" ["+ALLTRIM(SQLGET("DPSERVERBD","SBD_DOMINI","SBD_CODIGO"+GetWhere("=",cServer)))+"]",;
            "Por Favor Espere",{||lConectar:=EJECUTAR("DPSERVERDBOPEN",cServer)})

     IF !lConectar
        RETURN .F.
     ENDIF

   ENDIF 

   IF Type("oINVUNDMED")="O" .AND. oINVUNDMED:oWnd:hWnd>0
      RETURN EJECUTAR("BRRUNNEW",oINVUNDMED,GetScript())
   ENDIF


   cTitle:="Productos Vinculados con Unidad de Medida" +IF(Empty(cTitle),"",cTitle)

   oDp:oFrm:=NIL

   IF FILE(cFileMem) .AND. nPeriodo=NIL
      RESTORE FROM (cFileMem) ADDI
      nPeriodo:=V_nPeriodo
   ENDIF

   DEFAULT cCodSuc :=oDp:cSucursal,;
           nPeriodo:=4,;
           dDesde  :=CTOD(""),;
           dHasta  :=CTOD("")


   // Obtiene el Código del Parámetro

   IF !Empty(cWhere)
 
      cCodPar:=ATAIL(_VECTOR(cWhere,"="))
 
      IF TYPE(cCodPar)="C"
        cCodPar:=SUBS(cCodPar,2,LEN(cCodPar))
        cCodPar:=LEFT(cCodPar,LEN(cCodPar)-1)
      ENDIF

   ENDIF

   IF .T. .AND. (!nPeriodo=11 .AND. (Empty(dDesde) .OR. Empty(dhasta)))

       aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)
       dDesde :=aFechas[1]
       dHasta :=aFechas[2]

   ENDIF

   IF .F.

      IF nPeriodo=10
        dDesde :=V_dDesde
        dHasta :=V_dHasta
      ELSE
        aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)
        dDesde :=aFechas[1]
        dHasta :=aFechas[2]
      ENDIF

     aData :=LEERDATA(HACERWHERE(dDesde,dHasta,cWhere),NIL,cServer)


   ELSEIF (.T.)

     aData :=LEERDATA(HACERWHERE(dDesde,dHasta,cWhere),NIL,cServer)

   ENDIF

   IF Empty(aData)
      MensajeErr("no hay "+cTitle,"Información no Encontrada")
      RETURN .F.
   ENDIF

   ViewData(aData,cTitle,oDp:cWhere)

   oDp:oFrm:=oINVUNDMED
            
RETURN .T. 


FUNCTION ViewData(aData,cTitle,cWhere_)
   LOCAL oBrw,oCol,aTotal:=ATOTALES(aData)
   LOCAL oFont,oFontB
   LOCAL aPeriodos:=ACLONE(oDp:aPeriodos)
   LOCAL aCoors:=GetCoors( GetDesktopWindow() )

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 
   DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD


   DpMdi(cTitle,"oINVUNDMED","BRINVUNDMED.EDT")
// oINVUNDMED:CreateWindow(0,0,100,550)

   oINVUNDMED:Windows(0,0,aCoors[3]-160,MIN(1180,aCoors[4]-10),.T.) // Maximizado

   oINVUNDMED:cCodSuc  :=cCodSuc
   oINVUNDMED:cUndMed  :=cUndMed
   oINVUNDMED:lMsgBar  :=.F.
   oINVUNDMED:cPeriodo :=aPeriodos[nPeriodo]
   oINVUNDMED:cCodSuc  :=cCodSuc
   oINVUNDMED:nPeriodo :=nPeriodo
   oINVUNDMED:cNombre  :=""
   oINVUNDMED:dDesde   :=dDesde
   oINVUNDMED:cServer  :=cServer
   oINVUNDMED:dHasta   :=dHasta
   oINVUNDMED:cWhere   :=cWhere
   oINVUNDMED:cWhere_  :=cWhere_
   oINVUNDMED:cWhereQry:=""
   oINVUNDMED:cSql     :=oDp:cSql
   oINVUNDMED:oWhere   :=TWHERE():New(oINVUNDMED)
   oINVUNDMED:cCodPar  :=cCodPar // Código del Parámetro
   oINVUNDMED:lWhen    :=.T.
   oINVUNDMED:cTextTit :="" // Texto del Titulo Heredado
   oINVUNDMED:oDb     :=oDp:oDb
   oINVUNDMED:cBrwCod  :="INVUNDMED"
   oINVUNDMED:lTmdi    :=.T.
   oINVUNDMED:cUndMed  :=cUndMed

   oINVUNDMED:oBrw:=TXBrowse():New( IF(oINVUNDMED:lTmdi,oINVUNDMED:oWnd,oINVUNDMED:oDlg ))
   oINVUNDMED:oBrw:SetArray( aData, .F. )
   oINVUNDMED:oBrw:SetFont(oFont)

   oINVUNDMED:oBrw:lFooter     := .T.
   oINVUNDMED:oBrw:lHScroll    := .F.
   oINVUNDMED:oBrw:nHeaderLines:= 2
   oINVUNDMED:oBrw:nDataLines  := 1
   oINVUNDMED:oBrw:nFooterLines:= 1

   oINVUNDMED:aData            :=ACLONE(aData)
   oINVUNDMED:nClrText :=0
   oINVUNDMED:nClrPane1:=oDp:nClrPane1
   oINVUNDMED:nClrPane2:=oDp:nClrPane2

   AEVAL(oINVUNDMED:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

   

  oCol:=oINVUNDMED:oBrw:aCols[1]
  oCol:cHeader      :='Código'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oINVUNDMED:oBrw:aArrayData ) } 
  oCol:nWidth       := 160

  oCol:=oINVUNDMED:oBrw:aCols[2]
  oCol:cHeader      :='Descripción'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oINVUNDMED:oBrw:aArrayData ) } 
  oCol:nWidth       := 480

  oCol:=oINVUNDMED:oBrw:aCols[3]
  oCol:cHeader      :='Presentación'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oINVUNDMED:oBrw:aArrayData ) } 
  oCol:nWidth       := 160

  oCol:=oINVUNDMED:oBrw:aCols[4]
  oCol:cHeader      :='Cantidad'+CRLF+'Unidades'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oINVUNDMED:oBrw:aArrayData ) } 
  oCol:nWidth       := 80
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oINVUNDMED:oBrw:aArrayData[oINVUNDMED:oBrw:nArrayAt,4],FDP(nMonto,'999,999,999.99')}
//   oCol:cFooter      :=FDP(aTotal[4],'999,999,999.99')


  oCol:=oINVUNDMED:oBrw:aCols[5]
  oCol:cHeader      :='Para'+CRLF+'Venta'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oINVUNDMED:oBrw:aArrayData ) } 
  oCol:nWidth       := 45

  oCol:=oINVUNDMED:oBrw:aCols[6]
  oCol:cHeader      :='Para'+CRLF+'Compra'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oINVUNDMED:oBrw:aArrayData ) } 
  oCol:nWidth       := 45

  oCol:=oINVUNDMED:oBrw:aCols[7]
  oCol:cHeader      :='Volumen'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oINVUNDMED:oBrw:aArrayData ) } 
  oCol:nWidth       := 80
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oINVUNDMED:oBrw:aArrayData[oINVUNDMED:oBrw:nArrayAt,7],FDP(nMonto,'999,999,999.99')}
//oCol:cFooter      :=FDP(aTotal[7],'999,999,999.99')


  oCol:=oINVUNDMED:oBrw:aCols[8]
  oCol:cHeader      :='Pre-'+CRLF+'determinada'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oINVUNDMED:oBrw:aArrayData ) } 
  oCol:nWidth       := 70
  oCol:AddBmpFile("BITMAPS\checkverde.bmp") 
  oCol:AddBmpFile("BITMAPS\checkrojo.bmp") 
  oCol:bBmpData    := {||oBrw:=oINVUNDMED:oBrw,IIF(oBrw:aArrayData[oBrw:nArrayAt,8],1,2) }
  oCol:bStrData     :={||""}


  oCol:=oINVUNDMED:oBrw:aCols[9]
  oCol:cHeader      :='Signo'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oINVUNDMED:oBrw:aArrayData ) } 
  oCol:nWidth       := 40

   oINVUNDMED:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))

   oINVUNDMED:oBrw:bClrStd               := {|oBrw,nClrText,aData|oBrw:=oINVUNDMED:oBrw,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                           oINVUNDMED:nClrText,;
                                          {nClrText,iif( oBrw:nArrayAt%2=0, oINVUNDMED:nClrPane1, oINVUNDMED:nClrPane2 ) } }

   oINVUNDMED:oBrw:bClrHeader            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oINVUNDMED:oBrw:bClrFooter            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}


   oINVUNDMED:oBrw:bLDblClick:={|oBrw|oINVUNDMED:RUNCLICK() }

   oINVUNDMED:oBrw:bChange:={||oINVUNDMED:BRWCHANGE()}
   oINVUNDMED:oBrw:CreateFromCode()
   oINVUNDMED:bValid   :={|| EJECUTAR("BRWSAVEPAR",oINVUNDMED)}
   oINVUNDMED:BRWRESTOREPAR()

   oINVUNDMED:oWnd:oClient := oINVUNDMED:oBrw
   
   oINVUNDMED:Activate({||oINVUNDMED:ViewDatBar()})


RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar()
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg:=IF(oINVUNDMED:lTmdi,oINVUNDMED:oWnd,oINVUNDMED:oDlg)
   LOCAL nLin:=0
   LOCAL nWidth:=oINVUNDMED:oBrw:nWidth()

   oINVUNDMED:oBrw:GoBottom(.T.)
   oINVUNDMED:oBrw:Refresh(.T.)

// IF !File("FORMS\BRINVUNDMED.EDT")
//     oINVUNDMED:oBrw:Move(44,0,850+50,460)
// ENDIF

   DEFINE CURSOR oCursor HAND

   IF !oDp:lBtnText 
     DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   ELSE 
     DEFINE BUTTONBAR oBar SIZE oDp:nBtnWidth,oDp:nBarnHeight+6 OF oDlg 3D CURSOR oCursor 
   ENDIF 

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -11 BOLD


 // Emanager no Incluye consulta de Vinculos


   IF .F. .AND. Empty(oINVUNDMED:cServer)

  oINVUNDMED:oFontBtn   :=oFont    
  oINVUNDMED:nClrPaneBar:=oDp:nGris
  oINVUNDMED:oBrw:oLbx  :=oINVUNDMED

  DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\VIEW.BMP";
            TOP PROMPT "Consulta"; 
            ACTION  EJECUTAR("BRWRUNLINK",oINVUNDMED:oBrw,oINVUNDMED:cSql)

     oBtn:cToolTip:="Consultar Vinculos"


   ENDIF


    DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\PRODUCTO.BMP";
              TOP PROMPT "Producto"; 
              ACTION  EJECUTAR("DPINV",0,oINVUNDMED:oBrw:aArrayData[oINVUNDMED:oBrw:nArrayAt,1])

    oBtn:cToolTip:="Producto"


  DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\PRECIOS.BMP";
              TOP PROMPT "Precio"; 
              ACTION  oINVUNDMED:VERPRECIOS()

  oBtn:cToolTip:="Precios"



  
/*
   IF Empty(oINVUNDMED:cServer) .AND. !Empty(SQLGET("DPBRWLNK","EBR_CODIGO","EBR_CODIGO"+GetWhere("=","INVUNDMED")))
*/

   IF ISSQLFIND("DPBRWLNKCONCAT","BRC_CODIGO"+GetWhere("=","INVUNDMED"))

       DEFINE BUTTON oBtn;
       OF oBar;
       NOBORDER;
       FONT oFont;
       FILENAME "BITMAPS\XBROWSE.BMP";
         TOP PROMPT "Detalles"; 
              ACTION  EJECUTAR("BRWRUNBRWLINK",oINVUNDMED:oBrw,"INVUNDMED",oINVUNDMED:cSql,oINVUNDMED:nPeriodo,oINVUNDMED:dDesde,oINVUNDMED:dHasta,oINVUNDMED)

       oBtn:cToolTip:="Ejecutar Browse Vinculado(s)"
       oINVUNDMED:oBtnRun:=oBtn



       oINVUNDMED:oBrw:bLDblClick:={||EVAL(oINVUNDMED:oBtnRun:bAction) }


   ENDIF



   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
            TOP PROMPT "Buscar"; 
              ACTION  EJECUTAR("BRWSETFIND",oINVUNDMED:oBrw)

   oBtn:cToolTip:="Buscar"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
            TOP PROMPT "Filtrar"; 
              ACTION  EJECUTAR("BRWSETFILTER",oINVUNDMED:oBrw)

   oBtn:cToolTip:="Filtrar Registros"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\OPTIONS.BMP",NIL,"BITMAPS\OPTIONSG.BMP";
          TOP PROMPT "Opciones"; 
          ACTION  EJECUTAR("BRWSETOPTIONS",oINVUNDMED:oBrw);
          WHEN LEN(oINVUNDMED:oBrw:aArrayData)>1

   oBtn:cToolTip:="Filtrar según Valores Comunes"



IF nWidth>300

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\REFRESH.BMP";
          TOP PROMPT "Refrescar"; 
          ACTION  oINVUNDMED:BRWREFRESCAR()

   oBtn:cToolTip:="Refrescar"

ENDIF


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CRYSTAL.BMP";
          TOP PROMPT "Crystal"; 
          ACTION  EJECUTAR("BRWTODBF",oINVUNDMED)

   oBtn:cToolTip:="Visualizar Mediante Crystal Report"


IF nWidth>400

 
     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\EXCEL.BMP";
            TOP PROMPT "Excel"; 
            ACTION  (EJECUTAR("BRWTOEXCEL",oINVUNDMED:oBrw,oINVUNDMED:cTitle,oINVUNDMED:cNombre))

     oBtn:cToolTip:="Exportar hacia Excel"

     oINVUNDMED:oBtnXls:=oBtn

ENDIF

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\html.BMP";
          TOP PROMPT "Html"; 
          ACTION  (EJECUTAR("BRWTOHTML",oINVUNDMED:oBrw))

   oBtn:cToolTip:="Generar Archivo html"

   oINVUNDMED:oBtnHtml:=oBtn

IF nWidth>300

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PREVIEW.BMP";
          TOP PROMPT "Preview"; 
          ACTION  (EJECUTAR("BRWPREVIEW",oINVUNDMED:oBrw))

   oBtn:cToolTip:="Previsualización"

   oINVUNDMED:oBtnPreview:=oBtn

ENDIF

   IF ISSQLGET("DPREPORTES","REP_CODIGO","BRINVUNDMED")

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XPRINT.BMP";
            TOP PROMPT "Imprimir"; 
            ACTION  oINVUNDMED:IMPRIMIR()

      oBtn:cToolTip:="Imprimir"

     oINVUNDMED:oBtnPrint:=oBtn

   ENDIF

IF nWidth>700


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\QUERY.BMP";
          ACTION oINVUNDMED:BRWQUERY()

   oBtn:cToolTip:="Imprimir"

ENDIF




   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          TOP PROMPT "Primero"; 
          ACTION  (oINVUNDMED:oBrw:GoTop(),oINVUNDMED:oBrw:Setfocus())

IF nWidth>800 .OR. nWidth=0

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xSIG.BMP";
          TOP PROMPT "Avance"; 
          ACTION  (oINVUNDMED:oBrw:PageDown(),oINVUNDMED:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xANT.BMP";
          TOP PROMPT "Anterior"; 
          ACTION  (oINVUNDMED:oBrw:PageUp(),oINVUNDMED:oBrw:Setfocus())

ENDIF


  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          TOP PROMPT "Ultimo"; 
          ACTION  (oINVUNDMED:oBrw:GoBottom(),oINVUNDMED:oBrw:Setfocus())



   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          TOP PROMPT "Cerrar"; 
          ACTION  oINVUNDMED:Close()

  oINVUNDMED:oBrw:SetColor(0,oINVUNDMED:nClrPane1)

  EVAL(oINVUNDMED:oBrw:bChange)
 
  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  oINVUNDMED:oBar:=oBar

  oBar:SetSize(NIL,95,.T.)

  @ 68,15 SAY " "+oINVUNDMED:cUndMed  BORDER OF oBar SIZE 40,20 PIXEL COLOR oDp:nClrLabelText,oDp:nClrLabelPane FONT oFont

  @ 68,55 SAY " "+SQLGET("DPUNDMED","UND_DESCRI","UND_CODIGO"+GetWhere("=",oINVUNDMED:cUndMed));
          BORDER OF oBar SIZE 320,20 PIXEL COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont

RETURN .T.

/*
// Evento para presionar CLICK
*/
FUNCTION RUNCLICK()


RETURN .T.


/*
// Imprimir
*/
FUNCTION IMPRIMIR()
  LOCAL oRep,cWhere

  oRep:=REPORTE("BRINVUNDMED",cWhere)
  oRep:cSql  :=oINVUNDMED:cSql
  oRep:cTitle:=oINVUNDMED:cTitle

RETURN .T.

FUNCTION LEEFECHAS()
  LOCAL nPeriodo:=oINVUNDMED:oPeriodo:nAt,cWhere

  oINVUNDMED:nPeriodo:=nPeriodo


  IF oINVUNDMED:oPeriodo:nAt=LEN(oINVUNDMED:oPeriodo:aItems)

     oINVUNDMED:oDesde:ForWhen(.T.)
     oINVUNDMED:oHasta:ForWhen(.T.)
     oINVUNDMED:oBtn  :ForWhen(.T.)

     DPFOCUS(oINVUNDMED:oDesde)

  ELSE

     oINVUNDMED:aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)

     oINVUNDMED:oDesde:VarPut(oINVUNDMED:aFechas[1] , .T. )
     oINVUNDMED:oHasta:VarPut(oINVUNDMED:aFechas[2] , .T. )

     oINVUNDMED:dDesde:=oINVUNDMED:aFechas[1]
     oINVUNDMED:dHasta:=oINVUNDMED:aFechas[2]

     cWhere:=oINVUNDMED:HACERWHERE(oINVUNDMED:dDesde,oINVUNDMED:dHasta,oINVUNDMED:cWhere,.T.)

     oINVUNDMED:LEERDATA(cWhere,oINVUNDMED:oBrw,oINVUNDMED:cServer)

  ENDIF

  oINVUNDMED:SAVEPERIODO()

RETURN .T.


FUNCTION HACERWHERE(dDesde,dHasta,cWhere_,lRun)
   LOCAL cWhere:=""

   DEFAULT lRun:=.F.

   // Campo fecha no puede estar en la nueva clausula
   IF ""$cWhere
     RETURN ""
   ENDIF

   IF !Empty(dDesde)
       
   ELSE
     IF !Empty(dHasta)
       
     ENDIF
   ENDIF


   IF !Empty(cWhere_)
      cWhere:=cWhere + IIF( Empty(cWhere),""," AND ") +cWhere_
   ENDIF

   IF lRun

     IF !Empty(oINVUNDMED:cWhereQry)
       cWhere:=cWhere + oINVUNDMED:cWhereQry
     ENDIF

     oINVUNDMED:LEERDATA(cWhere,oINVUNDMED:oBrw,oINVUNDMED:cServer)

   ENDIF


RETURN cWhere


FUNCTION LEERDATA(cWhere,oBrw,cServer)
   LOCAL aData:={},aTotal:={},oCol,cSql,aLines:={}
   LOCAL oDb

   DEFAULT cWhere:=""

   IF !Empty(cServer)

     IF !EJECUTAR("DPSERVERDBOPEN",cServer)
        RETURN .F.
     ENDIF

     oDb:=oDp:oDb

   ENDIF


   cSql:=" SELECT IME_CODIGO,INV_DESCRI,IME_PRESEN,IME_CANTID,IME_VENTA,IME_COMPRA,IME_VOLUME,IME_MEDPRE,IME_SIGNO"+;
         " FROM DPINVMED "+;
         " LEFT JOIN DPINV ON IME_CODIGO=INV_CODIGO"+;
         IF(Empty(cWhere),""," WHERE ")+cWhere+;
         " ORDER BY IME_CODIGO"+;
         ""

   IF Empty(cWhere)
     cSql:=STRTRAN(cSql,"<WHERE>","")
   ELSE
     cSql:=STRTRAN(cSql,"<WHERE>"," WHERE "+cWhere)
   ENDIF

   cSql:=EJECUTAR("WHERE_VAR",cSql)

   oDp:lExcluye:=.T.

   DPWRITE("TEMP\BRINVUNDMED.SQL",cSql)

   aData:=ASQL(cSql,oDb)

   oDp:cWhere:=cWhere


   IF EMPTY(aData)
      aData:=EJECUTAR("SQLARRAYEMPTY",cSql,oDb)
//    AADD(aData,{'','','',0,'','',0,0,''})
   ENDIF

   IF ValType(oBrw)="O"

      oINVUNDMED:cSql   :=cSql
      oINVUNDMED:cWhere_:=cWhere

      aTotal:=ATOTALES(aData)

      oBrw:aArrayData:=ACLONE(aData)
      oBrw:nArrayAt  :=1
      oBrw:nRowSel   :=1

      
      oCol:=oINVUNDMED:oBrw:aCols[4]
         oCol:cFooter      :=FDP(aTotal[4],'999,999,999.99')
      oCol:=oINVUNDMED:oBrw:aCols[7]
         oCol:cFooter      :=FDP(aTotal[7],'999,999,999.99')

      oINVUNDMED:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))
   
      oBrw:Refresh(.T.)
      AEVAL(oINVUNDMED:oBar:aControls,{|o,n| o:ForWhen(.T.)})

      oINVUNDMED:SAVEPERIODO()

   ENDIF

RETURN aData


FUNCTION SAVEPERIODO()
  LOCAL cFileMem:="USER\BRINVUNDMED.MEM",V_nPeriodo:=oINVUNDMED:nPeriodo
  LOCAL V_dDesde:=oINVUNDMED:dDesde
  LOCAL V_dHasta:=oINVUNDMED:dHasta

  SAVE TO (cFileMem) ALL LIKE "V_*"

RETURN .T.

/*
// Permite Crear Filtros para las Búquedas
*/
FUNCTION BRWQUERY()
     EJECUTAR("BRWQUERY",oINVUNDMED)
RETURN .T.

/*
// Ejecución Cambio de Linea 
*/
FUNCTION BRWCHANGE()
RETURN NIL

/*
// Refrescar Browse
*/
FUNCTION BRWREFRESCAR()
    LOCAL cWhere


    IF Type("oINVUNDMED")="O" .AND. oINVUNDMED:oWnd:hWnd>0

      cWhere:=" "+IIF(!Empty(oINVUNDMED:cWhere_),oINVUNDMED:cWhere_,oINVUNDMED:cWhere)
      cWhere:=STRTRAN(cWhere," WHERE ","")


      oINVUNDMED:LEERDATA(oINVUNDMED:cWhere_,oINVUNDMED:oBrw,oINVUNDMED:cServer)
      oINVUNDMED:oWnd:Show()
      oINVUNDMED:oWnd:Maximize()

    ENDIF

RETURN NIL

/*
// Genera Correspondencia Masiva
*/

FUNCTION BRWRESTOREPAR()
RETURN EJECUTAR("BRWRESTOREPAR",oINVUNDMED)

FUNCTION VERPRECIOS()
   LOCAL aLine  :=oINVUNDMED:oBrw:aArrayData[oINVUNDMED:oBrw:nArrayAt]
   LOCAL cCodigo:=aLine[1]
RETURN EJECUTAR("DPPRECIOS",aLine[1],aLine[2]) //,oINVUNDMED:cUndMed)
//,oDp:cPrecio,oInv:cUndMed,oDp:cMonedaPvP)

// EOF
