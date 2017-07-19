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

! ================================================================================
! ASCII file viewer
! ================================================================================

   MAP
AddRecord      PROCEDURE(kcrAsciiFileClass SELF)             !adds a record to the index queue
IdxExtend      PROCEDURE(kcrAsciiFileClass SELF)             !extends the file index to eof
IdxExtend      PROCEDURE(kcrAsciiFileClass SELF,LONG LineNo),BYTE,PROC !extends the file index to lineNo, returns true if requested line is greater than the number of lines in the file
SetSequence    PROCEDURE(kcrAsciiFileClass SELF)             !sets up sequenctial processing of file
   END

  INCLUDE('kcrAsciiFileClass.inc'),ONCE
  INCLUDE('KEYCODES.CLW'),ONCE


kcrAsciiFileClass.Init PROCEDURE(FILE AsciiFile,*STRING FileLine,*STRING FName,ErrorClass ErrorHandler)

  CODE
  SELF.OpenMode=ReadOnly+DenyNone
  SELF.AsciiFile&=AsciiFile
  SELF.Line&=FileLine
  SELF.ErrorMgr&=ErrorHandler
  SELF.IndexQueue&=NEW(IndexQueue)
  IF ~SELF.Reset(FName)
    SELF.Kill
    RETURN False
  END
  RETURN True


kcrAsciiFileClass.Reset PROCEDURE(*STRING FName)

RVal      BYTE(False)
SavePath  CSTRING(FILE:MaxFilePath+1),AUTO

  CODE
  CLOSE(SELF.AsciiFile)
  FREE(SELF.IndexQueue)
  SavePath=PATH()
  LOOP
    IF ~FName AND ~SELF.GetDOSFilename(FName) THEN BREAK.
    OPEN(SELF.AsciiFile,SELF.OpenMode)
    IF ERRORCODE()
      IF ~INLIST(SELF.ErrorMgr.Throw(Msg:FileLoadFailed),Level:Benign,Level:User) THEN BREAK.
    ELSE
      RVal=True
    END
  UNTIL RVal=True
  IF RVal
    SELF.FileSize=BYTES(SELF.AsciiFile)
    SELF.ErrorMgr.SetFile(NAME(SELF.AsciiFile))
  END
  SETPATH(SavePath)
  RETURN RVal


kcrAsciiFileClass.Kill PROCEDURE

  CODE
  DISPOSE(SELF.IndexQueue)
  CLOSE(SELF.AsciiFile)


!This function gets a line at position LineNo from the Ascii file, extending the index queue as
!required. If the index queue already contains the requested line number then the file is read
!using the existing offset, otherwise th index is extended. If the requested LineNo does not
!exist in the file, the text line is cleared and ERRORCODE() set.
kcrAsciiFileClass.GetLine PROCEDURE(LONG LineNo)

  CODE
  ASSERT(LineNo>0)
  IdxExtend(SELF,LineNo)
  GET(SELF.IndexQueue,LineNo)
  IF ~ERRORCODE()
    GET(SELF.AsciiFile,SELF.IndexQueue.Offset)
    ASSERT(~ERRORCODE())
    SELF.FormatLine(SELF.Line,LineNo)
  END
  RETURN SELF.Line


!This function processes the whole file until the last record is encounted, returning its line
!position, taking into account already indexed items and active filters.
kcrAsciiFileClass.GetLastLineNo PROCEDURE()

  CODE
  IdxExtend(SELF)
  RETURN RECORDS(SELF.IndexQueue)


!This function returns the approximate percentage through the file that LineNo occurs at. Returns 0
!if LineNo=0 and 100 if LineNo>number of filtered lines in the file. Useful for calibrating vertical
!scroll bars.
kcrAsciiFileClass.GetPercentile PROCEDURE(LONG LineNo)

  CODE
  IF LineNo>0
    IdxExtend(SELF,LineNo)
    IF LineNo<=RECORDS(SELF.IndexQueue)
      GET(SELF.IndexQueue,LineNo)
      ASSERT(~ERRORCODE())
      RETURN (SELF.IndexQueue.Offset/SELF.FileSize)*100
    ELSE
      RETURN 100
    END
  END
  RETURN 0


