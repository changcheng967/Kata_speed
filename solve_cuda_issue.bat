@echo off
setlocal

echo Solving Unsupported CUDA v12.4 Issue for Kata_speed

REM Step 1: Verify CUDA Version
echo Checking CUDA version...
nvcc --version | findstr /C:"release 12.4"
if %errorlevel% NEQ 0 (
    echo CUDA v12.4 not detected. Please ensure you are running this script on a system with CUDA v12.4.
    exit /b 1
)

REM Step 2: Uninstall CUDA v12.4
echo Uninstalling CUDA v12.4...
powershell -Command "Get-WmiObject -Query 'select * from Win32_Product where Name like '%%CUDA%%'' | ForEach-Object { $_.Uninstall() }"

if %errorlevel% NEQ 0 (
    echo Failed to uninstall CUDA v12.4. Exiting script.
    exit /b 1
)

REM Step 3: Install CUDA v11.4
echo Downloading CUDA v11.4 installer...
powershell -Command "Invoke-WebRequest -Uri https://developer.download.nvidia.com/compute/cuda/11.4.0/local_installers/cuda_11.4.0_471.11_win10.exe -OutFile cuda_11.4.0_471.11_win10.exe"

if %errorlevel% NEQ 0 (
    echo Failed to download CUDA v11.4 installer. Exiting script.
    exit /b 1
)

echo Installing CUDA v11.4...
start /wait cuda_11.4.0_471.11_win10.exe -s

if %errorlevel% NEQ 0 (
    echo Failed to install CUDA v11.4. Exiting script.
    exit /b 1
)

REM Step 4: Update Environment Variables
echo Updating environment variables...
setx PATH "C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v11.4\bin;%PATH%"

if %errorlevel% NEQ 0 (
    echo Failed to update environment variables. Please set PATH manually to "C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v11.4\bin". Exiting script.
    exit /b 1
)

REM Step 5: Rebuild Kata_speed
echo Rebuilding Kata_speed...
pushd \path\to\Kata_speed

make clean
if %errorlevel% NEQ 0 (
    echo Failed to clean Kata_speed build. Exiting script.
    popd
    exit /b 1
)

make
if %errorlevel% NEQ 0 (
    echo Failed to rebuild Kata_speed. Exiting script.
    popd
    exit /b 1
)

popd

REM Step 6: Verify Installation
echo Verification of installation...
\path\to\Kata_speed\bin\kata_speed --version

if %errorlevel% NEQ 0 (
    echo Failed to verify installation. Please check manually. Exiting script.
    exit /b 1
)

echo Process completed successfully. CUDA v12.4 issue should be resolved.
pause
