@echo off
setlocal enabledelayedexpansion

REM Define supported versions for CUDA, cuDNN, and TensorRT
set "SUPPORTED_CUDA_VERSION=12.1"
set "SUPPORTED_CUDNN_VERSION=8.6"
set "SUPPORTED_TENSORRT_VERSION=8.7"

REM Define CUDA, cuDNN, and TensorRT versions to install
set "CUDA_VERSION=12.1"
set "CUDA_INSTALLER=cuda_%CUDA_VERSION%.0_496.13_win10.exe"
set "CUDA_URL=https://developer.download.nvidia.com/compute/cuda/%CUDA_VERSION%.0/local_installers/%CUDA_INSTALLER%"

set "CUDNN_VERSION=8.6.2"
set "CUDNN_INSTALLER=cudnn-%CUDNN_VERSION%-windows-x64-v8.6.2.39.zip"
set "CUDNN_URL=https://developer.download.nvidia.com/compute/redist/cudnn/v8.6.2/%CUDNN_INSTALLER%"

set "TENSORRT_VERSION=8.7.2"
set "TENSORRT_INSTALLER=nv-tensorrt-repo-windows-%TENSORRT_VERSION%-cuda%cuda_short_version%-trt8.7.2_20220222.zip"
set "TENSORRT_URL=https://developer.download.nvidia.com/compute/machine-learning/tensorrt/secure/8.7.2/local_repos/nv-tensorrt-repo-windows-%TENSORRT_VERSION%-cuda%cuda_short_version%-trt8.7.2_20220222.zip"

REM Output formatting and logging
echo Solving Unsupported CUDA v%CUDA_VERSION%, cuDNN v%CUDNN_VERSION%, and TensorRT v%TENSORRT_VERSION% Issue for Kata_speed

REM Step 0: Check if the selected versions are supported
if "%CUDA_VERSION%" lss "%SUPPORTED_CUDA_VERSION%" (
    echo Error: kata_speed does not support CUDA versions older than %SUPPORTED_CUDA_VERSION%.
    exit /b 1
)

if "%CUDNN_VERSION%" lss "%SUPPORTED_CUDNN_VERSION%" (
    echo Error: kata_speed does not support cuDNN versions older than %SUPPORTED_CUDNN_VERSION%.
    exit /b 1
)

if "%TENSORRT_VERSION%" lss "%SUPPORTED_TENSORRT_VERSION%" (
    echo Error: kata_speed does not support TensorRT versions older than %SUPPORTED_TENSORRT_VERSION%.
    exit /b 1
)

REM Step 1: Check current CUDA version
echo Checking current CUDA version...
for /f "tokens=2 delims=," %%v in ('nvcc --version ^| findstr /i "release"') do (
    set "CURRENT_CUDA_VERSION=%%v"
)
echo Detected CUDA version: %CURRENT_CUDA_VERSION%

REM Step 2: Compare current CUDA version with desired version
if "%CURRENT_CUDA_VERSION%" equ "%CUDA_VERSION%" (
    echo CUDA v%CUDA_VERSION% is already installed. No action needed.
) else (
    echo Uninstalling CUDA v%CURRENT_CUDA_VERSION%...
    REM Modify the uninstallation command as per your CUDA uninstallation method
    REM Example: powershell -Command "Get-WmiObject -Query 'select * from Win32_Product where Name like '%%CUDA v%CURRENT_CUDA_VERSION%%%'' | ForEach-Object { $_.Uninstall() }"
)

REM Step 3: Download and install CUDA if not already installed
if not exist "%CUDA_INSTALLER%" (
    echo Downloading CUDA v%CUDA_VERSION% installer...
    powershell -Command "Invoke-WebRequest -Uri %CUDA_URL% -OutFile %CUDA_INSTALLER%"
    if %errorlevel% neq 0 (
        echo Error: Failed to download CUDA installer.
        exit /b 1
    )
) else (
    echo CUDA installer already exists: %CUDA_INSTALLER%
)

REM Step 4: Check current cuDNN version
echo Checking current cuDNN version...
REM Add logic to detect current cuDNN version here (if applicable)
set "CURRENT_CUDNN_VERSION="

REM Step 5: Compare current cuDNN version with desired version
if "%CURRENT_CUDNN_VERSION%" equ "%CUDNN_VERSION%" (
    echo cuDNN v%CUDNN_VERSION% is already installed. No action needed.
) else (
    echo Downloading cuDNN v%CUDNN_VERSION%...
    powershell -Command "Invoke-WebRequest -Uri %CUDNN_URL% -OutFile %CUDNN_INSTALLER%"
    if %errorlevel% neq 0 (
        echo Error: Failed to download cuDNN installer.
        exit /b 1
    )
    REM Add installation steps for cuDNN here (e.g., unzip, copy files to CUDA directory)
)

REM Step 6: Download and verify TensorRT version
echo Checking current TensorRT version...
REM Add logic to detect current TensorRT version here (if applicable)
set "CURRENT_TENSORRT_VERSION="

REM Step 7: Compare current TensorRT version with desired version
if "%CURRENT_TENSORRT_VERSION%" equ "%TENSORRT_VERSION%" (
    echo TensorRT v%TENSORRT_VERSION% is already installed. No action needed.
) else (
    echo Downloading TensorRT v%TENSORRT_VERSION%...
    REM Replace %cuda_short_version% with the appropriate CUDA short version (e.g., 12.1 -> 121)
    set "CUDA_SHORT_VERSION=!CUDA_VERSION:.=!"
    set "TENSORRT_INSTALLER=!TENSORRT_INSTALLER:cuda%cuda_short_version%=cuda%CUDA_SHORT_VERSION%!"
    set "TENSORRT_URL=!TENSORRT_URL:cuda%cuda_short_version%=cuda%CUDA_SHORT_VERSION%!"
    powershell -Command "Invoke-WebRequest -Uri %TENSORRT_URL% -OutFile %TENSORRT_INSTALLER%"
    if %errorlevel% neq 0 (
        echo Error: Failed to download TensorRT installer.
        exit /b 1
    )
    REM Add installation steps for TensorRT here (e.g., unzip, install using repo installer)
)

REM Step 8: Update Environment Variables for CUDA
echo Updating environment variables for CUDA...
setx PATH "C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v%CUDA_VERSION%\bin;%PATH%"

REM Step 9: Rebuild Kata_speed
echo Rebuilding Kata_speed...
pushd "C:\path\to\Kata_speed"

make clean
make

if %errorlevel% neq 0 (
    echo Error: Failed to rebuild Kata_speed.
    exit /b 1
)

popd

REM Step 10: Verify Installation
echo Verification of installation...
"C:\path\to\Kata_speed\bin\kata_speed" --version

if %errorlevel% neq 0 (
    echo Error: Verification of installation failed.
    exit /b 1
)

echo Process completed successfully. CUDA v%CUDA_VERSION%, cuDNN v%CUDNN_VERSION%, and TensorRT v%TENSORRT_VERSION% installation should be complete.
pause
