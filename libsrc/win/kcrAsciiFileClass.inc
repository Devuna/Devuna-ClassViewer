
!ABCIncludeFile(KCR)

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

  OMIT('_EndOfInclude_',_kcrAsciiFileClassPresent_)
_kcrAsciiFileClassPresent_   EQUATE(1)

  INCLUDE('ABPOPUP.INC'),ONCE
  INCLUDE('KEYCODES.CLW'),ONCE
  INCLUDE('ABUTIL.INC'),ONCE
  INCLUDE('ABREPORT.INC'),ONCE

! ----------------------------------------------------------------------------
! The kcrAsciiFileClass is used to retrieve data from an ascii file, for display
! by the AsciiViewerClass
! ----------------------------------------------------------------------------

IndexQueue          QUEUE,TYPE
Offset                LONG
Length                USHORT
                    END

DisplayQueue        QUEUE,TYPE
LineNo                STRING(5)
Line                  STRING(255)
Style                 LONG
                    END

kcrAsciiFileClass   CLASS,TYPE,MODULE('kcrAsciiFileClass.clw'),LINK('kcrAsciiFileClass.clw',),DLL(_KCRDllMode_)
AsciiFile             &FILE
Line                  &STRING,PRIVATE
ErrorMgr              &ErrorClass,PROTECTED
IndexQueue            &IndexQueue,PROTECTED
FileSize              UNSIGNED,PRIVATE
NumberBuffers         UNSIGNED,PRIVATE
OpenMode              UNSIGNED

FormatLine            PROCEDURE(*STRING TextLine),PROTECTED,VIRTUAL              !Allows line formating at run-time
FormatLine            PROCEDURE(*STRING TextLine,LONG LineNo),PROTECTED,VIRTUAL  !ditto and supplies line number
GetDOSFilename        PROCEDURE(*STRING Dest),BYTE,VIRTUAL                       !Requests filename from user
GetFilename           PROCEDURE(),STRING
GetLastLineNo         PROCEDURE(),LONG,PROC                                      !returns no of last line in file - forces index of whole file
GetLine               PROCEDURE(LONG Number),STRING,PROC                         !retuns line/ force index to LineNo
GetPercentile         PROCEDURE(LONG Number),USHORT                              !return 0 - 100 (%age through file)
Init                  PROCEDURE(FILE AsciiFile,*STRING TextLine,*STRING Filename,ErrorClass ErrorHandler),BYTE   !,EXTENDS
Kill                  PROCEDURE
Reset                 PROCEDURE(*STRING Filename),BYTE
SetLine               PROCEDURE(LONG Number),VIRTUAL
SetPercentile         PROCEDURE(USHORT Percentage)                               !sets to line %age of way through file
ValidateLine          PROCEDURE(STRING TextLine),BYTE,PROTECTED,VIRTUAL          !Allows line filtering, return true to include line or false to exclude line
                    END

! ----------------------------------------------------------------------------
! The kcrAsciiSearchClass is used to 'step through' the occurances of a search
! string in an ascii file. It is used by the AsciiViewerClass
! ----------------------------------------------------------------------------

AsciiFindGroup      GROUP,TYPE
What                  PSTRING(64)               !text to look for
MatchCase             BYTE                      !case sensitive?
Direction             STRING(4)                 !either 'Up  ' or 'Down'
                    END

kcrAsciiSearchClass CLASS,TYPE,MODULE('kcrAsciiSearchClass.clw'),LINK('kcrAsciiSearchClass.clw',_KCRLinkMode_),DLL(_KCRDllMode_)
FileMgr               &kcrAsciiFileClass,PROTECTED
ErrorMgr              &ErrorClass,PROTECTED
Find                  LIKE(AsciiFindGroup),PROTECTED
LineCounter           LONG,PROTECTED
Translator            &TranslatorClass,PROTECTED

Ask                   PROCEDURE(LONG StartLine = 1),VIRTUAL
Init                  PROCEDURE(kcrAsciiFileClass FileManager, ErrorClass ErrHandler),VIRTUAL
Next                  PROCEDURE(),LONG,VIRTUAL
Setup                 PROCEDURE(*AsciiFindGroup Attributes,LONG StartLine=1)
SetTranslator         PROCEDURE(TranslatorClass Translator)
GetLastSearch         PROCEDURE(*AsciiFindGroup Attributes,*LONG StartLine)
                    END

