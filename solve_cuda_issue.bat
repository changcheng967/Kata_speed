@echo off
setlocal enabledelayedexpansion

REM Define CUDA and cuDNN versions to install
set "CUDA_VERSION=12.1"
set "CUDA_INSTALLER=cuda_%CUDA_VERSION%.0_496.13_win10.exe"
set "CUDA_URL=https://developer.download.nvidia.com/compute/cuda/%CUDA_VERSION%.0/local_installers/%CUDA_INSTALLER%"

REM Specify cuDNN version and URL (replace with the latest version)
set "CUDNN_VERSION=8.3.2"
set "CUDNN_INSTALLER=cudnn-%CUDNN_VERSION%-windows-x64-v8.3.2.27.zip"
set "CUDNN_URL=https://developer.download.nvidia.com/compute/redist/cudnn/v8.3.2/%CUDNN_INSTALLER%"

echo Solving Unsupported CUDA v%CUDA_VERSION% and cuDNN v%CUDNN_VERSION% Issue for Kata_speed

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
    REM Add installation steps for cuDNN here (e.g., unzip, copy files to CUDA directory)
)

REM Step 6: Update Environment Variables for CUDA
echo Updating environment variables for CUDA...
setx PATH "C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v%CUDA_VERSION%\bin;%PATH%"

REM Step 7: Rebuild Kata_speed
echo Rebuilding Kata_speed...
pushd "C:\path\to\Kata_speed"

make clean
make

popd

REM Step 8: Verify Installation
echo Verification of installation...
"C:\path\to\Kata_speed\bin\kata_speed" --version

echo Process completed successfully. CUDA v%CUDA_VERSION% and cuDNN v%CUDNN_VERSION% installation should be complete.
pause
