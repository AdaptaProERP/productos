// Programa   : BRDPSERXCLI
// Fecha/Hora : 05/06/2020 15:08:47
// Propósito  : "Seriales/Ticket  Egresados  y  Vinculadas con Clientes"
// Creado Por : Automáticamente por BRWMAKER
// Llamado por: <DPXBASE>
// Aplicación : Gerencia
// Tabla      : <TABLA>

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle,cSerial)
   LOCAL aData,aFechas,cFileMem:="USER\BRDPSERXCLI.MEM",V_nPeriodo:=4,cCodPar
   LOCAL V_dDesde:=CTOD(""),V_dHasta:=CTOD("")
   LOCAL cServer:=oDp:cRunServer
   LOCAL lConectar:=.F.

   oDp:cRunServer:=NIL

   IF Type("oDPSERXCLI")="O" .AND. oDPSERXCLI:oWnd:hWnd>0
      RETURN EJECUTAR("BRRUNNEW",oDPSERXCLI,GetScript())
   ENDIF


   IF !Empty(cServer)

     MsgRun("Conectando con Servidor "+cServer+" ["+ALLTRIM(SQLGET("DPSERVERBD","SBD_DOMINI","SBD_CODIGO"+GetWhere("=",cServer)))+"]",;
            "Por Favor Espere",{||lConectar:=EJECUTAR("DPSERVERDBOPEN",cServer)})

     IF !lConectar
        RETURN .F.
     ENDIF

   ENDIF


   cTitle:="Seriales/Ticket  Egresados  y  Vinculadas con Clientes" +IF(Empty(cTitle),"",cTitle)

   oDp:oFrm:=NIL

   IF FILE(cFileMem) .AND. nPeriodo=NIL
      RESTORE FROM (cFileMem) ADDI
      nPeriodo:=V_nPeriodo
   ENDIF

   DEFAULT cCodSuc :=oDp:cSucursal,;
           nPeriodo:=4,;
           dDesde  :=CTOD(""),;
           dHasta  :=CTOD("")


   DEFAULT cSerial :=SPACE(20)


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

   oDp:oFrm:=oDPSERXCLI

RETURN .T.


FUNCTION ViewData(aData,cTitle,cWhere_)
   LOCAL oBrw,oCol,aTotal:=ATOTALES(aData)
   LOCAL oFont,oFontB
   LOCAL aPeriodos:=ACLONE(oDp:aPeriodos)
   LOCAL aCoors:=GetCoors( GetDesktopWindow() )

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12
   DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD




   DpMdi(cTitle,"oDPSERXCLI","BRDPSERXCLI.EDT")
