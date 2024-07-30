@echo off
setlocal enabledelayedexpansion

:: Check for the correct number of arguments
if "%~6"=="" (
    echo Usage: %~nx0 BASEDIR TRAININGNAME MODELKIND BATCHSIZE EXPORTMODE OTHERARGS
    echo BASEDIR containing selfplay data and models and related directories
    echo TRAININGNAME name to prefix models with, specific to this training daemon
    echo MODELKIND what size model to train, like b10c128, see ../modelconfigs.py
    echo BATCHSIZE number of samples to concat together per batch for training, must match shuffle
    echo EXPORTMODE 'main': train and export for selfplay. 'extra': train and export extra non-selfplay model. 'trainonly': train without export
    exit /b 1
)

:: Set variables
set "BASEDIR=%~1"
set "TRAININGNAME=%~2"
set "MODELKIND=%~3"
set "BATCHSIZE=%~4"
set "EXPORTMODE=%~5"
shift /5

:: Output debug information
echo BASEDIR: %BASEDIR%
echo TRAININGNAME: %TRAININGNAME%
echo MODELKIND: %MODELKIND%
echo BATCHSIZE: %BATCHSIZE%
echo EXPORTMODE: %EXPORTMODE%

:: Create the necessary directories
if not exist "%BASEDIR%\train\%TRAININGNAME%" (
    mkdir "%BASEDIR%\train\%TRAININGNAME%"
)

:: Set export and extra flag based on EXPORTMODE
if "%EXPORTMODE%"=="main" (
    set "EXPORT_SUBDIR=torchmodels_toexport"
    set "EXTRAFLAG="
) else if "%EXPORTMODE%"=="extra" (
    set "EXPORT_SUBDIR=torchmodels_toexport_extra"
    set "EXTRAFLAG="
) else if "%EXPORTMODE%"=="trainonly" (
    set "EXPORT_SUBDIR=torchmodels_toexport_extra"
    set "EXTRAFLAG=-no-export"
) else (
    echo EXPORTMODE was not 'main' or 'extra' or 'trainonly', run with no arguments for usage
    exit /b 1
)

:: Check if MODELKIND is correct
if not "%MODELKIND%"=="b20c256" (
    echo Incorrect MODELKIND. Expected b20c256 but got %MODELKIND%.
    exit /b 1
)

:: Verify train.py location
if not exist "%BASEDIR%\python\train.py" (
    echo train.py not found in the current directory.
    exit /b 1
)

:: Run the training script
python "%BASEDIR%\python\train.py" ^
    -traindir "%BASEDIR%\train\%TRAININGNAME%" ^
    -datadir "%BASEDIR%\shuffleddata\current\" ^
    -exportdir "%BASEDIR%\%EXPORT_SUBDIR%" ^
    -exportprefix "%TRAININGNAME%" ^
    -pos-len 19 ^
    -batch-size "%BATCHSIZE%" ^
    -model-kind "%MODELKIND%" ^
    %EXTRAFLAG% ^
    %* 2>&1 | tee -a "%BASEDIR%\train\%TRAININGNAME%\stdout.txt"

exit /b 0
