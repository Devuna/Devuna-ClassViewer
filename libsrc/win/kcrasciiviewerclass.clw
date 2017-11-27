!Ascii Viewer Code

   MEMBER

!region Notices
! ================================================================================
! Notice : Copyright (C) 2017, Devuna
!          Distributed under the MIT License (https://opensource.org/licenses/MIT)
!
!    This file is part of Devuna-ClassViewer (https://github.com/Devuna/Devuna-ClassViewer)
!
!    Devuna-ClassViewer is free software: you can redistribute it and/or modify
!    it under the terms of the MIT License as published by
!    the Open Source Initiative.
!
!    Devuna-ClassViewer is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    MIT License for more details.
!
!    You should have received a copy of the MIT License
!    along with Devuna-ClassViewer.  If not, see <https://opensource.org/licenses/MIT>.
! ================================================================================
!endregion Notices

   MAP
   END

  INCLUDE('kcrAsciiFileClass.inc'),ONCE


kcrAsciiViewerClass.Init PROCEDURE(FILE AsciiFile,*STRING FileLine,UNSIGNED ListBox,ErrorClass ErrHandler,BYTE Enables=0)

Filename  STRING(File:MaxFilePath),AUTO

  CODE
  FileName=NAME(AsciiFile)
  ASSERT(FileName)
  RETURN SELF.Init(AsciiFile,FileLine,Filename,ListBox,ErrHandler,Enables)


kcrAsciiViewerClass.Init PROCEDURE(FILE AsciiFile,*STRING FileLine,*STRING Filename,UNSIGNED ListBox,ErrorClass ErrHandler,BYTE Enables=0)

c USHORT,AUTO

  CODE
  SELF.ListBox=ListBox
  SELF.ListBoxItems=SELF.ListBox{PROP:Items}
  IF ~PARENT.Init(AsciiFile,FileLine,Filename,ErrHandler) THEN RETURN False.     !FileMgr Init failed
  SELF.DisplayQueue &= NEW(DisplayQueue)
  SELF.LBPreserve.HScrollState=SELF.ListBox{PROP:HScroll}
  SELF.LBPreserve.HScrollPos=SELF.ListBox{PROP:HScrollPos}
  SELF.LBPreserve.VScrollState=SELF.ListBox{PROP:VScroll}
  SELF.LBPreserve.VScrollPos=SELF.ListBox{PROP:VScrollPos}
  SELF.LBPreserve.IMMState=SELF.ListBox{PROP:IMM}
  SELF.LBPreserve.Format=SELF.ListBox{PROP:Format}
  LOOP c=251 TO 253
    SELF.LBPreserve.Alrt[c-250]=SELF.ListBox{PROP:Alrt,c}
  END
  SELF.ListBox{PROP:From}=SELF.DisplayQueue
  SELF.ListBox{PROP:Format}=''
  SELF.ListBox{PROP:HScroll}=True
  SELF.ListBox{PROP:Alrt,251}=MouseRightUp
  SELF.ListBox{PROP:Alrt,252}=CtrlPgUp
  SELF.ListBox{PROP:Alrt,253}=CtrlPgDn
  SELF.ListBox{PROP:Imm}=True
  SELF.ListBox{PROP:VScroll}=True
  IF BAND(Enables,EnableSearch)
    SELF.Searcher &= NEW kcrAsciiSearchClass
    SELF.Searcher.Init(SELF,ErrHandler)
    SELF.SearcherSelfCreated=True
  END
  IF BAND(Enables,EnablePrint)
    SELF.Printer &= NEW kcrAsciiPrintClass
    SELF.Printer.Init(SELF,ErrHandler)
    SELF.PrinterSelfCreated=True
  END
  SELF.Popup &= NEW PopupClass
  SELF.Popup.Init
  SELF.Popup.AddMenu('~&Find|~&Print|-|&Move{{&Top|Page &Up|Page &Down|Bottom}|-|&Goto')
  SELF.Popup.SetItemEnable('Find',CHOOSE(BAND(Enables,EnableSearch)))
  SELF.Popup.SetItemEnable('Print',CHOOSE(BAND(Enables,EnablePrint)))
  SELF.Popup.AddItemEvent('Top',EVENT:ScrollTop,ListBox)
  SELF.Popup.AddItemEvent('PageUp',EVENT:PageUp,ListBox)
  SELF.Popup.AddItemEvent('PageDown',EVENT:PageDown,ListBox)
  SELF.Popup.AddItemEvent('Bottom',EVENT:ScrollBottom,ListBox)
  RETURN SELF.Reset(Filename)


kcrAsciiViewerClass.Kill PROCEDURE

c USHORT,AUTO

  CODE
  SELF.ListBox{PROP:HScroll}=SELF.LBPreserve.HScrollState     !restore list box settings
  SELF.ListBox{PROP:HScrollPos}=SELF.LBPreserve.HScrollPos
  SELF.ListBox{PROP:VScroll}=SELF.LBPreserve.VScrollState
  SELF.ListBox{PROP:VScrollPos}=SELF.LBPreserve.VScrollPos
  SELF.ListBox{PROP:IMM}=SELF.LBPreserve.IMMState
  SELF.ListBox{PROP:Format}=SELF.LBPreserve.Format
  LOOP c=251 TO 253
    SELF.ListBox{PROP:Alrt,c}=SELF.LBPreserve.Alrt[c-250]
  END
  PARENT.Kill                                                 !kill FileMgr
  DISPOSE(SELF.DisplayQueue)
  SELF.ListBox{PROP:From}=''
  SELF.Popup.Kill
  DISPOSE(SELF.Popup)
  IF SELF.SearcherSelfCreated=True THEN
     DISPOSE(SELF.Searcher)
  END
  IF SELF.PrinterSelfCreated=True THEN
     DISPOSE(SELF.Printer)
  END



kcrAsciiViewerClass.AddItem PROCEDURE(kcrAsciiPrintClass Printer)

  CODE
  IF SELF.PrinterSelfCreated=True THEN
     DISPOSE(SELF.Printer)
     SELF.PrinterSelfCreated=False
  END
  SELF.Printer &= Printer
  SELF.Printer.Init(SELF,SELF.ErrorMgr)
  SELF.Popup.SetItemEnable('Print',True)


kcrAsciiViewerClass.AddItem PROCEDURE(kcrAsciiSearchClass Searcher)

  CODE
  IF SELF.SearcherSelfCreated=True THEN
     DISPOSE(SELF.Searcher)
     SELF.SearcherSelfCreated=False
  END
  SELF.Searcher &= Searcher
  SELF.Searcher.Init(SELF,SELF.ErrorMgr)
  SELF.Popup.SetItemEnable('Find',True)


kcrAsciiViewerClass.SetTranslator PROCEDURE(TranslatorClass T)

  CODE
  SELF.Translator &= T
  IF ~SELF.Searcher &= NULL
    SELF.Searcher.SetTranslator(T)
  END
  IF ~SELF.Printer &= NULL
    SELF.Printer.SetTranslator(T)
  END
  SELF.Popup.SetTranslator(T)


kcrAsciiViewerClass.Reset PROCEDURE(*STRING Filename)

  CODE
  FREE(SELF.DisplayQueue)
  DISPLAY(SELF.ListBox)
  IF ~PARENT.Reset(Filename) THEN RETURN False.
  SELF.TopLine=1
  SELF.SetPercentile(0)
  SELF.DisplayPage
  RETURN True


kcrAsciiViewerClass.TakeEvent PROCEDURE(UNSIGNED EventNo)
  CODE
  IF FIELD()=0                              !Field independant event
    CASE EVENT()
    OF EVENT:Sized
      SELF.DisplayPage
    END
  ELSIF FIELD()=SELF.ListBox
    CASE EventNo
    OF EVENT:NewSelection
      SELF.SetThumb
    OF EVENT:AlertKey
      CASE KEYCODE()
      OF CtrlPgUp
        POST(EVENT:ScrollTop,SELF.ListBox)
      OF CtrlPgDn
        POST(EVENT:ScrollBottom,SELF.ListBox)
      OF MouseRightUp
        CASE SELF.Popup.Ask()
        OF 'Find'
          SELF.Searcher.Ask(CHOOSE(CHOICE(SELF.listBox)>0,SELF.TopLine+CHOICE(SELF.ListBox)-1,1))
        OF 'Print'
          SELF.Printer.Ask
        OF 'Goto'
          SELF.AskGotoLine
        END
      END
    OF EVENT:ScrollDrag
      SETCURSOR(CURSOR:Wait)
      SELF.SetPercentile(SELF.ListBox{PROP:VScrollPos})
      SETCURSOR
    OF EVENT:Scrollup
      SELF.SetLineRelative(-1)
    OF EVENT:ScrollDown
      SELF.SetLineRelative(1)
    OF EVENT:PageUp
      SELF.PageUp
    OF EVENT:PageDown
      SELF.PageDown
    OF EVENT:ScrollTop
      SELF.DisplayPage(1)
    OF EVENT:ScrollBottom
      SETCURSOR(CURSOR:Wait)
      SELF.DisplayPage(SELF.GetLastLineNo())
      SETCURSOR
    END
    RETURN Level:Notify
  END
  RETURN Level:Benign


kcrAsciiViewerClass.AskGotoLine PROCEDURE

LineNo  LONG,STATIC
OKGo    BYTE(False)
X       LONG
Y       LONG

GotoDialog WINDOW('Goto'),AT(,,96,38),FONT('MS Sans Serif',8,,FONT:regular),CENTER,GRAY,DOUBLE
       SPIN(@n_5),AT(36,4,56,13),USE(LineNo),RANGE(1,99999)
       PROMPT('&Line No:'),AT(4,9,32,10),USE(?Prompt1)
       BUTTON('&Go'),AT(8,22,40,14),USE(?GoButton),TIP('Go to selected Line')
       BUTTON('&Cancel'),AT(52,22,40,14),USE(?CancelButton),TIP('Cancel GoTo operation')
     END

  CODE
  OPEN(GotoDialog)
  IF ~SELF.Translator&=NULL THEN SELF.Translator.TranslateWindow.
  ACCEPT
    CASE EVENT()
    OF EVENT:Accepted
      CASE ACCEPTED()
      OF ?GoButton
        OKGo=True
      OROF ?CancelButton
        POST(EVENT:CloseWindow)
      END
    END
  END
  CLOSE(GotoDialog)
  IF OKGo THEN SELF.SetLine(LineNo).


kcrAsciiViewerClass.DisplayPage PROCEDURE

  CODE
  SELF.DisplayPage(SELF.TopLine)


kcrAsciiViewerClass.DisplayPage PROCEDURE(LONG LineNo)

LastPageLine  USHORT,AUTO
RecsQ         LONG,AUTO

  CODE
  SELF.ListBoxItems=SELF.ListBox{PROP:Items}
  IF LineNo>0
    LastPageLine=LineNo+SELF.ListBoxItems-1
    !RecsQ=RECORDS(SELF.IndexQueue)
    SELF.GetLine(LastPageLine)
    RecsQ=RECORDS(SELF.IndexQueue)
    IF RecsQ<=SELF.ListBoxItems
      SELF.DisplayPage(1,RecsQ,LineNo)
    ELSE
      IF RecsQ>=LastPageLine
        SELF.DisplayPage(LineNo,LastPageLine,1)
      ELSE
        SELF.DisplayPage(RecsQ-SELF.ListBoxItems+1,RecsQ,SELF.ListBoxItems)
      END
    END
  END


!This is a PRIVATE low-level version of DisplayPage, it assumes that StartLine and EndLine are always valid and that
!the file has alreday been indexed up to EndLine, also SelectLine must exist withinc the ListBox
kcrAsciiViewerClass.DisplayPage PROCEDURE(LONG StartLine,LONG EndLine,USHORT SelectLine)

i LONG,AUTO

  CODE
  FREE(SELF.DisplayQueue)
  LOOP i=StartLine TO EndLine
    SELF.DisplayQueue.LineNo = i                                                !Devuna 05/28/2003 RR
    SELF.DisplayQueue.Line=SELF.GetLine(i)
    SELF.SetDisplayQueueStyle(i,SELF.DisplayQueue.Style)                        !Devuna 03/19/2003 RR
    ADD(SELF.DisplayQueue)
    ASSERT(~ERRORCODE())
  END
  SELF.TopLine=StartLine
  SELF.SetListboxSelection(SelectLine)


kcrAsciiViewerClass.SetDisplayQueueStyle PROCEDURE(LONG LineNo, *LONG Style)    !Devuna 03/19/2003 RR
  CODE                                                                          !Devuna 03/19/2003 RR
  RETURN                                                                        !Devuna 03/19/2003 RR


kcrAsciiViewerClass.SetLineRelative PROCEDURE(LONG LineCount)        !-Ve up, +Ve Down

CurSelect   USHORT,AUTO
SelectLine  USHORT,AUTO

  CODE
  CurSelect=SELF.ListBox{PROP:Selected}
  SelectLine=CurSelect
  LOOP ABS(LineCount) TIMES
    IF LineCount<0
      IF CurSelect>1
        SelectLine=CurSelect-1
      ELSE
        IF SELF.TopLine=1 THEN BREAK.
        SELF.TopLine-=1
        SelectLine=1
      END
    ELSE
      IF CurSelect<SELF.ListBoxItems
        IF CurSelect+1<=RECORDS(SELF.IndexQueue)
          SelectLine=CurSelect+1
        END
      ELSE
        SELF.GetLine(SELF.TopLine+SELF.ListBoxItems)
        IF RECORDS(SELF.indexQueue)<SELF.TopLine+SELF.ListBoxItems THEN BREAK.
        SELF.TopLine+=1
        SelectLine=SELF.ListBoxItems
      END
    END
  END
  SELF.DisplayPage(SELF.TopLine)
  SELF.SetListBoxSelection(SelectLine)


kcrAsciiViewerClass.SetListboxSelection PROCEDURE(LONG SelectLine)

  CODE
  IF INRANGE(SelectLine,1,SELF.ListBoxItems)
    SELF.ListBox{PROP:Selected}=SelectLine
    SELF.SetThumb
  END


kcrAsciiViewerClass.PageUp PROCEDURE

  CODE
  IF CHOICE(SELF.ListBox)=1
    SELF.SetLineRelative(-SELF.ListBoxItems)
  ELSE
    SELF.SetListboxSelection(1)
  END


kcrAsciiViewerClass.PageDown PROCEDURE

  CODE
  IF CHOICE(SELF.ListBox)=SELF.ListBoxItems
    SELF.SetLineRelative(SELF.ListBoxItems)
  ELSE
    SELF.SetListboxSelection(CHOOSE(RECORDS(SELF.IndexQueue)<=SELF.ListBoxItems,RECORDS(SELF.IndexQueue),SELF.ListBoxItems))
  END


kcrAsciiViewerClass.SetThumb PROCEDURE

  CODE
  SELF.ListBox{PROP:VScrollPos}=SELF.GetPercentile(SELF.TopLine+CHOICE(SELF.ListBox)-1)


kcrAsciiViewerClass.SetLine PROCEDURE(LONG LineNo)         !sync list box with line no provided by external source

  CODE
  SELF.DisplayPage(LineNo)
  SELF.SetListboxSelection(CHOOSE(LineNo-SELF.TopLine+1<=RECORDS(SELF.DisplayQueue),LineNo-SELF.TopLine+1,1))