// oDPSERXCLI:CreateWindow(0,0,100,550)
   oDPSERXCLI:Windows(0,0,aCoors[3]-160,MIN(1042,aCoors[4]-10),.T.) // Maximizado



   oDPSERXCLI:cCodSuc  :=cCodSuc
   oDPSERXCLI:lMsgBar  :=.F.
   oDPSERXCLI:cPeriodo :=aPeriodos[nPeriodo]
   oDPSERXCLI:cCodSuc  :=cCodSuc
   oDPSERXCLI:nPeriodo :=nPeriodo
   oDPSERXCLI:cNombre  :=""
   oDPSERXCLI:dDesde   :=dDesde
   oDPSERXCLI:cServer  :=cServer
   oDPSERXCLI:dHasta   :=dHasta
   oDPSERXCLI:cWhere   :=cWhere
   oDPSERXCLI:cWhere_  :=cWhere_
   oDPSERXCLI:cWhereQry:=""
   oDPSERXCLI:cSql     :=oDp:cSql
   oDPSERXCLI:oWhere   :=TWHERE():New(oDPSERXCLI)
   oDPSERXCLI:cCodPar  :=cCodPar // Código del Parámetro
   oDPSERXCLI:lWhen    :=.T.
   oDPSERXCLI:cTextTit :="" // Texto del Titulo Heredado
   oDPSERXCLI:oDb      :=oDp:oDb
   oDPSERXCLI:cBrwCod  :="DPSERXCLI"
   oDPSERXCLI:lTmdi    :=.T.
   oDPSERXCLI:aHead    :={}
   oDPSERXCLI:cSerial  :=cSerial
   

   // Guarda los parámetros del Browse cuando cierra la ventana
   oDPSERXCLI:bValid   :={|| EJECUTAR("BRWSAVEPAR",oDPSERXCLI)}

   oDPSERXCLI:lBtnMenuBrw :=.F.
   oDPSERXCLI:lBtnSave    :=.F.
   oDPSERXCLI:lBtnCrystal :=.F.
   oDPSERXCLI:lBtnRefresh :=.F.
   oDPSERXCLI:lBtnHtml    :=.T.
   oDPSERXCLI:lBtnExcel   :=.T.
   oDPSERXCLI:lBtnPreview :=.T.
   oDPSERXCLI:lBtnQuery   :=.F.
   oDPSERXCLI:lBtnOptions :=.T.
   oDPSERXCLI:lBtnPageDown:=.T.
   oDPSERXCLI:lBtnPageUp  :=.T.
   oDPSERXCLI:lBtnFilters :=.T.
   oDPSERXCLI:lBtnFind    :=.T.

   oDPSERXCLI:nClrPane1:=16774636
   oDPSERXCLI:nClrPane2:=16769476

   oDPSERXCLI:nClrText :=0
   oDPSERXCLI:nClrText1:=0
   oDPSERXCLI:nClrText2:=0
   oDPSERXCLI:nClrText3:=0




   oDPSERXCLI:oBrw:=TXBrowse():New( IF(oDPSERXCLI:lTmdi,oDPSERXCLI:oWnd,oDPSERXCLI:oDlg ))
   oDPSERXCLI:oBrw:SetArray( aData, .F. )
   oDPSERXCLI:oBrw:SetFont(oFont)

   oDPSERXCLI:oBrw:lFooter     := .T.
   oDPSERXCLI:oBrw:lHScroll    := .T.
   oDPSERXCLI:oBrw:nHeaderLines:= 2
   oDPSERXCLI:oBrw:nDataLines  := 1
   oDPSERXCLI:oBrw:nFooterLines:= 1




   oDPSERXCLI:aData            :=ACLONE(aData)

   AEVAL(oDPSERXCLI:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

   

  oCol:=oDPSERXCLI:oBrw:aCols[1]
  oCol:cHeader      :='Serial'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oDPSERXCLI:oBrw:aArrayData ) } 
  oCol:nWidth       := 120

  oCol:=oDPSERXCLI:oBrw:aCols[2]
  oCol:cHeader      :='Código'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oDPSERXCLI:oBrw:aArrayData ) } 
  oCol:nWidth       := 60

  oCol:=oDPSERXCLI:oBrw:aCols[3]
  oCol:cHeader      :='Descripción'+CRLF+'Producto'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oDPSERXCLI:oBrw:aArrayData ) } 
  oCol:nWidth       := 120

  oCol:=oDPSERXCLI:oBrw:aCols[4]
  oCol:cHeader      :='Código'+CRLF+'Cliente'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oDPSERXCLI:oBrw:aArrayData ) } 
  oCol:nWidth       := 80

  oCol:=oDPSERXCLI:oBrw:aCols[5]
  oCol:cHeader      :='Nombre'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oDPSERXCLI:oBrw:aArrayData ) } 
  oCol:nWidth       := 480

  oCol:=oDPSERXCLI:oBrw:aCols[6]
  oCol:cHeader      :='Fecha'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oDPSERXCLI:oBrw:aArrayData ) } 
  oCol:nWidth       := 70

  oCol:=oDPSERXCLI:oBrw:aCols[7]
  oCol:cHeader      :='Tip.'+CRLF+'Doc'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oDPSERXCLI:oBrw:aArrayData ) } 
  oCol:nWidth       := 32

  oCol:=oDPSERXCLI:oBrw:aCols[8]
  oCol:cHeader      :='Número'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oDPSERXCLI:oBrw:aArrayData ) } 
  oCol:nWidth       := 80

   oDPSERXCLI:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))

   oDPSERXCLI:oBrw:bClrStd  := {|oBrw,nClrText,aLine|oBrw:=oDPSERXCLI:oBrw,aLine:=oBrw:aArrayData[oBrw:nArrayAt],;
                                                 nClrText:=oDPSERXCLI:nClrText,;
                                                 nClrText:=IF(.F.,nClrText,oDPSERXCLI:nClrText1),;
                                                 nClrText:=IF(.F.,nClrText,oDPSERXCLI:nClrText2),;
                                                 {nClrText,iif( oBrw:nArrayAt%2=0, oDPSERXCLI:nClrPane1, oDPSERXCLI:nClrPane2 ) } }

