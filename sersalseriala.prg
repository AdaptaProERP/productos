// Programa   : SERSALSERIALA
// Fecha/Hora : 10/08/2023 15:24:20
// Propósito  : Entrada de Seriales Automotriz
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oGrid)
   LOCAL cWhere:="",cCodSuc,nPeriodo,dDesde,dHasta,cTitle,cCodigo:="",nOption:=0,cCodAlm:=""
   LOCAL aData:={},oCol,cSql,dFecha:=oDp:dFecha,aExiste,cTitle:=""
   LOCAL lSerial:=.F.

   IF ValType(oGrid)="O"

// JN 20/11/2023 , por no tener almancen no opera
//      IF oGrid:oBrw:nColSel<>2
//         RETURN ACLONE(oGrid:aSeriales)
//      ENDIF

      nOption:=oGrid:nOption
      cCodigo:=oGrid:MOV_CODIGO
      cCodAlm:=oGrid:MOV_CODALM
      cCodSuc:=oGrid:MOV_CODSUC
      dFecha :=oGrid:oHead:DOC_FECHA

      IF !Empty(oGrid:aSeriales)
         aData  :=ACLONE(oGrid:aSeriales)
         lSerial:=.T.
      ENDIF

      IF nOption=3 .AND. Empty(oGrid:aSeriales)

         aData:=ASQL(" SELECT "+;
                     " MSR_SERIAL AS SERIALM,"+;
                     " MSR_LOTE   AS SERIALC,"+;
                     " MSR_CODTAR AS COLOR,"+;
                     " MSR_ORDPRO AS PLACA,"+;
                     " MSR_CANEMP AS ANO  ,"+;
                     " 1          AS ACTIVO "+;
                     " FROM DPMOVSERIAL WHERE "+;
                     " MSR_CODSUC"+GetWhere("=",oGrid:MOV_CODSUC)+" AND "+;
                     " MSR_CODALM"+GetWhere("=",oGrid:MOV_CODALM)+" AND "+;
                     " MSR_TIPDOC"+GetWhere("=",oGrid:MOV_TIPDOC)+" AND "+;
                     " MSR_NUMDOC"+GetWhere("=",oGrid:MOV_DOCUME)+" AND "+;
                     " MSR_CODCTA"+GetWhere("=",oGrid:MOV_CODCTA)+" AND "+;
                     " MSR_ITEM"  +GetWhere("=",oGrid:MOV_ITEM  )+;
                     "",.T.)

      ENDIF

   ENDIF

   aExiste:=ACLONE(oGrid:aSeriales)

   IF !lSerial
     AEVAL(aData,{|a,n| AADD(aExiste,ACLONE(a))})
   ENDIF

   IF Empty(aExiste) .OR. nOption=3 

     cSql:=" SELECT "+;
           " MSR_SERIAL AS SERIALM,"+;
           " MSR_LOTE   AS SERIALC,"+;
           " MSR_CODTAR AS COLOR  ,"+;
           " MSR_ORDPRO AS PLACA  ,"+;
           " MSR_CANEMP AS ANO    ,"+;
           " 0          AS ACTIVO  "+;
           " FROM DPMOVSERIAL "+;
           " INNER JOIN DPMOVINV ON MSR_CODSUC=MOV_CODSUC AND "+;
           "                        MSR_CODALM=MOV_CODALM AND "+;
           "                        MSR_TIPDOC=MOV_TIPDOC AND "+;
           "                        MSR_NUMDOC=MOV_DOCUME AND "+;
           "                        MSR_CODCTA=MOV_CODCTA AND "+;
           "                        MSR_ITEM  =MOV_ITEM       "+;
           " WHERE MOV_CODIGO"+GetWhere("=",cCodigo)+;
           "   AND MOV_CODSUC"+GetWhere("=",cCodSuc)+;
           "   AND MOV_CODALM"+GetWhere("=",cCodAlm)+;
           "   AND (MOV_FECHA "+GetWhere("<=",dFecha)+cWhere+") AND MOV_INVACT<>0 "+;
           " GROUP BY MSR_SERIAL "+;
           " HAVING SUM(MOV_FISICO) > 0 "
           " ORDER BY MSR_SERIAL "

      aExiste:=ASQL(cSql)

      IF nOption=3 .AND. Empty(oGrid:aSeriales)
         AEVAL(aData,{|a,n| AADD(aExiste,ACLONE(a))})
      ENDIF

   ENDIF

   IF Empty(aExiste)
      MensajeErr("no hay Seriales Disponibles para el Código "+cCodigo,"Información no Encontrada")
      RETURN .F.
   ENDIF

   aData:=ViewData(aExiste,cTitle,"")

   oGrid:aSeriales:=ACLONE(aData)