!This procedure synronises the 'focus record' with a given percentage through the file(usually
!the vertical thumb position). The index is extended as required and the the virtual SetLine
!procedure is called with the line number that is the required percentage of the way through the
!file.
kcrAsciiFileClass.SetPercentile PROCEDURE(USHORT Percentage)

TargetLine     LONG(0)
TargetOffset   LONG,AUTO
LCnt           LONG(1)

  CODE
  TargetOffset=SELF.FileSize*(Percentage/100)
  IF TargetOffset>SELF.FileSize THEN TargetOffset=SELF.FileSize.
  IF TargetOffset=SELF.FileSize
    TargetLine=SELF.GetLastLineNo()
  ELSIF TargetOffset=0
    TargetLine=1
  ELSE
    LOOP
      IF LCnt<RECORDS(SELF.IndexQueue)
        GET(SELF.IndexQueue,LCnt)
        ASSERT(~ERRORCODE())
      ELSE
        IF IdxExtend(SELF,RECORDS(SELF.IndexQueue)+1) THEN BREAK.
      END
      LCnt+=1
    UNTIL INRANGE(TargetOffset,SELF.IndexQueue.Offset,SELF.IndexQueue.Offset+SELF.IndexQueue.Length-1)
    TargetLine=POINTER(SELF.IndexQueue)
  END
  SELF.SetLine(TargetLine)


kcrAsciiFileClass.GetFilename PROCEDURE()

  CODE
  RETURN NAME(SELF.AsciiFile)


kcrAsciiFileClass.FormatLine PROCEDURE(*STRING TextLine) !Place holder for users Virtual function

  CODE


kcrAsciiFileClass.FormatLine PROCEDURE(*STRING TextLine,LONG LineNo) !Place holder for users Virtual function

  CODE
  SELF.FormatLine(TextLine)


kcrAsciiFileClass.SetLine PROCEDURE(LONG LineNo) !Place holder for Virtual function

  CODE


kcrAsciiFileClass.ValidateLine PROCEDURE(STRING LineToTest)

  CODE
  RETURN True


kcrAsciiFileClass.GetDOSFilename PROCEDURE(*STRING DestVar)

DOSLookup   SelectFileClass

  CODE
  DOSLookup.Init
  DOSLookup.AddMask('Text files|*.Txt|All files|*.*')
  DOSLookup.WindowTitle='Select an Ascii File'
  DOSLookup.Flags=FILE:LongName
  DestVar=DOSLookup.Ask()
  RETURN CHOOSE(DestVar<>'')


IdxExtend PROCEDURE(kcrAsciiFileClass SELF)

  CODE
  IdxExtend(SELF,0)


IdxExtend PROCEDURE(kcrAsciiFileClass SELF,LONG LineNo)

  CODE
  IF LineNo>RECORDS(SELF.IndexQueue) OR LineNo=0
    SetSequence(SELF)
    LOOP
      IF LineNo AND RECORDS(SELF.IndexQueue)>LineNo THEN BREAK.
      NEXT(SELF.AsciiFile)
      IF ERRORCODE() THEN RETURN True.
      AddRecord(SELF)
    END
  END
  RETURN False


AddRecord PROCEDURE(kcrAsciiFileClass SELF)

  CODE
  IF SELF.ValidateLine(SELF.Line)
    SELF.IndexQueue.Offset=POINTER(SELF.AsciiFile)
    SELF.IndexQueue.Length=BYTES(SELF.AsciiFile)
    ADD(SELF.IndexQueue)
    ASSERT(ERRORCODE()=NoError)
  END


SetSequence PROCEDURE(kcrAsciiFileClass SELF)

  CODE
  IF RECORDS(SELF.IndexQueue)
    GET(SELF.IndexQueue,RECORDS(SELF.IndexQueue))
    ASSERT(ERRORCODE()=NoError)
    SET(SELF.AsciiFile,SELF.IndexQueue.Offset)
    NEXT(SELF.AsciiFile)
  ELSE
    SET(SELF.AsciiFile)
  END
