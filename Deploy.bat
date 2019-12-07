@rem - Encoding:utf-8; Mode:Batch; Language:zh-CN,en; LineEndings:CRLF -
:: Video Downloaders (You-Get, Youtube-dl, Annie) One-Click Deployment Batch (Windows)
:: Author: Lussac (https://blog.lussac.net)
:: Version: 1.4.0
:: Last updated: 2019-12-07
:: >>> Get updated from: https://github.com/LussacZheng/video-downloader-deploy <<<
:: >>> EDIT AT YOUR OWN RISK. <<<
@echo off
setlocal EnableDelayedExpansion
set "version=1.4.0"
set "lastUpdated=2019-12-07"
:: Remote resources url of 'sources.txt', 'wget.exe', '7za.exe', 'scripts/CurrentVersion'
set "_RemoteRes_=https://raw.githubusercontent.com/LussacZheng/video-downloader-deploy/master/res"


rem ================= Preparation =================


REM mode con cols=100 lines=40

:: Get %_Language_% , %_Region_% , %_SystemType_%
if exist res\deploy.settings (
    for /f "tokens=2 delims= " %%i in ('findstr /i "Language" res\deploy.settings') do ( set "_Language_=%%i" )
) else ( call res\scripts\LanguageSelector.bat )
:: Import translation text
call res\scripts\lang_%_Language_%.bat
if exist res\deploy.settings (
    for /f "tokens=2 delims= " %%i in ('findstr /i "Region" res\deploy.settings') do ( set "_Region_=%%i" )
)
call res\scripts\SystemTypeSelector.bat

:: Start of Deployment
title %str_title%  -- By Lussac
:: py=python, yg=you-get, yd=youtube-dl, an=annie, ff=ffmpeg, pip=pip
set "root=%cd%"
set "pyBin=%root%\usr\python-embed"
set "ygBin=%root%\usr\you-get"
set "ydBin=%root%\usr\youtube-dl"
set "anBin=%root%\usr"
set "ffBin=%root%\usr\ffmpeg\bin"

:: If already deployed, show more info in Option3.
set "opt3_info="
if NOT exist res\deploy.log goto MENU
cd res && call :Get_DeployMode
if "%DeployMode%"=="portable" set "opt3_info=(you-get,youtube-dl,annie)"
if "%DeployMode%"=="quickstart" set "opt3_info=(you-get)"
if "%DeployMode%"=="withpip" set "opt3_info=(you-get,youtube-dl,annie)"


rem ================= Menu =================


:MENU
cd "%root%"
cls
REM echo %_Language_% & echo %_Region_%
echo ====================================================
echo ====================================================
echo ======%str_titleExpanded%=======
echo ====================================================
echo ===================  By Lussac  ====================
echo ====================================================
echo ==========  version: %version% (%lastUpdated%)  ===========
echo ====================================================
echo ====================================================
echo.
echo. & echo  [1?] %str_opt1%
        echo    ^|
        echo    ^|-- [11] %str_portable%: you-get + youtube-dl + annie
        echo    ^|        ( %str_opt11% ) 
        echo    ^|
        echo    ^|-- [12] %str_quickstart%: you-get
        echo    ^|        ( %str_opt12% )
        echo    ^|
        echo    ^|-- [13] %str_withpip%: you-get + youtube-dl + annie
        echo             ( %str_opt13% )
echo. & echo  [2] %str_opt2%
echo. & echo  [3] %str_opt3% %opt3_info%
echo. & echo  [4] %str_opt4%
echo. & echo  [5] %str_opt5%
echo. & echo  [6] %str_opt6%
echo. & echo.
echo ====================================================
set choice=0
set /p choice= %str_please-choose%
echo.
if "%choice%"=="1" goto InitDeploy
if "%choice%"=="11" goto InitDeploy-portable
if "%choice%"=="12" goto InitDeploy-quickstart
if "%choice%"=="13" goto InitDeploy-withpip
if "%choice%"=="2" goto InitDeploy-ffmpeg
if "%choice%"=="3" goto Upgrade
if "%choice%"=="4" goto Reset_dl-bat
if "%choice%"=="5" goto Update
if "%choice%"=="6" goto Setting
echo. & echo %str_please-input-valid-num%
pause > NUL
goto MENU


rem ================= OPTION 1 =================


:InitDeploy
echo. & echo %str_please-choose-from%
goto _ReturnToMenu_


rem ================= OPTION 11 =================


:InitDeploy-portable
set "DeployMode=portable"
call :ExitIfInit
cd res && call :Common
if NOT exist "%pyBin%" call scripts\DoDeploy.bat Setup python
if NOT exist "%ygBin%" call scripts\DoDeploy.bat Setup youget
if NOT exist "%ydBin%" call scripts\DoDeploy.bat Setup youtubedl
if NOT exist "%anBin%\annie.exe" call scripts\DoDeploy.bat Setup annie
goto InitLog


rem ================= OPTION 12 =================


:InitDeploy-quickstart
set "DeployMode=quickstart"
call :ExitIfInit
cd res && call :Common
if NOT exist "%pyBin%" call scripts\DoDeploy.bat Setup python
if NOT exist "%ygBin%" call scripts\DoDeploy.bat Setup youget
goto InitLog


rem ================= OPTION 13 =================


:InitDeploy-withpip
set "DeployMode=withpip"
call :ExitIfInit
cd res
if exist scripts\get-pip.py (
    if NOT exist download md download
    xcopy /Y scripts\get-pip.py download\ > NUL
)
call :Common
if NOT exist "%pyBin%" call scripts\DoDeploy.bat Setup python
if NOT exist "%anBin%\annie.exe" call scripts\DoDeploy.bat Setup annie

:edit-python_pth
pushd "%pyBin%"
:: Get the full name of "python3*._pth" -> %py_pth%
for /f "delims=" %%i in ('dir /b python*._pth') do ( set "py_pth=%%i" )
copy %py_pth% %py_pth%.bak > NUL
type NUL > %py_pth%
for /f "delims=" %%i in (%py_pth%.bak) do (
    set "py_pth_str=%%i"
    set py_pth_str=!py_pth_str:#import=import!
    echo !py_pth_str!>>%py_pth%
)
del /Q %py_pth%.bak >NUL 2>NUL

:get-pip
xcopy /Y "%root%\res\download\get-pip.py" "%pyBin%" > NUL
set "PATH=%pyBin%;%pyBin%\Scripts;%PATH%"
if "%_Region_%"=="cn" set "pip_option=--index-url=https://pypi.tuna.tsinghua.edu.cn/simple"
python get-pip.py %pip_option%
pip3 install --upgrade you-get %pip_option%
pip3 install --upgrade youtube-dl %pip_option%
echo You-Get %str_already-deploy% & echo Youtube-dl %str_already-deploy%
del /Q get-pip.py >NUL 2>NUL
popd && goto InitLog


rem ================= OPTION 11-13 InitLog =================


:InitLog
call scripts\Log.bat Init %DeployMode%
cd .. && call :Create_Download-bat 1
goto _ReturnToMenu_


rem ================= OPTION 2 =================


:InitDeploy-ffmpeg
:: Check whether FFmpeg already exists
echo %PATH% | findstr /i "ffmpeg" >NUL && goto ffmpeg-exists
if exist "%ffBin%\ffmpeg.exe" goto ffmpeg-exists

call :AskForInit
cd res && call :Common_wget
echo %str_downloading%...
call :Common_7za
call scripts\SourcesSelector.bat sources.txt ffmpeg %_Region_% %_SystemType_% download\to-be-downloaded.txt
wget %_WgetOptions_% -i download\to-be-downloaded.txt -P download
call scripts\DoDeploy.bat Setup ffmpeg
call scripts\Log.bat Init ffmpeg

echo. 
echo ====================================================
echo FFmpeg %str_already-deploy%
echo ====================================================
goto _ReturnToMenu_

:ffmpeg-exists
echo. & echo FFmpeg %str_already-exist%
goto _ReturnToMenu_


rem ================= OPTION 3 =================


:Upgrade
call :AskForInit
cd res && call :Common_wget && call :Common_7za
call :StopIfDisconnected
call :Get_DeployMode
set "whetherToLog=false"
echo %str_checking-update%...
if "%DeployMode%"=="portable" goto Upgrade-portable
if "%DeployMode%"=="quickstart" goto Upgrade-quickstart
if "%DeployMode%"=="withpip" goto Upgrade-withpip

:upgrade_Manually
set opt3_choice=0
set /p opt3_choice= %str_please-set-DeployMode%
if "%opt3_choice%"=="11" ( set "DeployMode=portable" && goto Upgrade-portable )
if "%opt3_choice%"=="12" ( set "DeployMode=quickstart" && goto Upgrade-quickstart )
if "%opt3_choice%"=="13" ( set "DeployMode=withpip" && goto Upgrade-withpip )
goto upgrade_Manually


:Upgrade-portable
:: Get %_isYgLatestVersion% , %_isYdLatestVersion% , %_isAnLatestVersion%
:: from "scripts\CheckUpdate.bat". 0: false; 1: true.
call scripts\CheckUpdate.bat youget
call scripts\CheckUpdate.bat youtubedl
call scripts\CheckUpdate.bat annie
if "%_isYgLatestVersion%"=="1" if "%_isYdLatestVersion%"=="1" if "%_isAnLatestVersion%"=="1" (
    echo you-get %str_is-latestVersion%: v%ygCurrentVersion%
    echo youtube-dl %str_is-latestVersion%: %ydCurrentVersion%
    echo annie %str_is-latestVersion%: v%anCurrentVersion%
    goto upgrade_done
)
set "whetherToLog=true"
if "%_isYgLatestVersion%"=="0" call scripts\DoDeploy.bat Upgrade youget
if "%_isYdLatestVersion%"=="0" call scripts\DoDeploy.bat Upgrade youtubedl
if "%_isAnLatestVersion%"=="0" call scripts\DoDeploy.bat Upgrade annie
goto upgrade_done


:Upgrade-quickstart
call scripts\CheckUpdate.bat youget
if "%_isYgLatestVersion%"=="1" (
    echo you-get %str_is-latestVersion%: v%ygCurrentVersion%
) else (
    set "whetherToLog=true"
    call scripts\DoDeploy.bat Upgrade youget
)
goto upgrade_done


:Upgrade-withpip
call scripts\CheckUpdate.bat annie
if "%_isAnLatestVersion%"=="1" (
    echo annie %str_is-latestVersion%: v%anCurrentVersion%
) else (
    set "whetherToLog=true"
    call scripts\DoDeploy.bat Upgrade annie
)

:: Re-create a pip3.cmd in case of the whole folder had been moved.
pushd "%root%\usr"
set "PATH=%root%\usr\command;%pyBin%;%pyBin%\Scripts;%PATH%"
if NOT exist command\ md command
cd command
echo @"%pyBin%\python.exe" "%pyBin%\Scripts\pip3.exe" %%*> pip3.cmd
:: OR  echo @python ..\python-embed\Scripts\pip3.exe %%*> pip3.cmd
if "%_Region_%"=="cn" set "pip_option=--index-url=https://pypi.tuna.tsinghua.edu.cn/simple"
echo pip3 install --upgrade you-get %pip_option%> upgrade_you-get.bat
echo pip3 install --upgrade youtube-dl %pip_option%> upgrade_youtube-dl.bat
:: Directly use "pip3 install --upgrade you-get" here will crash for some unknown reason.
:: So write the command into a bat and then call it.
call upgrade_you-get.bat && call upgrade_youtube-dl.bat
echo You-Get %str_already-upgrade% & echo Youtube-dl %str_already-upgrade%
popd && goto upgrade_done


:upgrade_done
if "%whetherToLog%"=="true" call scripts\Log.bat Upgrade %DeployMode%
echo. & echo. & echo %str_upgrade-ok%
goto _ReturnToMenu_


rem ================= OPTION 4 =================


:Reset_dl-bat
call :AskForInit
cd res && call :Get_DeployMode
if NOT "%DeployMode%"=="unknown" goto create_dl-bat

:reset_dl-bat_Manually
set opt4_choice=0
set /p opt4_choice= %str_please-set-DeployMode%
if "%opt4_choice%"=="11" ( set "DeployMode=portable" && goto create_dl-bat )
if "%opt4_choice%"=="12" ( set "DeployMode=quickstart" && goto create_dl-bat )
if "%opt4_choice%"=="13" ( set "DeployMode=withpip" && goto create_dl-bat )
goto reset_dl-bat_Manually

:create_dl-bat
cd .. && call :Create_Download-bat 0
goto _ReturnToMenu_


rem ================= OPTION 5 =================


:Update
cd res && call :Common_wget
echo %str_checking-update%...
:: Get %_isLatestVersion% from "scripts\CheckUpdate.bat". 0: false; 1: true.
call scripts\CheckUpdate.bat self
if "%_isLatestVersion%"=="1" (
    echo %str_bat-is-latest%
    echo %str_open-webpage1%...
) else (
    echo %str_bat-can-update-to% %latestVersion%
    echo %str_open-webpage2%...
)
pause > NUL
start https://github.com/LussacZheng/video-downloader-deploy
goto _ReturnToMenu_


rem ================= OPTION 6 =================


:Setting
cls
echo ====================================================
echo ===============%str_opt6-Expanded%===============
echo ====================================================
echo.
echo. & echo  [0] %str_opt6_opt0%
echo. & echo  [1] %str_opt6_opt1%
echo. & echo  [2] %str_opt6_opt2%
echo. & echo  [3] %str_opt6_opt3%
echo. & echo  [4] %str_opt6_opt4%
echo. & echo  [5] %str_opt6_opt5%
echo. & echo  [6] %str_opt6_opt6%
if NOT "%DeployMode%"=="withpip" ( echo. & echo  [7] %str_opt6_opt7% )
echo. & echo  [99] %str_opt6_opt99%
echo. & echo.
echo ====================================================
set opt6_choice=-1
set /p opt6_choice= %str_please-choose%
echo.
if "%opt6_choice%"=="0" goto MENU
if "%opt6_choice%"=="99" goto setting_Reset
if "%opt6_choice%"=="1" goto setting_Language
if "%opt6_choice%"=="11" ( call res\scripts\Config.bat Language en && goto _PleaseRerun_ )
if "%opt6_choice%"=="12" ( call res\scripts\Config.bat Language zh && goto _PleaseRerun_ )
if "%opt6_choice%"=="2" goto setting_Region
if "%opt6_choice%"=="21" ( call res\scripts\Config.bat Region origin && goto _PleaseRerun_ )
if "%opt6_choice%"=="22" ( call res\scripts\Config.bat Region cn && goto _PleaseRerun_ )
if "%opt6_choice%"=="3" goto setting_ProxyHint
if "%opt6_choice%"=="4" goto setting_FFmpeg
if "%opt6_choice%"=="5" goto setting_Wget
if "%opt6_choice%"=="50" goto setting_Wget2
if "%opt6_choice%"=="6" goto setting_NetTest
if "%opt6_choice%"=="7" goto setting_UpgradeOnlyViaGitHub
echo. & echo %str_please-input-valid-num%
goto _ReturnToSetting_


:setting_Reset
set opt6_opt99_choice=0
echo %str_reset-settings_1%
set /p opt6_opt99_choice= %str_reset-settings_2%
echo.
if /i "%opt6_opt99_choice%"=="Y" (
    del /Q res\deploy.settings >NUL 2>NUL
    echo %str_reset-settings_3%
) else echo %str_reset-settings_4%
goto _ReturnToSetting_

:setting_Language
echo %str_please-select-language%
goto _ReturnToSetting_

:setting_Region
echo %str_current-region% %_Region_%
echo %str_please-select-region%
goto _ReturnToSetting_

:setting_ProxyHint
call res\scripts\Config.bat ProxyHint
goto _ReturnToSetting_

:setting_FFmpeg
call res\scripts\Config.bat FFmpeg
goto _ReturnToSetting_

:setting_Wget
echo. & echo %str_wget-option-is%
set "_WgetOptions_="
cd res && call :Get_WgetOptions
echo. & echo "%_WgetOptions_%"
if NOT exist wget.opt ( call scripts\GenerateWgetOptions.bat )
cd ..
echo. & echo %str_please-edit-wget-opt_1%
echo %str_please-edit-wget-opt_2%
echo %str_please-edit-wget-opt_3%
goto _ReturnToSetting_

:setting_Wget2
cd res && call scripts\GenerateWgetOptions.bat
cd .. && echo %str_reset-wget-opt-ok%
goto _ReturnToSetting_

:setting_NetTest
call res\scripts\Config.bat NetTest
goto _ReturnToSetting_

:setting_UpgradeOnlyViaGitHub
call res\scripts\Config.bat UpgradeOnlyViaGitHub
goto _ReturnToSetting_


rem ================= FUNCTIONS =================


:_ReturnToMenu_
pause > NUL
goto MENU


:_ReturnToSetting_
pause > NUL
goto Setting


:_PleaseRerun_
echo. & echo %str_exit%
pause > NUL
exit


:: Please make sure that: only call :Common* when %cd% is "res\".
:Common
call :Common_wget
echo %str_downloading%...
call :Common_7za
:: %_Region_% was set in res\scripts\lang_%_Language_%.bat
call scripts\SourcesSelector.bat sources.txt %DeployMode% %_Region_% %_SystemType_% download\to-be-downloaded.txt
:: https://stackoverflow.com/questions/4686464/how-to-show-wget-progress-bar-only
wget %_WgetOptions_% -i download\to-be-downloaded.txt -P download
:: if exist .wget-hsts del .wget-hsts
goto :eof


:Common_wget
:: Make sure the existence of res\wget.exe
if NOT exist wget.exe (
    echo %str_downloading% "wget.exe", %str_please-wait%...
    REM :: use ^) instead of )
    REM powershell (New-Object Net.WebClient^).DownloadFile('%_RemoteRes_%/wget.exe', 'wget.exe'^)
    powershell -command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; (new-object System.Net.WebClient).DownloadFile('%_RemoteRes_%/wget.exe','wget.exe')"
)
call :Get_WgetOptions
goto :eof