//   oDPSERXCLI:oBrw:bClrHeader            := {|| {0,14671839 }}
//   oDPSERXCLI:oBrw:bClrFooter            := {|| {0,14671839 }}

   oDPSERXCLI:oBrw:bClrHeader          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oDPSERXCLI:oBrw:bClrFooter          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

   oDPSERXCLI:oBrw:bLDblClick:={|oBrw|oDPSERXCLI:RUNCLICK() }

   oDPSERXCLI:oBrw:bChange:={||oDPSERXCLI:BRWCHANGE()}
   oDPSERXCLI:oBrw:CreateFromCode()


   oDPSERXCLI:oWnd:oClient := oDPSERXCLI:oBrw



   oDPSERXCLI:Activate({||oDPSERXCLI:ViewDatBar()})

   oDPSERXCLI:BRWRESTOREPAR()

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar()
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg:=IF(oDPSERXCLI:lTmdi,oDPSERXCLI:oWnd,oDPSERXCLI:oDlg)
   LOCAL nLin:=0
   LOCAL nWidth:=oDPSERXCLI:oBrw:nWidth()

   oDPSERXCLI:oBrw:GoBottom(.T.)
   oDPSERXCLI:oBrw:Refresh(.T.)

//   IF !File("FORMS\BRDPSERXCLI.EDT")
//     oDPSERXCLI:oBrw:Move(44,0,1042+50,460)
//   ENDIF

   DEFINE CURSOR oCursor HAND

   IF !oDp:lBtnText 
     DEFINE BUTTONBAR oBar SIZE 52-15,60-15+30 OF oDlg 3D CURSOR oCursor
   ELSE 
     DEFINE BUTTONBAR oBar SIZE oDp:nBtnWidth,oDp:nBarnHeight+6+25 OF oDlg 3D CURSOR oCursor 
   ENDIF 

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -10 BOLD

 // Emanager no Incluye consulta de Vinculos


   IF .F. .AND. Empty(oDPSERXCLI:cServer)

   oDPSERXCLI:oFontBtn   :=oFont    
   oDPSERXCLI:nClrPaneBar:=oDp:nGris
   oDPSERXCLI:oBrw:oLbx  :=oDPSERXCLI

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\VIEW.BMP";
          TOP PROMPT "Consulta"; 
          ACTION  EJECUTAR("BRWRUNLINK",oDPSERXCLI:oBrw,oDPSERXCLI:cSql)

     oBtn:cToolTip:="Consultar Vinculos"


   ENDIF


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CLIENTE.BMP",NIL,"BITMAPS\CLIENTE.BMP";
          TOP PROMPT "Cliente"; 
          ACTION  oDPSERXCLI:VERCLIENTES();
          WHEN !Empty(oDPSERXCLI:oBrw:aArrayData[1,1])
             
   oBtn:cToolTip:="Consultar Ficha del "+oDp:xDPCLIENTES


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PRODUCTO.BMP",NIL,"BITMAPS\PRODUCTOG.BMP";
          TOP PROMPT "Producto"; 
          ACTION  EJECUTAR("DPINV",0,oDPSERXCLI:oBrw:aArrayData[1,3]);
          WHEN !Empty(oDPSERXCLI:oBrw:aArrayData[1,1])
             
   oBtn:cToolTip:="Consultar Ficha del "+oDp:xDPINV


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          TOP PROMPT "Consulta"; 
          FILENAME "BITMAPS\VIEW.BMP",NIL,"BITMAPS\VIEWG.BMP";
          ACTION oDPSERXCLI:VERDOCUMENTO();
          WHEN !Empty(oDPSERXCLI:oBrw:aArrayData[1,1])
             
   oBtn:cToolTip:="Consultar Documento"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FORM.BMP",NIL,"BITMAPS\FACTURAVTAG.BMP";
          TOP PROMPT "Doc/Org"; 
          ACTION oDPSERXCLI:VERFACTURA();
          WHEN !Empty(oDPSERXCLI:oBrw:aArrayData[1,1])
             
   oBtn:cToolTip:="Consultar Documento"




