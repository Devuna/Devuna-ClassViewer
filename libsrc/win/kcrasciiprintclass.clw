!Ascii Printer Code

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


kcrAsciiPrintClass.Init PROCEDURE(kcrAsciiFileClass FileMgr, ErrorClass ErrHandler)

  CODE
  SELF.FileMgr &= FileMgr
  SELF.ErrorMgr &= ErrHandler
  SELF.PrintPreview=False

kcrAsciiPrintClass.Ask PROCEDURE

FirstLine       LONG
LastLine        LONG
HighestLine     LONG,AUTO

PrintOptions WINDOW('Print Options: Checking File, please wait...'),AT(,,259,89),FONT('MS Sans Serif',8,,FONT:regular), |
         CENTER,GRAY,DOUBLE
       OPTION('&Range to Print'),AT(4,0,196,73),USE(?RangeOption),BOXED
         RADIO('&All'),AT(8,13,30,13),USE(?Radio1),VALUE('All')
         RADIO('&Selection'),AT(8,26,44,13),USE(?Radio2),VALUE('Selection')
       END
       GROUP('&Line Range'),AT(8,39,188,30),USE(?LineRangeGroup),DISABLE,BOXED
         SPIN(@n5),AT(32,52,64,13),USE(FirstLine),RANGE(1,99999),STEP(1)
         SPIN(@n5),AT(128,52,64,13),USE(LastLine),RANGE(1,99999),STEP(1)
         PROMPT('&Last:'),AT(108,56,20,12),USE(?Prompt2),TRN
         PROMPT('&First:'),AT(12,56,20,13),USE(?FirstLinePrompt),TRN
       END
       CHECK('Pre&view Before Printing?'),AT(8,78),USE(SELF.PrintPreview,,?PrintPreview)
       BUTTON('&Print'),AT(204,4,52,14),USE(?PrintButton),DEFAULT
       BUTTON('Print &Setup...'),AT(204,22,52,14),USE(?PrintSetupButton),STD(STD:PrintSetup)
       BUTTON('&Cancel'),AT(204,39,52,14),USE(?CancelButton)
     END

  CODE
  OPEN(PrintOptions)
  IF ~SELF.Translator&=NULL THEN SELF.Translator.TranslateWindow.
  DISABLE(?RangeOption)
  DISABLE(?LineRangeGroup)
  DISABLE(?PrintButton,?CancelButton)
  ACCEPT
    CASE EVENT()
    OF EVENT:OpenWindow
      HighestLine=SELF.FileMgr.GetLastLineNo()
      PrintOptions{PROP:Text}=SUB(PrintOptions{Prop:Text},1,LEN('Print Options'))
      FirstLine=1
      LastLine=HighestLine
      ?FirstLine{PROP:RangeHigh}=Highestline
      ?LastLine{PROP:RangeHigh}=HighestLine
      ENABLE(?RangeOption,?Radio2)
      ENABLE(?PrintButton,?CancelButton)
      SELECT(?RangeOption,1)
      DISPLAY
    OF EVENT:Accepted
      CASE ACCEPTED()
      OF ?CancelButton
        POST(EVENT:CloseWindow)
      OF ?PrintButton
        IF CHOICE(?RangeOption)=1
          FirstLine=1
          LastLine=HighestLine
        ELSE
          IF ~INRANGE(LastLine,1,HighestLine) OR ~INRANGE(FirstLine,1,LastLine) OR FirstLine>LastLine
            SELF.ErrorMgr.SetField('first line ')
            IF SELF.ErrorMgr.ThrowMessage(Msg:FieldOutofRange,'1 and '&LastLine) NOT=Level:Fatal
              SELECT(?FirstLine)
              CYCLE
            END
          END
        END
        SELF.PrintLines(FirstLine,LastLine)
        POST(EVENT:CloseWindow)
      END
    END
    ?LineRangeGroup{PROP:Disable}=CHOOSE(CHOICE(?RangeOption)<>2)
  END
  CLOSE(PrintOptions)


kcrAsciiPrintClass.PrintLines PROCEDURE(LONG FirstLine,LONG LastLine)

YieldGrain      EQUATE(10)

CurrentLine     STRING(255),AUTO
ProgressValue   LONG
LineCount       LONG
PrevQ           PreviewQueue
Previewer       &PrintPreviewClass

window WINDOW('Printing'),AT(,,219,33),FONT('Tahoma',10,,FONT:regular),CENTER,GRAY,DOUBLE
       PROGRESS,USE(ProgressValue),AT(4,17,212,14),RANGE(0,100)
       STRING('100%'),AT(200,4),USE(?String3),RIGHT
       STRING('0%'),AT(4,4),USE(?String2),LEFT
       STRING('%age Complete'),AT(85,4),USE(?String1),CENTER
     END

Report REPORT,AT(1000,42,6000,11604),PRE(RPT),FONT('Courier New',10,,),THOUS
Detail DETAIL,AT(,,,177)
         STRING(@s255),AT(0,0,6042,208),USE(CurrentLine)
       END
     END

  CODE
  OPEN(Window)
  Window{PROP:Text}=Window{Prop:Text}&' line '&FirstLine&' to '&LastLine
  ?ProgressValue{PROP:RangeHigh}=LastLine-FirstLine+1
  IF ~SELF.Translator&=NULL THEN SELF.Translator.TranslateWindow.
  OPEN(Report)
  Report{PROP:Preview}=PrevQ.Filename
  IF SELF.PrintPreview
    Previewer &= NEW PrintPreviewClass
    Previewer.Init(PrevQ)
  END
  LOOP LineCount=FirstLine TO LastLine
    CurrentLine=SELF.FileMgr.GetLine(LineCount)
    PRINT(RPT:Detail)
    ProgressValue+=1
    DISPLAY(?ProgressValue)
    IF ~(ProgressValue%YieldGrain) THEN YIELD().
  END
  CLOSE(Window)
  ENDPAGE(Report)
  Report{PROP:FlushPreview}=CHOOSE(SELF.PrintPreview=False,True,Previewer.Display())
  CLOSE(Report)
  IF SELF.PrintPreview
    Previewer.Kill
    DISPOSE(Previewer)
  END

kcrAsciiPrintClass.SetTranslator PROCEDURE(TranslatorClass T)

  CODE
  SELF.Translator &= T
