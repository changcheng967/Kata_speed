@echo off
setlocal enabledelayedexpansion

:: Check for the correct number of arguments
if "%~5"=="" (
    echo Usage: %0 BASEDIR TRAININGNAME MODELKIND BATCHSIZE EXPORTMODE OTHERARGS
    echo BASEDIR containing selfplay data and models and related directories
    echo TRAININGNAME name to prefix models with, specific to this training daemon
    echo MODELKIND what size model to train, like b10c128, see ../modelconfigs.py
    echo BATCHSIZE number of samples to concat together per batch for training, must match shuffle
    echo EXPORTMODE 'main': train and export for selfplay. 'extra': train and export extra non-selfplay model. 'trainonly': train without export
    exit /b 1
)

:: Set variables
set BASEDIR=%1
shift
set TRAININGNAME=%1
shift
set MODELKIND=%1
shift
set BATCHSIZE=%1
shift
set EXPORTMODE=%1
shift

:: Create directories
if not exist "%BASEDIR%\train\%TRAININGNAME%" (
    mkdir "%BASEDIR%\train\%TRAININGNAME%"
)

:: Check if running from snapshot directory
set SNAPSHOTDIR=%CD%
if not "%SNAPSHOTDIR%"=="%BASEDIR%\scripts" (
    for /f "delims=" %%i in ('git rev-parse --show-toplevel') do set GITROOTDIR=%%i

    git show --no-patch --no-color > "%BASEDIR%\train\%TRAININGNAME%\version.txt"
    git diff --no-color > "%BASEDIR%\train\%TRAININGNAME%\diff.txt"
    git diff --staged --no-color > "%BASEDIR%\train\%TRAININGNAME%\diffstaged.txt"

    :: Archive the current state
    set DATE_FOR_FILENAME=%DATE:~10,4%%DATE:~4,2%%DATE:~7,2%-%TIME:~0,2%%TIME:~3,2%
    set DATED_ARCHIVE=%BASEDIR%\scripts\train\dated\%DATE_FOR_FILENAME%
    mkdir "%DATED_ARCHIVE%"
    copy "%GITROOTDIR%\python\*.py" "%DATED_ARCHIVE%"
    copy "%GITROOTDIR%\python\selfplay\train.sh" "%DATED_ARCHIVE%"
    git show --no-patch --no-color > "%DATED_ARCHIVE%\version.txt"
    git diff --no-color > "%DATED_ARCHIVE%\diff.txt"
    git diff --staged --no-color > "%DATED_ARCHIVE%\diffstaged.txt"
    cd /d "%DATED_ARCHIVE%"
)

:: Set export mode
if "%EXPORTMODE%"=="main" (
    set EXPORT_SUBDIR=torchmodels_toexport
    set EXTRAFLAG=
) else if "%EXPORTMODE%"=="extra" (
    set EXPORT_SUBDIR=torchmodels_toexport_extra
    set EXTRAFLAG=
) else if "%EXPORTMODE%"=="trainonly" (
    set EXPORT_SUBDIR=torchmodels_toexport_extra
    set EXTRAFLAG=-no-export
) else (
    echo EXPORTMODE was not 'main' or 'extra' or 'trainonly', run with no arguments for usage
    exit /b 1
)

:: Run the training
python "%GITROOTDIR%\python\train.py" ^
     -traindir "%BASEDIR%\train\%TRAININGNAME%" ^
     -datadir "%BASEDIR%\shuffleddata\current\" ^
     -exportdir "%BASEDIR%\%EXPORT_SUBDIR%" ^
     -exportprefix "%TRAININGNAME%" ^
     -pos-len 19 ^
     -batch-size "%BATCHSIZE%" ^
     -model-kind "%MODELKIND%" ^
     %EXTRAFLAG% ^
     %*
     2>&1 | tee -a "%BASEDIR%\train\%TRAININGNAME%\stdout.txt"

endlocal
exit /b 0