/*
   IF Empty(oDPSERXCLI:cServer) .AND. !Empty(SQLGET("DPBRWLNK","EBR_CODIGO","EBR_CODIGO"+GetWhere("=","DPSERXCLI")))
*/

   IF ISSQLFIND("DPBRWLNKCONCAT","BRC_CODIGO"+GetWhere("=","DPSERXCLI"))

       DEFINE BUTTON oBtn;
       OF oBar;
       NOBORDER;
       FONT oFont;
       FILENAME "BITMAPS\XBROWSE.BMP";
       TOP PROMPT "Detalles"; 
       ACTION  EJECUTAR("BRWRUNBRWLINK",oDPSERXCLI:oBrw,"DPSERXCLI",oDPSERXCLI:cSql,oDPSERXCLI:nPeriodo,oDPSERXCLI:dDesde,oDPSERXCLI:dHasta,oDPSERXCLI)

       oBtn:cToolTip:="Ejecutar Browse Vinculado(s)"
       oDPSERXCLI:oBtnRun:=oBtn



       oDPSERXCLI:oBrw:bLDblClick:={||EVAL(oDPSERXCLI:oBtnRun:bAction) }


   ENDIF


/*
IF oDPSERXCLI:lBtnSave

      DEFINE BITMAP OF OUTLOOK oBRWMENURUN:oOut ;
             BITMAP "BITMAPS\XSAVE.BMP";
             PROMPT "Guardar Consulta";
             TOP PROMPT "Grabar"; 
             ACTION  EJECUTAR("DPBRWSAVE",oDPSERXCLI:oBrw,oDPSERXCLI:oFrm)
ENDIF
*/

IF oDPSERXCLI:lBtnMenuBrw

 DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\BRWMENU.BMP",NIL,"BITMAPS\BRWMENUG.BMP";
          TOP PROMPT "Menú"; 
          ACTION  (EJECUTAR("BRWBUILDHEAD",oDPSERXCLI),;
                  EJECUTAR("DPBRWMENURUN",oDPSERXCLI,oDPSERXCLI:oBrw,oDPSERXCLI:cBrwCod,oDPSERXCLI:cTitle,oDPSERXCLI:aHead));
          WHEN !Empty(oDPSERXCLI:oBrw:aArrayData[1,1])

   oBtn:cToolTip:="Menú de Opciones"

ENDIF


IF oDPSERXCLI:lBtnFind

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
          TOP PROMPT "Buscar"; 
          ACTION  EJECUTAR("BRWSETFIND",oDPSERXCLI:oBrw)

   oBtn:cToolTip:="Buscar"

ENDIF

IF oDPSERXCLI:lBtnFilters

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
          MENU EJECUTAR("BRBTNMENUFILTER",oDPSERXCLI:oBrw,oDPSERXCLI);
          TOP PROMPT "Filtrar"; 
          ACTION  EJECUTAR("BRWSETFILTER",oDPSERXCLI:oBrw)

   oBtn:cToolTip:="Filtrar Registros"

ENDIF

IF oDPSERXCLI:lBtnOptions

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\OPTIONS.BMP",NIL,"BITMAPS\OPTIONSG.BMP";
          TOP PROMPT "Opciones"; 
          ACTION  EJECUTAR("BRWSETOPTIONS",oDPSERXCLI:oBrw);
          WHEN LEN(oDPSERXCLI:oBrw:aArrayData)>1

   oBtn:cToolTip:="Filtrar según Valores Comunes"

ENDIF

IF oDPSERXCLI:lBtnRefresh

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\REFRESH.BMP";
          TOP PROMPT "Refrescar"; 
          ACTION  oDPSERXCLI:BRWREFRESCAR()

   oBtn:cToolTip:="Refrescar"

ENDIF

IF oDPSERXCLI:lBtnCrystal

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CRYSTAL.BMP";
          TOP PROMPT "Crystal"; 
          ACTION  EJECUTAR("BRWTODBF",oDPSERXCLI)

   oBtn:cToolTip:="Visualizar Mediante Crystal Report"

ENDIF

IF oDPSERXCLI:lBtnExcel

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\EXCEL.BMP";
            TOP PROMPT "Excel"; 
            ACTION  (EJECUTAR("BRWTOEXCEL",oDPSERXCLI:oBrw,oDPSERXCLI:cTitle,oDPSERXCLI:cNombre))

     oBtn:cToolTip:="Exportar hacia Excel"

     oDPSERXCLI:oBtnXls:=oBtn

ENDIF

IF oDPSERXCLI:lBtnHtml

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\html.BMP";
          TOP PROMPT "Html"; 
          ACTION  (oDPSERXCLI:HTMLHEAD(),EJECUTAR("BRWTOHTML",oDPSERXCLI:oBrw,NIL,oDPSERXCLI:cTitle,oDPSERXCLI:aHead))

   oBtn:cToolTip:="Generar Archivo html"

   oDPSERXCLI:oBtnHtml:=oBtn

ENDIF