! ----------------------------------------------------------------------------
! The kcrAsciiPrintClass is use to preview and print data displayed in the
! ascii viewer
! ----------------------------------------------------------------------------

kcrAsciiPrintClass  CLASS,TYPE,MODULE('kcrAsciiPrintClass.clw'),LINK('kcrAsciiPrintClass.clw',_KCRLinkMode_),DLL(_KCRDllMode_)
FileMgr               &kcrAsciiFileClass,PROTECTED
ErrorMgr              &ErrorClass,PROTECTED
Translator            &TranslatorClass,PROTECTED
PrintPreview          BYTE

Init                  PROCEDURE(kcrAsciiFileClass FileManager, ErrorClass ErrHandler),VIRTUAL
Ask                   PROCEDURE,VIRTUAL
PrintLines            PROCEDURE(LONG FirstLine,LONG LastLine),VIRTUAL
SetTranslator         PROCEDURE(TranslatorClass Translator)
                    END

! ----------------------------------------------------------------------------
! The AsciiViewerClass displays an ascii text file in a viewer window. The file
! is read 'as needed', it is not all read when the window opens
! ----------------------------------------------------------------------------

EnableSearch        BYTE(001b)
EnablePrint         BYTE(010b)

PreserveListBoxGroup GROUP,TYPE
IMMState              BYTE             !attribute states
HScrollState          BYTE
HScrollPos            UNSIGNED
VScrollState          BYTE
VScrollPos            UNSIGNED
Alrt                  LONG,DIM(3)
Format                STRING(255)      !list box format string
                    END

kcrAsciiViewerClass CLASS(kcrAsciiFileClass),TYPE,MODULE('kcrAsciiViewerClass.clw'),LINK('kcrAsciiViewerClass.clw',_KCRLinkMode_),DLL(_KCRDllMode_)
DisplayQueue          &DisplayQueue,PRIVATE
LBPreserve            LIKE(PreserveListBoxGroup),PRIVATE
ListBox               UNSIGNED,PRIVATE
ListBoxItems          UNSIGNED,PRIVATE
TopLine               UNSIGNED
Popup                 &PopupClass
Searcher              &kcrAsciiSearchClass
Translator            &TranslatorClass,PRIVATE
Printer               &kcrAsciiPrintClass
SearcherSelfCreated   BYTE,PRIVATE
PrinterSelfCreated    BYTE,PRIVATE

AddItem               PROCEDURE(kcrAsciiPrintClass Printer)
AddItem               PROCEDURE(kcrAsciiSearchClass Searcher)
AskGotoLine           PROCEDURE
DisplayPage           PROCEDURE                                             !displays page from current top line
DisplayPage           PROCEDURE(LONG LineNumber)                            !Displays a new page with LineNo on it
DisplayPage           PROCEDURE(LONG StartLine,LONG EndLine,USHORT SelectLine),PRIVATE
Init                  PROCEDURE(FILE AsciiFile,*STRING FileLine,UNSIGNED ListBox,ErrorClass ErrHandler,BYTE Enables=0),BYTE  !,EXTENDS, !Use wil files with constant NAME() attribute
Init                  PROCEDURE(FILE AsciiFile,*STRING FileLine,*STRING Filename,UNSIGNED ListBox,ErrorClass ErrHandler,BYTE Enables=0),BYTE   !,EXTENDS
Kill                  PROCEDURE
PageDown              PROCEDURE,PROTECTED                                   !Moves down one page
PageUp                PROCEDURE,PROTECTED                                   !Moves up one page
Reset                 PROCEDURE(*STRING Filename),BYTE,PROC
SetDisplayQueueStyle  PROCEDURE(LONG LineNo, *LONG Style),VIRTUAL
SetLine               PROCEDURE(LONG Number),VIRTUAL,PROTECTED
SetLineRelative       PROCEDURE(LONG Number),PROTECTED                      !scrolls LineCount Lines -ve up +ve down
SetListboxSelection   PROCEDURE(LONG SelectLine),PRIVATE
SetThumb              PROCEDURE,PRIVATE
SetTranslator         PROCEDURE(TranslatorClass Translator)
TakeEvent             PROCEDURE(UNSIGNED Event),BYTE,PROC                   !Returns Level:Notify to indicate a cycle required
                    END

!_EndOfInclude_