//   oDp:oFrm:=oSERSALSERIALA

RETURN aData

FUNCTION ViewData(aData,cTitle,cWhere_)
   LOCAL oBrw,oCol,aTotal:=ATOTALES(aData)
   LOCAL oFont,oFontB
   LOCAL aPeriodos:=ACLONE(oDp:aPeriodos)
   LOCAL aCoors   :=GetCoors( GetDesktopWindow() )

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12
   DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD

   DPEDIT():New(cTitle,"BRSERSALSERIALA.EDT","oSERSALSERIALA",.F.,.T.)

   oSERSALSERIALA:CreateWindow(NIL,NIL,NIL,aCoors[3]-160,MIN(784,aCoors[4]-10))

   oSERSALSERIALA:cCodSuc  :=cCodSuc
   oSERSALSERIALA:lMsgBar  :=.F.
   oSERSALSERIALA:lMdi     :=.F.
// oSERSALSERIALA:cPeriodo :=aPeriodos[nPeriodo]
   oSERSALSERIALA:cCodSuc  :=cCodSuc
// oSERSALSERIALA:nPeriodo :=nPeriodo
   oSERSALSERIALA:cNombre  :=""
// oSERSALSERIALA:dDesde   :=dDesde
// oSERSALSERIALA:cServer  :=cServer
// oSERSALSERIALA:dHasta   :=dHasta
// oSERSALSERIALA:cWhere   :=cWhere
// oSERSALSERIALA:cWhere_  :=cWhere_
   oSERSALSERIALA:cWhereQry:=""
   oSERSALSERIALA:cSql     :=oDp:cSql
   oSERSALSERIALA:oWhere   :=TWHERE():New(oSERSALSERIALA)
   oSERSALSERIALA:cCodPar  :=cCodPar // Código del Parámetro
   oSERSALSERIALA:lWhen    :=.T.
   oSERSALSERIALA:cTextTit :="" // Texto del Titulo Heredado
   oSERSALSERIALA:oDb      :=oDp:oDb
   oSERSALSERIALA:cBrwCod  :="SERSALSERIALA"
   oSERSALSERIALA:lTmdi    :=.T.
   oSERSALSERIALA:aHead    :={}
   oSERSALSERIALA:lBarDef   :=.T. // Activar Modo Diseño.
// oSERSALSERIALA:aColor    :=ATABLE("SELECT COL_CODIGO FROM DPCOLORES WHERE COL_ACTIVO=1")
   oSERSALSERIALA:INV_CODIGO:=cCodigo
// oSERSALSERIALA:oGrid     :=oGrid
   oSERSALSERIALA:lSave     :=.F. // guardar
   oSERSALSERIALA:aData     :=ACLONE(aData) // Data Original

