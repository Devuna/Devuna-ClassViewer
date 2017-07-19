#TEMPLATE(ABCVIEW,'Devuna ClassViewer Templates'),FAMILY('ABC')
#!
#! ================================================================================
#!                           Devuna ClassViewer Templates
#! ================================================================================
#! Notice : Copyright (C) 2017, Devuna
#!          Distributed under the MIT License (https://opensource.org/licenses/MIT)
#!
#!    This file is part of Devuna-ClassViewer (https://github.com/Devuna/Devuna-DateTimePicker)
#!
#!    Devuna-ClassViewer is free software: you can redistribute it and/or modify
#!    it under the terms of the MIT License as published by
#!    the Open Source Initiative.
#!
#!    Devuna-ClassViewer is distributed in the hope that it will be useful,
#!    but WITHOUT ANY WARRANTY; without even the implied warranty of
#!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#!    MIT License for more details.
#!
#!    You should have received a copy of the MIT License
#!    along with Devuna-ClassViewer.  If not, see <https://opensource.org/licenses/MIT>.
#! ================================================================================
#!
#!
#!
#! ----------------------------------------------------------------
#EXTENSION(UseLocalIni,'Use Local INI File if available'),APPLICATION
#! ----------------------------------------------------------------
#AT(%BeforeInitializingGlobalObjects)
szIniFilename = PATH() & '\ABCVIEW.INI'
IF _access(szIniFilename,0) = -1
#ENDAT
#!
#!
#AT(%ProgramSetup),FIRST
ELSE
   FuzzyMatcher.Init                                        ! Initilaize the browse 'fuzzy matcher'
   FuzzyMatcher.SetOption(MatchOption:NoCase, 1)            ! Configure case matching
   FuzzyMatcher.SetOption(MatchOption:WordOnly, 0)          ! Configure 'word only' matching
   INIMgr.Init(szIniFilename, NVD_INI)
   DctInit
END
#ENDAT
#!
#!
#!
#! ----------------------------------------------------------------
#EXTENSION(OptionalToolTips,'Optional ToolTips'),PROCEDURE,REQ(KCR_ToolTips(KCR))
#! ----------------------------------------------------------------
#BOXED('Default MakeHead Prompts'),AT(0,0),WHERE(%False),HIDE
  #INSERT(%MakeHeadHiddenPrompts)
#ENDBOXED
#PREPARE
  #INSERT (%MakeHead,'OptionalToolTips (ABC)','Optional ToolTips Extension')
#ENDPREPARE
#BOXED('Devuna')
  #INSERT (%Head)
  #DISPLAY ('This template adds code to make tooltips conditional at runtime.'),AT(10)
  #DISPLAY ('')
  #PROMPT('Conditional Global Variable:',FROM(%GlobalData)),%ConditionalGlobalVariable,REQ,AT(80,,110),DEFAULT('glo:bShowTips')
  #PROMPT('ToolTip Delay Time:',@N4),%ToolTipDelayTime,REQ,AT(80),DEFAULT('1000')
#ENDBOXED
#!
#!
#AT(%WindowManagerMethodCodeSection,'Open','()'),PRIORITY(5050),DESCRIPTION('Conditional ToolTip Initialization'),WHERE(NOT %DontApply)
IF %ConditionalGlobalVariable
#ENDAT
#!
#!
#AT(%WindowManagerMethodCodeSection,'Open','()'),PRIORITY(5150),DESCRIPTION('Conditional ToolTip Initialization'),WHERE(NOT %DontApply)
   IF hwndTT
      tt.Activate(%ConditionalGlobalVariable)
      tt.SetDelayTime(TTDT_INITIAL,%ToolTipDelayTime)
   END
END
#ENDAT
#!
#!
#AT(%WindowManagerMethodCodeSection,'Kill','(),BYTE'),PRIORITY(2450),DESCRIPTION('Conditional ToolTip Cleanup'),WHERE(NOT %DontApply)
IF %ConditionalGlobalVariable
#ENDAT
#!
#!
#AT(%WindowManagerMethodCodeSection,'Kill','(),BYTE'),PRIORITY(2550),DESCRIPTION('Conditional ToolTip Cleanup'),WHERE(NOT %DontApply)
END
#ENDAT
#!
#!
#!
#!
#SYSTEM
 #TAB('ClassViewer Templates')
  #INSERT  (%SysHead)
  #BOXED   ('About ClassViewer Templates'),AT(5)
    #DISPLAY (''),AT(15)
    #DISPLAY ('This template 1s free software:                                       '),AT(15)
    #DISPLAY ('You can redistribute it and/or modify it under the terms of the GNU   '),AT(15)
    #DISPLAY ('General Public License as published by the Free Software Foundation,  '),AT(15)
    #DISPLAY (''),AT(15)
    #DISPLAY ('This template is distributed in the hope that they will be useful     '),AT(15)
    #DISPLAY ('but WITHOUT ANY WARRANTY; without even the implied warranty           '),AT(15)
    #DISPLAY ('of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.'),AT(15)
    #DISPLAY (''),AT(15)
    #DISPLAY ('See the MIT License for more details.'),AT(15)
    #DISPLAY ('http://www.gnu.org/licenses/'),AT(15)
    #DISPLAY ('Copyright 2017 Devuna'),AT(15)
  #ENDBOXED
 #ENDTAB
#!-----------------------------------------------------------------------------------------------------------
#GROUP (%MakeHeadHiddenPrompts)
  #PROMPT('',@S50),%TplName
  #PROMPT('',@S100),%TplDescription
#!-----------------------------------------------------------------------------------------------------------
#GROUP   (%MakeHead,%xTplName,%xTplDescription)
  #SET (%TplName,%xTplName)
  #SET (%TplDescription,%xTplDescription)
#!
#!-----------------------------------------------------------------------------------------------------------
#GROUP   (%Head)
  #IMAGE   ('ABCView.ICO'), AT(,,175,26)
  #DISPLAY (%TplName),AT(40,3)
  #DISPLAY ('(C)2017 Devuna'),AT(40,12)
  #DISPLAY ('')
#!
#!-----------------------------------------------------------------------------------------------------------
#GROUP   (%SysHead)
  #IMAGE   ('ABCView.ICO'), AT(,4,175,26)
  #DISPLAY ('ABCVIEW.TPL'),AT(40,4)
  #DISPLAY ('Devuna ClassViewer Templates'),AT(40,14)
  #DISPLAY ('for Clarion ABC Template Applications'),AT(40,24)
  #DISPLAY ('')
#!
#!-----------------------------------------------------------------------------------------------------------
#GROUP(%EmbedStart)
#?!-----------------------------------------------------------------------------------------------------------
#?! ABCVIEW.TPL   (C)2017 Devuna
#?! Template: (%TplName - %TplDescription)
#IF (%EmbedID)
#?! Embed:    (%EmbedID) (%EmbedDescription) (%EmbedParameters)
#ENDIF
#?!-----------------------------------------------------------------------------------------------------------
#!
#!----------------------------------------------------------------------------------------------------------
#GROUP(%EmbedEnd)
#?!-----------------------------------------------------------------------------------------------------------
