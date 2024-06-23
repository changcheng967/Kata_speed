@echo off
setlocal

REM Define CUDA version to install
set CUDA_VERSION=12.1

echo Solving Unsupported CUDA v%CUDA_VERSION% Issue for Kata_speed

REM Step 1: Check current CUDA version
echo Checking current CUDA version...
for /f "tokens=2 delims=," %%v in ('nvcc --version') do (
    set CURRENT_CUDA_VERSION=%%v
)
echo Detected CUDA version: %CURRENT_CUDA_VERSION%

REM Step 2: Compare current CUDA version with desired version
if "%CURRENT_CUDA_VERSION%" equ "%CUDA_VERSION%" (
    echo CUDA v%CUDA_VERSION% is already installed. No action needed.
    goto :continue
) else (
    echo Uninstalling CUDA v%CURRENT_CUDA_VERSION%...
    powershell -Command "Get-WmiObject -Query 'select * from Win32_Product where Name like '%%CUDA v%CURRENT_CUDA_VERSION%%%'' | ForEach-Object { $_.Uninstall() }"
)

REM Step 3: Download CUDA %CUDA_VERSION% installer
echo Downloading CUDA v%CUDA_VERSION% installer...
powershell -Command "Invoke-WebRequest -Uri https://developer.download.nvidia.com/compute/cuda/%CUDA_VERSION%.0/local_installers/cuda_%CUDA_VERSION%.0_496.13_win10.exe -OutFile cuda_%CUDA_VERSION%.0_496.13_win10.exe"

REM Step 4: Install CUDA %CUDA_VERSION%
echo Installing CUDA v%CUDA_VERSION%...
start /wait cuda_%CUDA_VERSION%.0_496.13_win10.exe -s

REM Step 5: Update Environment Variables
echo Updating environment variables...
setx PATH "C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v%CUDA_VERSION%\bin;%PATH%"

REM Step 6: Rebuild Kata_speed
echo Rebuilding Kata_speed...
pushd \path\to\Kata_speed

make clean
make

popd

REM Step 7: Verify Installation
echo Verification of installation...
\path\to\Kata_speed\bin\kata_speed --version

echo Process completed successfully. CUDA v%CUDA_VERSION% installation should be complete.
pause

:continue