//   IF Empty(oSERSALSERIALA:aColor )
//      AADD(oSERSALSERIALA:aColor,"Indefinido")
//   ENDIF

   // Guarda los parámetros del Browse cuando cierra la ventana
   IF oSERSALSERIALA:lTmdi
      oSERSALSERIALA:bValid   :={|| oSERSALSERIALA:SETSERIALESGRID(.F.),EJECUTAR("BRWSAVEPAR",oSERSALSERIALA)}
   ELSE
      oSERSALSERIALA:oWnd:=oSERSALSERIALA:oDlg
   ENDIF

   oSERSALSERIALA:lBtnRun     :=.F.
   oSERSALSERIALA:lBtnMenuBrw :=.F.
   oSERSALSERIALA:lBtnSave    :=.F.
   oSERSALSERIALA:lBtnCrystal :=.F.
   oSERSALSERIALA:lBtnRefresh :=.F.
   oSERSALSERIALA:lBtnHtml    :=.T.
   oSERSALSERIALA:lBtnExcel   :=.T.
   oSERSALSERIALA:lBtnPreview :=.T.
   oSERSALSERIALA:lBtnQuery   :=.F.
   oSERSALSERIALA:lBtnOptions :=.T.
   oSERSALSERIALA:lBtnPageDown:=.T.
   oSERSALSERIALA:lBtnPageUp  :=.T.
   oSERSALSERIALA:lBtnFilters :=.T.
   oSERSALSERIALA:lBtnFind    :=.T.
   oSERSALSERIALA:lBtnColor   :=.T.

   oSERSALSERIALA:nClrPane1:=16775408
   oSERSALSERIALA:nClrPane2:=16771797

   oSERSALSERIALA:nClrText :=0
   oSERSALSERIALA:nClrText1:=16744448
   oSERSALSERIALA:nClrText2:=0
   oSERSALSERIALA:nClrText3:=0
   oSERSALSERIALA:nClrText4:=0

   oSERSALSERIALA:oBrw:=TXBrowse():New( IF(oSERSALSERIALA:lTmdi,oSERSALSERIALA:oWnd,oSERSALSERIALA:oDlg ))

   oSERSALSERIALA:oBrw:SetArray( aData, .F. )
   oSERSALSERIALA:oBrw:SetFont(oFont)

   oSERSALSERIALA:oBrw:lFooter     := .F.
   oSERSALSERIALA:oBrw:lHScroll    := .F.
   oSERSALSERIALA:oBrw:nHeaderLines:= 2
   oSERSALSERIALA:oBrw:nDataLines  := 1
   oSERSALSERIALA:oBrw:nFooterLines:= 1

   oSERSALSERIALA:aData            :=ACLONE(aData)

   AEVAL(oSERSALSERIALA:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})
  

  // Campo: SERIALM
  oCol:=oSERSALSERIALA:oBrw:aCols[1]
  oCol:cHeader      :='Serial'+CRLF+'Motor'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oSERSALSERIALA:oBrw:aArrayData ) } 
  oCol:nWidth       := 220

//  oCol:nEditType    :=1
//  oCol:bOnPostEdit  :={|oCol,uValue|oSERSALSERIALA:PUTVALOR(oCol,uValue,1)}


  // Campo: SERIALC
  oCol:=oSERSALSERIALA:oBrw:aCols[2]
  oCol:cHeader      :='Serial'+CRLF+'Carrocería'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oSERSALSERIALA:oBrw:aArrayData ) } 
  oCol:nWidth       := 210
//  oCol:nEditType    :=1
//  oCol:bOnPostEdit  :={|oCol,uValue|oSERSALSERIALA:PUTVALOR(oCol,uValue,2)}

  // Campo: COLOR
  oCol:=oSERSALSERIALA:oBrw:aCols[3]
  oCol:cHeader       :='Color'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oSERSALSERIALA:oBrw:aArrayData ) } 
  oCol:nWidth        := 150
//  oCol:nEditType     := EDIT_LISTBOX
//  oCol:aEditListTxt  := ACLONE(oSERSALSERIALA:aColor)
//  oCol:aEditListBound:= ACLONE(oSERSALSERIALA:aColor)
//  oCol:bOnPostEdit   := {|oCol, uValue|oSERSALSERIALA:PUTVALOR(oCol,uValue,3)} 

//oSERSALSERIALA:PUTVALOR(oCol,uValue,3)}
// ViewArray(oSERSALSERIALA:aColor)

  // Campo: PLACA
  oCol:=oSERSALSERIALA:oBrw:aCols[4]
  oCol:cHeader      :='Placa'
  oCol:bLClickHeader:= {|r,c,f,o| SortArray( o, oSERSALSERIALA:oBrw:aArrayData ) } 
  oCol:nWidth       := 64
//  oCol:nEditType    :=1
//  oCol:bOnPostEdit  :={|oCol,uValue|oSERSALSERIALA:PUTVALOR(oCol,uValue,4)}


  // Campo: ANO
  oCol:=oSERSALSERIALA:oBrw:aCols[5]
  oCol:cHeader      :='Año'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oSERSALSERIALA:oBrw:aArrayData ) } 
  oCol:nWidth       := 50
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9999'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oSERSALSERIALA:oBrw:aArrayData[oSERSALSERIALA:oBrw:nArrayAt,5],;
                              oCol  := oSERSALSERIALA:oBrw:aCols[5],;
                              FDP(nMonto,oCol:cEditPicture)}

