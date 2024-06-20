@echo off
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
powershell -Command "Get-WmiObject -Query 'select * from Win32_Product where Name like "%%CUDA%%"' | ForEach-Object { $_.Uninstall() }"

REM Step 3: Install CUDA v11.4
echo Downloading CUDA v11.4 installer...
powershell -Command "Invoke-WebRequest -Uri https://developer.download.nvidia.com/compute/cuda/11.4.0/local_installers/cuda_11.4.0_471.11_win10.exe -OutFile cuda_11.4.0_471.11_win10.exe"
echo Installing CUDA v11.4...
start /wait cuda_11.4.0_471.11_win10.exe -s

REM Step 4: Update Environment Variables
echo Updating environment variables...
setx PATH "C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v11.4\bin;%PATH%"

REM Step 5: Rebuild Kata_speed
echo Rebuilding Kata_speed...
pushd \path\to\Kata_speed
make clean
make
popd

REM Step 6: Verify Installation
echo Verification of installation...
\path\to\Kata_speed\bin\kata_speed --version

echo Process completed successfully. CUDA v12.4 issue should be resolved.
pause