:Common_7za
:: Make sure the existence of res\7za.exe, res\download\7za.exe
if NOT exist 7za.exe (
    wget %_WgetOptions_% %_RemoteRes_%/7za.exe
)
if NOT exist download\7za.exe (
    xcopy 7za.exe download\ > NUL
)
goto :eof


:Create_Download-bat
set isInInitDeploy=%~1
call res\scripts\GenerateDownloadBatch.bat %DeployMode%
echo.
echo ====================================================
if "%isInInitDeploy%"=="1" echo %str_deploy-ok%
echo %str_dl-bat-created%
echo ====================================================
goto :eof


:ExitIfInit
:: Check whether already InitDeploy,
if exist usr (
    echo. & echo %str_please-re-init%
    call :_PleaseRerun_
)
goto :eof


:AskForInit
if NOT exist usr (
    echo. & echo %str_please-init%
    pause > NUL
    goto MENU
)
goto :eof


:StopIfDisconnected
if exist deploy.settings (
    for /f "tokens=2 delims= " %%i in ('findstr /i "NetTest" deploy.settings') do ( set "state_netTest=%%i" )
)
if "%state_netTest%"=="disable" goto :eof
echo %str_checking-connection%...
wget -q --no-check-certificate %_RemoteRes_%/scripts/CurrentVersion -O NetTest && set "_isNetConnected=true" || set "_isNetConnected=false"
if exist NetTest del NetTest
if "%_isNetConnected%"=="false" (
    echo %str_please-check-connection%
    pause > NUL
    goto MENU
)
goto :eof


:Get_DeployMode
:: Get %DeployMode% from res\deploy.log
if exist deploy.log (
    for /f "tokens=2 delims= " %%i in ('findstr /i "DeployMode" deploy.log') do ( set "DeployMode=%%i" )
) else ( set "DeployMode=unknown" )
goto :eof


:Get_WgetOptions
:: Get default options for 'wget.exe' from res\wget.opt
if exist wget.opt (
    for /f "eol=# delims=" %%i in (wget.opt) do ( set "_WgetOptions_=%%i" && goto :eof )    
) else ( set "_WgetOptions_=-q --show-progress --progress=bar:force:noscroll --no-check-certificate -nc" )
goto :eof


rem ================= End of File =================