//  oCol:nEditType    :=1
//  oCol:bOnPostEdit  :={|oCol,uValue|oSERSALSERIALA:PUTVALOR(oCol,uValue,5)}

  oCol:=oSERSALSERIALA:oBrw:aCols[6]
  oCol:cHeader      := "Ok"
  oCol:nWidth       := 40
  oCol:AddBmpFile("BITMAPS\checkverde.bmp")
  oCol:AddBmpFile("BITMAPS\checkrojo.bmp")
  oCol:bBmpData    := { ||oBrw:=oSERSALSERIALA:oBrw,IIF(oBrw:aArrayData[oBrw:nArrayAt,6],1,2) }
  oCol:nDataStyle  := oCol:DefStyle( AL_LEFT, .F.)
  oCol:bStrData    :={||""}



   oSERSALSERIALA:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))

   oSERSALSERIALA:oBrw:bClrStd  := {|oBrw,nClrText,aLine|oBrw:=oSERSALSERIALA:oBrw,aLine:=oBrw:aArrayData[oBrw:nArrayAt],;
                                                 nClrText:=oSERSALSERIALA:nClrText,;
                                                 nClrText:=IF(aLine[6],oSERSALSERIALA:nClrText1,nClrText),;
                                                 nClrText:=IF(.F.,oSERSALSERIALA:nClrText2,nClrText),;
                                                 {nClrText,iif( oBrw:nArrayAt%2=0, oSERSALSERIALA:nClrPane1, oSERSALSERIALA:nClrPane2 ) } }

//   oSERSALSERIALA:oBrw:bClrHeader            := {|| {0,14671839 }}
//   oSERSALSERIALA:oBrw:bClrFooter            := {|| {0,14671839 }}

   oSERSALSERIALA:oBrw:bClrHeader          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oSERSALSERIALA:oBrw:bClrFooter          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

   oSERSALSERIALA:oBrw:bLDblClick:={|oBrw|oSERSALSERIALA:RUNCLICK() }

   oSERSALSERIALA:oBrw:bChange:={||oSERSALSERIALA:BRWCHANGE()}
   oSERSALSERIALA:oBrw:CreateFromCode()

   IF oSERSALSERIALA:lMdi
     oSERSALSERIALA:oWnd:oClient := oSERSALSERIALA:oBrw
   ENDIF

   oSERSALSERIALA:Activate({||oSERSALSERIALA:ViewDatBar()})

   IF oSERSALSERIALA:lMdi 
     oSERSALSERIALA:BRWRESTOREPAR()
   ENDIF

RETURN oSERSALSERIALA:aData

/*
// Barra de Botones
*/
FUNCTION ViewDatBar()
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg:=IF(oSERSALSERIALA:lTmdi,oSERSALSERIALA:oWnd,oSERSALSERIALA:oDlg)
   LOCAL nLin:=2,nCol:=0
   LOCAL nWidth:=oSERSALSERIALA:oBrw:nWidth()

   oSERSALSERIALA:oBrw:GoBottom(.T.)
   oSERSALSERIALA:oBrw:nArrayAt:=LEN(oSERSALSERIALA:oBrw:aArrayData)
   oSERSALSERIALA:oBrw:Refresh(.T.)


   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -10 BOLD

 // Emanager no Incluye consulta de Vinculos
   IF .F. .AND. Empty(oSERSALSERIALA:cServer)

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\VIEW.BMP";
            ACTION EJECUTAR("BRWRUNLINK",oSERSALSERIALA:oBrw,oSERSALSERIALA:cSql)

     oBtn:cToolTip:="Consultar Vinculos"


   ENDIF

   IF .t.
// ValType(oSERSALSERIALA:oGrid)="O"

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XSAVE.BMP";
            ACTION (oSERSALSERIALA:lSave:=.T.,;
                    oSERSALSERIALA:SETSERIALESGRID(.T.))

     oBtn:cToolTip:="Guardar Seriales en el Formulario"

   ENDIF

/*
   IF Empty(oSERSALSERIALA:cServer) .AND. !Empty(SQLGET("DPBRWLNK","EBR_CODIGO","EBR_CODIGO"+GetWhere("=","SERENTSERIALA")))
*/

   IF ISSQLFIND("DPBRWLNKCONCAT","BRC_CODIGO"+GetWhere("=","SERENTSERIALA"))

       DEFINE BUTTON oBtn;
       OF oBar;
       NOBORDER;
       FONT oFont;
       FILENAME "BITMAPS\XBROWSE.BMP";
       ACTION EJECUTAR("BRWRUNBRWLINK",oSERSALSERIALA:oBrw,"SERENTSERIALA",oSERSALSERIALA:cSql,oSERSALSERIALA:nPeriodo,oSERSALSERIALA:dDesde,oSERSALSERIALA:dHasta,oSERSALSERIALA)

       oBtn:cToolTip:="Ejecutar Browse Vinculado(s)"
       oSERSALSERIALA:oBtnRun:=oBtn



       oSERSALSERIALA:oBrw:bLDblClick:={||EVAL(oSERSALSERIALA:oBtnRun:bAction) }


   ENDIF


