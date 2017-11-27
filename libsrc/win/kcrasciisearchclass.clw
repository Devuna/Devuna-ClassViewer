!Ascii Search Code

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

  INCLUDE('kcrAsciiFileClass.inc'),ONCE


kcrAsciiSearchClass.Init PROCEDURE(kcrAsciiFileClass FileMgr, ErrorClass ErrHandler)

  CODE
  SELF.FileMgr &= FileMgr
  SELF.ErrorMgr &= ErrHandler
  CLEAR(SELF.Find.What)
  SELF.Find.MatchCase=False
  SELF.Find.Direction='Down'


kcrAsciiSearchClass.Ask PROCEDURE(LONG StartLine)

OmitWindow      BYTE(False)
Quit            BYTE,AUTO
WinXPos         SIGNED,AUTO
WinYPos         SIGNED,AUTO
WinInit         BYTE(False)

FindOptions WINDOW('Find'),AT(,,239,46),FONT('MS Sans Serif',8,,FONT:regular),CENTER,IMM,GRAY,DOUBLE
       PROMPT('Find What:'),AT(4,9,40,12),USE(?Prompt1)
       ENTRY(@s32),AT(48,4,144,12),USE(SELF.Find.What),IMM
       CHECK('Match &Case'),AT(4,22,92,14),USE(SELF.Find.MatchCase)
       OPTION('&Direction'),AT(100,17,92,25),USE(SELF.Find.Direction),BOXED
         RADIO('&Up'),AT(112,30),USE(?Radio1),VALUE('Up')
         RADIO('&Down'),AT(148,30),USE(?Radio2),VALUE('Down')
       END
       BUTTON('&Cancel'),AT(196,22,40,14),USE(?CancelButton)
       BUTTON('&Next'),AT(196,4,40,13),USE(?NextButton),DEFAULT
     END

  CODE
  SELF.LineCounter=StartLine
  IF ~SELF.Find.Direction THEN SELF.Find.Direction='Down'.
  LOOP
    IF ~OmitWindow
      OPEN(FindOptions)
      IF WinInit
        SETPOSITION(0,WinXPos,WinYPos)
      ELSE
        GETPOSITION(0,WinXPos,WinYPos)
        WinInit=True
       END
      IF ~SELF.Translator&=NULL THEN SELF.Translator.TranslateWindow.
      ACCEPT
        CASE KEYCODE()
        OF EscKey
           Quit=True
           BREAK
        END
        CASE EVENT()
        OF EVENT:OpenWindow
          SELECT(?SELF:Find:What)
        OF EVENT:Accepted
          CASE FIELD()
          OF ?NextButton
            IF KEYCODE() = EscKey
               Quit = TRUE
            ELSE
               Quit=False
            END
            POST(EVENT:CloseWindow)
          OF ?CancelButton
            Quit=True
            POST(EVENT:CloseWindow)
          END
        OF EVENT:Moved
          GETPOSITION(0,WinXPos,WinYPos)
        END
        UPDATE(?SELF:Find:What)
        ?NextButton{PROP:Disable}=CHOOSE(SELF.Find.What='')
      END
      CLOSE(FindOptions)
    END
    OmitWindow=False
    IF Quit
      BREAK
    ELSE
      SELF.LineCounter=SELF.Next()
      IF SELF.LineCounter
        SELF.FileMgr.SetLine(SELF.LineCounter)
      ELSE
        CASE SELF.ErrorMgr.Throw(CHOOSE(SELF.Find.Direction='Down',Msg:SearchReachedEnd,Msg:SearchReachedBeginning))
        OF Level:Benign
          SELF.LineCounter=CHOOSE(SELF.Find.Direction='Down',1,SELF.FileMgr.GetLastLineNo())
          OmitWindow=True
        OF Level:Cancel
          BREAK
        ELSE
          ASSERT(False) !Unexpected return value from ErrorMgr.Throw()
        END
      END
    END
  END


kcrAsciiSearchClass.Setup PROCEDURE(*AsciiFindGroup FindAttrib,LONG StartLine)

  CODE
  SELF.Find :=: FindAttrib
  SELF.LineCounter=StartLine


kcrAsciiSearchClass.Next PROCEDURE()

Cnt         LONG(0)
CurrentLine CSTRING(256),AUTO

  CODE
  IF SELF.LineCounter>0 AND SELF.Find.What
    Cnt=SELF.LineCounter
    LOOP
      Cnt+=(CHOOSE(SELF.Find.Direction='Down',1,-1))
      IF Cnt>0
        CurrentLine=SELF.FileMgr.GetLine(Cnt)
        IF ERRORCODE()
          RETURN 0
        ELSIF (~SELF.Find.MatchCase AND INSTRING(UPPER(CLIP(SELF.Find.What)),UPPER(CurrentLine),1,1)) OR INSTRING(CLIP(SELF.Find.What),CurrentLine,1,1)
          BREAK
        END
      ELSE
        BREAK
      END
    END
  END
  RETURN CHOOSE(Cnt<=0,0,Cnt)


kcrAsciiSearchClass.SetTranslator PROCEDURE(TranslatorClass T)

  CODE
  SELF.Translator &= T


kcrAsciiSearchClass.GetLastSearch   PROCEDURE(*AsciiFindGroup FindAttrib,*LONG StartLine)

szSearchString  CSTRING(64)

  CODE
  szSearchString  = SELF.Find.What
  FindAttrib.What = szSearchString
  FindAttrib.Direction = SELF.Find.Direction
  FindAttrib.MatchCase = SELF.Find.MatchCase
  StartLine = SELF.LineCounter