IF oDPSERXCLI:lBtnPreview

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PREVIEW.BMP";
          TOP PROMPT "Preview"; 
          ACTION  (EJECUTAR("BRWPREVIEW",oDPSERXCLI:oBrw))

   oBtn:cToolTip:="Previsualización"

   oDPSERXCLI:oBtnPreview:=oBtn

ENDIF

   IF ISSQLGET("DPREPORTES","REP_CODIGO","BRDPSERXCLI")

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XPRINT.BMP";
            TOP PROMPT "Imprimir"; 
            ACTION  oDPSERXCLI:IMPRIMIR()

      oBtn:cToolTip:="Imprimir"

     oDPSERXCLI:oBtnPrint:=oBtn

   ENDIF

IF oDPSERXCLI:lBtnQuery


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\QUERY.BMP";
          ACTION oDPSERXCLI:BRWQUERY()

   oBtn:cToolTip:="Imprimir"

ENDIF




   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          TOP PROMPT "Primero"; 
          ACTION  (oDPSERXCLI:oBrw:GoTop(),oDPSERXCLI:oBrw:Setfocus())

IF nWidth>800 .OR. nWidth=0

   IF oDPSERXCLI:lBtnPageDown

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\xSIG.BMP";
              TOP PROMPT "Avance"; 
              ACTION  (oDPSERXCLI:oBrw:PageDown(),oDPSERXCLI:oBrw:Setfocus())
  ENDIF

  IF  oDPSERXCLI:lBtnPageUp

    DEFINE BUTTON oBtn;
           OF oBar;
           NOBORDER;
           FONT oFont;
           FILENAME "BITMAPS\xANT.BMP";
           TOP PROMPT "Anterior"; 
           ACTION  (oDPSERXCLI:oBrw:PageUp(),oDPSERXCLI:oBrw:Setfocus())

  ENDIF

ENDIF


  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          TOP PROMPT "Ultimo"; 
          ACTION  (oDPSERXCLI:oBrw:GoBottom(),oDPSERXCLI:oBrw:Setfocus())



   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          TOP PROMPT "Cerrar"; 
          ACTION  oDPSERXCLI:Close()

  oDPSERXCLI:oBrw:SetColor(0,oDPSERXCLI:nClrPane1)

  EVAL(oDPSERXCLI:oBrw:bChange)

  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  oDPSERXCLI:oBar:=oBar

  oDPSERXCLI:SETBTNBAR(45,45,oBar)

  DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -09 BOLD

  nLin:=682

  // Controles se Inician luego del Ultimo Boton
  nLin:=32+320