IF oSERSALSERIALA:lBtnRun

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            MENU EJECUTAR("BRBTNMENU",{"Opcion 1",;
                                       "Opcion 2",;
                                       "Opcion 3"},;
                                       "oSERSALSERIALA");
            FILENAME "BITMAPS\RUN.BMP";
            ACTION oSERSALSERIALA:BTNRUN()

      oBtn:cToolTip:="Opciones de Ejecucion"

ENDIF

IF oSERSALSERIALA:lBtnColor

     oSERSALSERIALA:oBtnColor:=NIL

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\COLORS.BMP";
            MENU EJECUTAR("BRBTNMENUCOLOR",oSERSALSERIALA:oBrw,oSERSALSERIALA,oSERSALSERIALA:oBtnColor,{||EJECUTAR("BRWCAMPOSOPC",oSERSALSERIALA,.T.)});
            ACTION EJECUTAR("BRWSELCOLORFIELD",oSERSALSERIALA,.T.)

    oBtn:cToolTip:="Personalizar Colores en los Campos"

    oSERSALSERIALA:oBtnColor:=oBtn

ENDIF



IF oSERSALSERIALA:lBtnSave

      DEFINE BITMAP OF OUTLOOK oBRWMENURUN:oOut ;
             BITMAP "BITMAPS\XSAVE.BMP";
             PROMPT "Guardar Consulta";
             ACTION EJECUTAR("DPBRWSAVE",oSERSALSERIALA:oBrw,oSERSALSERIALA:oFrm)
ENDIF

IF oSERSALSERIALA:lBtnMenuBrw

 DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\BRWMENU.BMP",NIL,"BITMAPS\BRWMENUG.BMP";
          ACTION (EJECUTAR("BRWBUILDHEAD",oSERSALSERIALA),;
                  EJECUTAR("DPBRWMENURUN",oSERSALSERIALA,oSERSALSERIALA:oBrw,oSERSALSERIALA:cBrwCod,oSERSALSERIALA:cTitle,oSERSALSERIALA:aHead));
          WHEN !Empty(oSERSALSERIALA:oBrw:aArrayData[1,1])

   oBtn:cToolTip:="Menú de Opciones"

ENDIF


IF oSERSALSERIALA:lBtnFind

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
          ACTION EJECUTAR("BRWSETFIND",oSERSALSERIALA:oBrw)

   oBtn:cToolTip:="Buscar"
ENDIF

IF oSERSALSERIALA:lBtnFilters

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
          MENU EJECUTAR("BRBTNMENUFILTER",oSERSALSERIALA:oBrw,oSERSALSERIALA);
          ACTION EJECUTAR("BRWSETFILTER",oSERSALSERIALA:oBrw)

   oBtn:cToolTip:="Filtrar Registros"
ENDIF

IF oSERSALSERIALA:lBtnOptions

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\OPTIONS.BMP",NIL,"BITMAPS\OPTIONSG.BMP";
          ACTION EJECUTAR("BRWSETOPTIONS",oSERSALSERIALA:oBrw);
          WHEN LEN(oSERSALSERIALA:oBrw:aArrayData)>1

   oBtn:cToolTip:="Filtrar según Valores Comunes"

ENDIF

IF oSERSALSERIALA:lBtnRefresh

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\REFRESH.BMP";
          ACTION oSERSALSERIALA:BRWREFRESCAR()

   oBtn:cToolTip:="Refrescar"

ENDIF

IF oSERSALSERIALA:lBtnCrystal

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CRYSTAL.BMP";
          ACTION EJECUTAR("BRWTODBF",oSERSALSERIALA)

   oBtn:cToolTip:="Visualizar Mediante Crystal Report"

ENDIF

IF oSERSALSERIALA:lBtnExcel


     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\EXCEL.BMP";
            ACTION (EJECUTAR("BRWTOEXCEL",oSERSALSERIALA:oBrw,oSERSALSERIALA:cTitle,oSERSALSERIALA:cNombre))

     oBtn:cToolTip:="Exportar hacia Excel"

     oSERSALSERIALA:oBtnXls:=oBtn

