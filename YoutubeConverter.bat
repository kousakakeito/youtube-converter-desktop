@echo off

REM バックカラーを緑、文字色を黒に設定
color 20

REM プロセスIDを保存するための一時ファイル
set pidFile=%temp%\batch_pids.txt
del "%pidFile%" >nul 2>&1

echo Running php_serve.bat in hidden mode...
call :runHidden "cmd\php_serve.bat" php

echo Running npm_dev.bat in hidden mode...
call :runHidden "cmd\npm_dev.bat" node

echo Running php_queue.bat in hidden mode...
call :runHidden "cmd\php_queue.bat" php

echo Waiting for all scripts to finish...

REM スクリプトが終了するまで待つ
timeout /t 3 /nobreak > nul

REM 各バッチファイルが完了したらChromeを開く
echo Opening Chrome and navigating to http://127.0.0.1:8000
start "" "chrome" "http://127.0.0.1:8000"

echo All scripts have been launched and Chrome is opened.
pause

REM バックグラウンドプロセスを停止
echo Stopping background processes...

REM Node.js JavaScript Runtime のプロセスを終了
for /f "tokens=2 delims=," %%a in ('tasklist /fi "imagename eq node.exe" /fo csv /nh') do (
    echo Killing Node.js PID %%a
    taskkill /F /PID %%~a
)

REM Windows コマンドプロセッサ (cmd.exe) のプロセスを終了
for /f "tokens=2 delims=," %%a in ('tasklist /fi "imagename eq cmd.exe" /fo csv /nh') do (
    echo Killing CMD PID %%a
    taskkill /F /PID %%~a
)

REM PHP CLI のプロセスを終了
for /f "tokens=2 delims=," %%a in ('tasklist /fi "imagename eq php.exe" /fo csv /nh') do (
    echo Killing PHP CLI PID %%a
    taskkill /F /PID %%~a
)

del "%pidFile%" >nul 2>&1
exit

:runHidden
REM 引数で渡されたバッチファイルを非表示で実行
setlocal
set script=%temp%\runHidden.vbs

REM 非表示でバッチファイルを実行し、そのPIDを記録
echo CreateObject("WScript.Shell").Run """" ^& WScript.Arguments(0) ^& """", 0, False > "%script%"
cscript //nologo "%script%" "%~1"
del "%script%" >nul 2>&1

REM プロセスIDの取得
set procName=%2
for /f "tokens=2 delims=," %%a in ('tasklist /fi "imagename eq %procName%.exe" /fo csv /nh ^| findstr /i "%procName%"') do (
    set "pid=%%~a"
    set "pid=%pid:~1,-1%"  REM Remove quotes
    echo %pid% >> %pidFile%
)

endlocal
exit /b