//  AEVAL(oBar:aControls,{|o,n|nLin:=nLin+o:nWidth() })

  //
  // Campo : Periodo
  //

  @ 08+55, nLin COMBOBOX oDPSERXCLI:oPeriodo  VAR oDPSERXCLI:cPeriodo ITEMS aPeriodos;
                SIZE 100,200;
                PIXEL;
                OF oBar;
                FONT oFont;
                ON CHANGE oDPSERXCLI:LEEFECHAS();
                WHEN oDPSERXCLI:lWhen


  ComboIni(oDPSERXCLI:oPeriodo )

  @ 08+55, nLin+103 BUTTON oDPSERXCLI:oBtn PROMPT " < " SIZE 27,24;
                 FONT oFont;
                 PIXEL;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oDPSERXCLI:oPeriodo:nAt,oDPSERXCLI:oDesde,oDPSERXCLI:oHasta,-1),;
                         EVAL(oDPSERXCLI:oBtn:bAction));
                WHEN oDPSERXCLI:lWhen


  @ 08+55, nLin+130 BUTTON oDPSERXCLI:oBtn PROMPT " > " SIZE 27,24;
                 FONT oFont;
                 PIXEL;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oDPSERXCLI:oPeriodo:nAt,oDPSERXCLI:oDesde,oDPSERXCLI:oHasta,+1),;
                         EVAL(oDPSERXCLI:oBtn:bAction));
                WHEN oDPSERXCLI:lWhen


  @ 08+55, nLin+160 BMPGET oDPSERXCLI:oDesde  VAR oDPSERXCLI:dDesde;
                PICTURE "99/99/9999";
                PIXEL;
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oDPSERXCLI:oDesde ,oDPSERXCLI:dDesde);
                SIZE 76-1,24;
                OF   oBar;
                WHEN oDPSERXCLI:oPeriodo:nAt=LEN(oDPSERXCLI:oPeriodo:aItems) .AND. oDPSERXCLI:lWhen ;
                FONT oFont

   oDPSERXCLI:oDesde:cToolTip:="F6: Calendario"

  @ 08+55, nLin+252 BMPGET oDPSERXCLI:oHasta  VAR oDPSERXCLI:dHasta;
                PICTURE "99/99/9999";
                PIXEL;
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oDPSERXCLI:oHasta,oDPSERXCLI:dHasta);
                SIZE 76-1,24;
                WHEN oDPSERXCLI:oPeriodo:nAt=LEN(oDPSERXCLI:oPeriodo:aItems) .AND. oDPSERXCLI:lWhen ;
                OF oBar;
                FONT oFont

   oDPSERXCLI:oHasta:cToolTip:="F6: Calendario"

   @ 08+55, nLin+345 BUTTON oDPSERXCLI:oBtn PROMPT " > " SIZE 27,24;
               FONT oFont;
               OF oBar;
               PIXEL;
               WHEN oDPSERXCLI:oPeriodo:nAt=LEN(oDPSERXCLI:oPeriodo:aItems);
               ACTION oDPSERXCLI:HACERWHERE(oDPSERXCLI:dDesde,oDPSERXCLI:dHasta,oDPSERXCLI:cWhere,.T.);
               WHEN oDPSERXCLI:lWhen

  BMPGETBTN(oBar,oFont,13)

  AEVAL(oBar:aControls,{|o|o:ForWhen(.T.)})

  oDPSERXCLI:SETBTNBAR(52,60,oBar)

  DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 BOLD

  @ 50+12,10 SAY "# Buscar" ;
    SIZE 60,19 PIXEL COLOR CLR_WHITE,16744448 OF oBar FONT oFont BORDER 

  @ 50+12,72 BMPGET oDPSERXCLI:oSerial VAR oDPSERXCLI:cSerial;
                  VALID EJECUTAR("BRDPSERXCLIFIND",oDPSERXCLI,oDPSERXCLI:cSerial);
                  NAME "BITMAPS\FIND2.bmp"; 
                  ACTION EJECUTAR("BRDPSERXCLIFIND",oDPSERXCLI,oDPSERXCLI:cSerial); 
                  WHEN .T.;
                  SIZE 190,20 OF oBar PIXEL UPDATE

  oDPSERXCLI:oSerial:bKeyDown:={|nKey| IF(nKey=13, EJECUTAR("BRDPSERXCLIFIND",oDPSERXCLI,oDPSERXCLI:cSerial),NIL)}
  
  BMPGETBTN(oDPSERXCLI:oSerial,oFont,20)

RETURN .T.

/*
// Evento para presionar CLICK
*/
FUNCTION RUNCLICK()

? "RUNCLI"


RETURN .T.


/*
// Imprimir
*/
FUNCTION IMPRIMIR()
  LOCAL oRep,cWhere

  oRep:=REPORTE("BRDPSERXCLI",cWhere)
  oRep:cSql  :=oDPSERXCLI:cSql
  oRep:cTitle:=oDPSERXCLI:cTitle

RETURN .T.

FUNCTION LEEFECHAS()
  LOCAL nPeriodo:=oDPSERXCLI:oPeriodo:nAt,cWhere

  oDPSERXCLI:nPeriodo:=nPeriodo


  IF oDPSERXCLI:oPeriodo:nAt=LEN(oDPSERXCLI:oPeriodo:aItems)

     oDPSERXCLI:oDesde:ForWhen(.T.)
     oDPSERXCLI:oHasta:ForWhen(.T.)
     oDPSERXCLI:oBtn  :ForWhen(.T.)

     DPFOCUS(oDPSERXCLI:oDesde)

  ELSE

     oDPSERXCLI:aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)

     oDPSERXCLI:oDesde:VarPut(oDPSERXCLI:aFechas[1] , .T. )
     oDPSERXCLI:oHasta:VarPut(oDPSERXCLI:aFechas[2] , .T. )

     oDPSERXCLI:dDesde:=oDPSERXCLI:aFechas[1]
     oDPSERXCLI:dHasta:=oDPSERXCLI:aFechas[2]

     cWhere:=oDPSERXCLI:HACERWHERE(oDPSERXCLI:dDesde,oDPSERXCLI:dHasta,oDPSERXCLI:cWhere,.T.)

     oDPSERXCLI:LEERDATA(cWhere,oDPSERXCLI:oBrw,oDPSERXCLI:cServer)

  ENDIF

  oDPSERXCLI:SAVEPERIODO()

RETURN .T.