ENDIF

IF oSERSALSERIALA:lBtnHtml

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\html.BMP";
          ACTION (oSERSALSERIALA:HTMLHEAD(),EJECUTAR("BRWTOHTML",oSERSALSERIALA:oBrw,NIL,oSERSALSERIALA:cTitle,oSERSALSERIALA:aHead))

   oBtn:cToolTip:="Generar Archivo html"

   oSERSALSERIALA:oBtnHtml:=oBtn

ENDIF


IF oSERSALSERIALA:lBtnPreview

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PREVIEW.BMP";
          ACTION (EJECUTAR("BRWPREVIEW",oSERSALSERIALA:oBrw))

   oBtn:cToolTip:="Previsualización"

   oSERSALSERIALA:oBtnPreview:=oBtn

ENDIF

   IF ISSQLGET("DPREPORTES","REP_CODIGO","BRSERENTSERIALA")

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XPRINT.BMP";
            ACTION oSERSALSERIALA:IMPRIMIR()

      oBtn:cToolTip:="Imprimir"

     oSERSALSERIALA:oBtnPrint:=oBtn

   ENDIF

IF oSERSALSERIALA:lBtnQuery


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\QUERY.BMP";
          ACTION oSERSALSERIALA:BRWQUERY()

   oBtn:cToolTip:="Imprimir"

ENDIF




   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          ACTION (oSERSALSERIALA:oBrw:GoTop(),oSERSALSERIALA:oBrw:Setfocus())

IF nWidth>800 .OR. nWidth=0

   IF oSERSALSERIALA:lBtnPageDown

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\xSIG.BMP";
            ACTION (oSERSALSERIALA:oBrw:PageDown(),oSERSALSERIALA:oBrw:Setfocus())
  ENDIF

  IF  oSERSALSERIALA:lBtnPageUp

    DEFINE BUTTON oBtn;
           OF oBar;
           NOBORDER;
           FONT oFont;
           FILENAME "BITMAPS\xANT.BMP";
           ACTION (oSERSALSERIALA:oBrw:PageUp(),oSERSALSERIALA:oBrw:Setfocus())
  ENDIF

ENDIF

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oSERSALSERIALA:oBrw:GoBottom(),oSERSALSERIALA:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oSERSALSERIALA:Close()

  oSERSALSERIALA:oBrw:SetColor(0,oSERSALSERIALA:nClrPane1)

  oSERSALSERIALA:SETBTNBAR(40,40,oBar)
 
  EVAL(oSERSALSERIALA:oBrw:bChange)

  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  oSERSALSERIALA:oBar:=oBar

  nLin:=nLin+34

  DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -11 BOLD

  oBar:SetSize(NIL,70,.T.)

  @ nLin+10,30-20 SAY " Código " OF oBar BORDER PIXEL;
               COLOR oDp:nClrLabelText,oDp:nClrLabelPane FONT oFont SIZE 50,20  RIGHT

  @ nLin+10,81-20 SAY oSERSALSERIALA:oINV_CODIGO PROMPT " "+oSERSALSERIALA:INV_CODIGO BORDER PIXEL;
               COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont SIZE 100,20

  @ nLin+10,170+10 SAY " Descripción " OF oBar BORDER PIXEL;
               COLOR oDp:nClrLabelText,oDp:nClrLabelPane FONT oFont SIZE 50+40,20 RIGHT 

  @ nLin+10,170+81+20 SAY oSERSALSERIALA:oSAY_DESCRI PROMPT " "+SQLGET("DPINV","INV_DESCRI","INV_CODIGO"+GetWhere("=",oSERSALSERIALA:INV_CODIGO));
               BORDER PIXEL;
               COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont SIZE 300,20
 
  IF !File("FORMS\BRSERENTSERIALA.EDT")
     oSERSALSERIALA:oBrw:Move(oBar:nHeight()-2,0,oDlg:nWidth()-8,oDlg:nHeight()-oBar:nHeight()-28)
  ENDIF

RETURN .T.

/*
// Evento para presionar CLICK
*/
FUNCTION RUNCLICK()

  oSERSALSERIALA:oBrw:aArrayData[oSERSALSERIALA:oBrw:nArrayAt,6]:=!oSERSALSERIALA:oBrw:aArrayData[oSERSALSERIALA:oBrw:nArrayAt,6]
  oSERSALSERIALA:oBrw:DrawLine(.T.)