FUNCTION HACERWHERE(dDesde,dHasta,cWhere_,lRun)
   LOCAL cWhere:=""

   DEFAULT lRun:=.F.

   // Campo fecha no puede estar en la nueva clausula
   IF "DPMOVINV.MOV_FECHA"$cWhere
     RETURN ""
   ENDIF

   IF !Empty(dDesde)
       cWhere:=GetWhereAnd('DPMOVINV.MOV_FECHA',dDesde,dHasta)
   ELSE
     IF !Empty(dHasta)
       cWhere:=GetWhereAnd('DPMOVINV.MOV_FECHA',dDesde,dHasta)
     ENDIF
   ENDIF


   IF !Empty(cWhere_)
      cWhere:=cWhere + IIF( Empty(cWhere),""," AND ") +cWhere_
   ENDIF

   IF lRun

     IF !Empty(oDPSERXCLI:cWhereQry)
       cWhere:=cWhere + oDPSERXCLI:cWhereQry
     ENDIF

     oDPSERXCLI:LEERDATA(cWhere,oDPSERXCLI:oBrw,oDPSERXCLI:cServer)

   ENDIF


RETURN cWhere


FUNCTION LEERDATA(cWhere,oBrw,cServer)
   LOCAL aData:={},aTotal:={},oCol,cSql,aLines:={}
   LOCAL oDb
   LOCAL nAt,nRowSel

   DEFAULT cWhere:=""

   IF !Empty(cServer)

     IF !EJECUTAR("DPSERVERDBOPEN",cServer)
        RETURN .F.
     ENDIF

     oDb:=oDp:oDb

   ENDIF

   cWhere:=IIF(Empty(cWhere),"",ALLTRIM(cWhere))

   IF !Empty(cWhere) .AND. LEFT(cWhere,5)="WHERE"
      cWhere:=SUBS(cWhere,6,LEN(cWhere))
   ENDIF

   cSql:=" SELECT "+;
          " MSR_SERIAL,"+;
          " MOV_CODIGO,"+;
          " INV_DESCRI,"+;
          " MOV_CODCTA,"+;
          " CLI_NOMBRE,"+;
          " MOV_FECHA,"+;
          " MSR_TIPDOC,"+;
          " MSR_NUMDOC"+;
          " FROM "+;
          " DPMOVSERIAL  "+;
          " INNER JOIN DPMOVINV   ON MOV_CODSUC=MSR_CODSUC AND MOV_CODALM=MSR_CODALM AND MOV_TIPDOC=MSR_TIPDOC AND MOV_CODCTA=MSR_CODCTA AND MOV_DOCUME=MSR_NUMDOC AND MOV_ITEM=MSR_ITEM   "+;
          " INNER JOIN DPCLIENTES ON CLI_CODIGO=MOV_CODCTA  "+;
          " INNER JOIN DPINV      ON INV_CODIGO=MOV_CODIGO  "+;
          " WHERE "+cWhere+IIF(Empty(cWhere),""," AND ")+" MOV_CODSUC=&oDp:cSucursal AND MOV_INVACT=1 AND (MOV_CONTAB<0 OR MOV_FISICO<0 OR MOV_LOGICO<0)"+;
""

   IF Empty(cWhere)
     cSql:=STRTRAN(cSql,"<WHERE>","")
   ELSE
     cSql:=STRTRAN(cSql,"<WHERE>"," WHERE "+cWhere)
   ENDIF

   cSql:=EJECUTAR("WHERE_VAR",cSql)

   oDp:lExcluye:=.T.

   DPWRITE("TEMP\BRDPSERXCLI.SQL",cSql)

   aData:=ASQL(cSql,oDb)

   oDp:cWhere:=cWhere


   IF EMPTY(aData)
      aData:=EJECUTAR("SQLARRAYEMPTY",cSql,oDb)
//    AADD(aData,{'','','','','',CTOD(""),'',''})
   ENDIF

   

   IF ValType(oBrw)="O"

      oDPSERXCLI:cSql   :=cSql
      oDPSERXCLI:cWhere_:=cWhere

      aTotal:=ATOTALES(aData)

      oBrw:aArrayData:=ACLONE(aData)
      // oBrw:nArrayAt  :=1
      // oBrw:nRowSel   :=1

      // JN 15/03/2020 Sustituido por BRWCALTOTALES
/*
      // 
*/
      EJECUTAR("BRWCALTOTALES",oBrw,.F.)

      // oDPSERXCLI:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))

      // oBrw:Refresh(.T.)

      nAt    :=oBrw:nArrayAt
      nRowSel:=oBrw:nRowSel

      oBrw:Refresh(.F.)
      oBrw:nArrayAt  :=MIN(nAt,LEN(aData))
      oBrw:nRowSel   :=MIN(nRowSel,oBrw:nRowSel)
      AEVAL(oDPSERXCLI:oBar:aControls,{|o,n| o:ForWhen(.T.)})

      oDPSERXCLI:SAVEPERIODO()

   ENDIF

RETURN aData


FUNCTION SAVEPERIODO()
  LOCAL cFileMem:="USER\BRDPSERXCLI.MEM",V_nPeriodo:=oDPSERXCLI:nPeriodo
  LOCAL V_dDesde:=oDPSERXCLI:dDesde
  LOCAL V_dHasta:=oDPSERXCLI:dHasta

  SAVE TO (cFileMem) ALL LIKE "V_*"

RETURN .T.

/*
// Permite Crear Filtros para las Búquedas
*/
FUNCTION BRWQUERY()
     EJECUTAR("BRWQUERY",oDPSERXCLI)
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


    IF Type("oDPSERXCLI")="O" .AND. oDPSERXCLI:oWnd:hWnd>0

      cWhere:=" "+IIF(!Empty(oDPSERXCLI:cWhere_),oDPSERXCLI:cWhere_,oDPSERXCLI:cWhere)
      cWhere:=STRTRAN(cWhere," WHERE ","")

      oDPSERXCLI:LEERDATA(oDPSERXCLI:cWhere_,oDPSERXCLI:oBrw,oDPSERXCLI:cServer)
      oDPSERXCLI:oWnd:Show()
      oDPSERXCLI:oWnd:Restore()

    ENDIF

RETURN NIL


FUNCTION BTNMENU(nOption,cOption)

   IF nOption=1
   ENDIF

RETURN .T.

FUNCTION HTMLHEAD()

   oDPSERXCLI:aHead:=EJECUTAR("HTMLHEAD",oDPSERXCLI)

// Ejemplo para Agregar mas Parámetros
//   AADD(oDOCPROISLR:aHead,{"Consulta",oDOCPROISLR:oWnd:cTitle})

RETURN

// Restaurar Parametros
FUNCTION BRWRESTOREPAR()
  EJECUTAR("BRWRESTOREPAR",oDPSERXCLI)
RETURN .T.


FUNCTION VERCLIENTES()
   LOCAL cCodCli :=oDPSERXCLI:oBrw:aArrayData[oDPSERXCLI:oBrw:nArrayAt,4]

   EJECUTAR("DPCLIENTESCON",NIL,cCodCli)

RETURN .T.

FUNCTION VERDOCUMENTO()
   LOCAL cCodigo :=oDPSERXCLI:oBrw:aArrayData[oDPSERXCLI:oBrw:nArrayAt,4]
   LOCAL cTipDoc :=oDPSERXCLI:oBrw:aArrayData[oDPSERXCLI:oBrw:nArrayAt,7]
   LOCAL cNumero :=oDPSERXCLI:oBrw:aArrayData[oDPSERXCLI:oBrw:nArrayAt,8]

// oFrm,cCodSuc,cTipDoc,cNumero,cCodigo
   EJECUTAR("DPDOCCLIFAVCON",NIL,oDPSERXCLI:cCodSuc,cTipDoc,cNumero,cCodigo)

RETURN .T.

FUNCTION VERFACTURA()
   LOCAL cCodigo :=oDPSERXCLI:oBrw:aArrayData[oDPSERXCLI:oBrw:nArrayAt,4]
   LOCAL cTipDoc :=oDPSERXCLI:oBrw:aArrayData[oDPSERXCLI:oBrw:nArrayAt,7]
   LOCAL cNumero :=oDPSERXCLI:oBrw:aArrayData[oDPSERXCLI:oBrw:nArrayAt,8]

RETURN EJECUTAR("VERDOCCLI",oDp:cSucursal,cTipDoc,cCodigo,cNumero,"D")

FUNCTION BUSCAR()
   LOCAL cSerial:=ALLTRIM(oDPSERXCLI:cSerial)
   LOCAL nAt:=ASCAN(oDPSERXCLI:oBrw:aArrayData,{|a,n| cSerial=a[1] })

   IF nAt>0
     oDPSERXCLI:oBrw:nArrayAt:=nAt
     oDPSERXCLI:oBrw:Refresh(.F.)
   ENDIF
  

RETURN .T.

// EOF