RETURN .T.


/*
// Imprimir
*/
FUNCTION IMPRIMIR()
  LOCAL oRep,cWhere

  oRep:=REPORTE("BRSERENTSERIALA",cWhere)
  oRep:cSql  :=oSERSALSERIALA:cSql
  oRep:cTitle:=oSERSALSERIALA:cTitle

RETURN .T.

FUNCTION LEEFECHAS()
  LOCAL nPeriodo:=oSERSALSERIALA:oPeriodo:nAt,cWhere

  oSERSALSERIALA:nPeriodo:=nPeriodo


  IF oSERSALSERIALA:oPeriodo:nAt=LEN(oSERSALSERIALA:oPeriodo:aItems)

     oSERSALSERIALA:oDesde:ForWhen(.T.)
     oSERSALSERIALA:oHasta:ForWhen(.T.)
     oSERSALSERIALA:oBtn  :ForWhen(.T.)

     DPFOCUS(oSERSALSERIALA:oDesde)

  ELSE

     oSERSALSERIALA:aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)

     oSERSALSERIALA:oDesde:VarPut(oSERSALSERIALA:aFechas[1] , .T. )
     oSERSALSERIALA:oHasta:VarPut(oSERSALSERIALA:aFechas[2] , .T. )

     oSERSALSERIALA:dDesde:=oSERSALSERIALA:aFechas[1]
     oSERSALSERIALA:dHasta:=oSERSALSERIALA:aFechas[2]

     cWhere:=oSERSALSERIALA:HACERWHERE(oSERSALSERIALA:dDesde,oSERSALSERIALA:dHasta,oSERSALSERIALA:cWhere,.T.)

     oSERSALSERIALA:LEERDATA(cWhere,oSERSALSERIALA:oBrw,oSERSALSERIALA:cServer,oSERSALSERIALA)

  ENDIF

  oSERSALSERIALA:SAVEPERIODO()

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

     IF !Empty(oSERSALSERIALA:cWhereQry)
       cWhere:=cWhere + oSERSALSERIALA:cWhereQry
     ENDIF

     oSERSALSERIALA:LEERDATA(cWhere,oSERSALSERIALA:oBrw,oSERSALSERIALA:cServer,oSERSALSERIALA)

   ENDIF


RETURN cWhere


FUNCTION LEERDATA(cWhere,oBrw,cServer,oSERSALSERIALA)
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
          " MSR_SERIAL AS SERIALM,"+;
          " MSR_LOTE   AS SERIALC,"+;
          " MSR_CODTAR AS COLOR,"+;
          " MSR_ORDPRO AS PLACA,"+;
          " MSR_CANEMP AS ANO"+;
          " FROM DPMOVSERIAL"+;
          " ORDER BY MSR_SERIAL"+;
""

/*
   IF Empty(cWhere)
     cSql:=STRTRAN(cSql,"<WHERE>","")
   ELSE
     cSql:=STRTRAN(cSql,"<WHERE>"," WHERE "+cWhere)
   ENDIF
*/
   IF !Empty(cWhere)
      cSql:=EJECUTAR("SQLINSERTWHERE",cSql,cWhere)
   ENDIF

   cSql:=EJECUTAR("WHERE_VAR",cSql)


   oDp:lExcluye:=.F.

   DPWRITE("TEMP\BRSERENTSERIALA.SQL",cSql)

   aData:=ASQL(cSql,oDb)

   oDp:cWhere:=cWhere


   IF EMPTY(aData)
      aData:=EJECUTAR("SQLARRAYEMPTY",cSql,oDb)
//    AADD(aData,{'','','','',0})
   ENDIF

   

   IF ValType(oBrw)="O"

      oSERSALSERIALA:cSql   :=cSql
      oSERSALSERIALA:cWhere_:=cWhere

      aTotal:=ATOTALES(aData)

      oBrw:aArrayData:=ACLONE(aData)
      // oBrw:nArrayAt  :=1
      // oBrw:nRowSel   :=1

      // JN 15/03/2020 Sustituido por BRWCALTOTALES
      EJECUTAR("BRWCALTOTALES",oBrw,.F.)

      nAt    :=oBrw:nArrayAt
      nRowSel:=oBrw:nRowSel

      oBrw:Refresh(.F.)
      oBrw:nArrayAt  :=MIN(nAt,LEN(aData))
      oBrw:nRowSel   :=MIN(nRowSel,oBrw:nRowSel)
      AEVAL(oSERSALSERIALA:oBar:aControls,{|o,n| o:ForWhen(.T.)})

      oSERSALSERIALA:SAVEPERIODO()

   ENDIF

RETURN aData


FUNCTION SAVEPERIODO()
  LOCAL cFileMem:="USER\BRSERENTSERIALA.MEM",V_nPeriodo:=oSERSALSERIALA:nPeriodo
  LOCAL V_dDesde:=oSERSALSERIALA:dDesde
  LOCAL V_dHasta:=oSERSALSERIALA:dHasta

  SAVE TO (cFileMem) ALL LIKE "V_*"

RETURN .T.

/*
// Permite Crear Filtros para las Búquedas
*/
FUNCTION BRWQUERY()
     EJECUTAR("BRWQUERY",oSERSALSERIALA)
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


    IF Type("oSERSALSERIALA")="O" .AND. oSERSALSERIALA:oWnd:hWnd>0

      cWhere:=" "+IIF(!Empty(oSERSALSERIALA:cWhere_),oSERSALSERIALA:cWhere_,oSERSALSERIALA:cWhere)
      cWhere:=STRTRAN(cWhere," WHERE ","")

      oSERSALSERIALA:LEERDATA(oSERSALSERIALA:cWhere_,oSERSALSERIALA:oBrw,oSERSALSERIALA:cServer,oSERSALSERIALA)
      oSERSALSERIALA:oWnd:Show()
      oSERSALSERIALA:oWnd:Restore()

    ENDIF

RETURN NIL

FUNCTION BTNRUN()
    ? "PERSONALIZA FUNCTION DE BTNRUN"
RETURN .T.

FUNCTION BTNMENU(nOption,cOption)

   ? nOption,cOption,"PESONALIZA LAS SUB-OPCIONES"

   IF nOption=1
   ENDIF

   IF nOption=2
   ENDIF

   IF nOption=3
   ENDIF

RETURN .T.

FUNCTION HTMLHEAD()

   oSERSALSERIALA:aHead:=EJECUTAR("HTMLHEAD",oSERSALSERIALA)

// Ejemplo para Agregar mas Parámetros
//   AADD(oDOCPROISLR:aHead,{"Consulta",oDOCPROISLR:oWnd:cTitle})

RETURN

// Restaurar Parametros
FUNCTION BRWRESTOREPAR()
  EJECUTAR("BRWRESTOREPAR",)
RETURN .T.


FUNCTION PUTVALOR(oCol,uValue,nCol)
  LOCAL aLine  :=oSERSALSERIALA:oBrw:aArrayData[oSERSALSERIALA:oBrw:nArrayAt]
  LOCAL nAt    :=oSERSALSERIALA:oBrw:nArrayAt

 
  oSERSALSERIALA:oBrw:aArrayData[oSERSALSERIALA:oBrw:nArrayAt,nCol]:=uValue
  oSERSALSERIALA:oBrw:DrawLine(.t.)

  IF nCol=5
    oSERSALSERIALA:SERNEWLINE()
  ELSE
    oSERSALSERIALA:oBrw:nColSel:=nCol+1
  ENDIF

RETURN .T.

FUNCTION SERNEWLINE()

   LOCAL aLine:=ATAIL(oSERSALSERIALA:oBrw:aArrayData)

   IF !Empty(aLine)

      AEVAL(aLine,{|a,n| aLine[n]:=CTOEMPTY(a)})
      aLine[5]:=YEAR(oDp:dFecha)
      AADD(oSERSALSERIALA:oBrw:aArrayData,aLine)
      oSERSALSERIALA:oBrw:nColSel:=1

      oSERSALSERIALA:oBrw:GoBottom(.T.)
      oSERSALSERIALA:oBrw:Refresh(.F.)
      // oSERSALSERIALA:oBrw:nColSel:=1
      // oSERSALSERIALA:oBrw:nArrayAt:=LEN(oSERSALSERIALA:oBrw:aArrayData)
   ENDIF

RETURN .T.

FUNCTION SETSERIALESGRID(lSave)

  oSERSALSERIALA:aData:=ACLONE(oSERSALSERIALA:oBrw:aArrayData)

  ADEPURA(oSERSALSERIALA:aData,6)
  ADEPURA(oSERSALSERIALA:aData,{|a,n| Empty(a[1])})

  oSERSALSERIALA:Close()

RETURN .T.
// EOF



//

