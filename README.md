# Kata_speed

Kata_speed is a Go AI engine inspired by KataGo, designed to provide strong and fast gameplay. It supports most GPUs and CPUs, making it easy to run on a wide range of hardware. With its advanced neural network architecture, Kata_speed delivers powerful and efficient Go game analysis and move prediction.

## Features
- **Supports most GPUs and CPUs**: Ensures compatibility with a wide range of hardware.
- **Easy to run**: Simple setup and execution process.
- **Fast and strong**: Provides quick and powerful gameplay analysis.

## Installation

1. **Download the latest release**: Visit the [release page](https://github.com/changcheng967/Kata_speed/releases) and download the latest version suitable for your system.
2. **Extract the files**: Unzip the downloaded files to your desired location.

## Network Sharing Site

Visit our [network sharing site](https://katagui40b.free.nf/) to download pre-trained networks and share your own.

## Solving CUDA v12.4 Issue

If you encounter issues with CUDA v12.4, you can use the following script to resolve them:

### Instructions:
1. **Customize Paths**: Replace `\path\to\Kata_speed` with the actual path to your Kata_speed repository.
2. **Save the Script**: Save the following script as `solve_cuda_issue.bat`.

```bat
@echo off
SETLOCAL
REM Customize the following path to your Kata_speed repository
SET REPO_PATH=\path\to\Kata_speed

REM Ensure CUDA and cuDNN paths are correctly set
SET CUDA_PATH=C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v12.4
SET CUDNN_PATH=C:\cudnn\cuda

REM Add CUDA and cuDNN to the system path
SET PATH=%CUDA_PATH%\bin;%CUDNN_PATH%\bin;%PATH%

REM Change directory to the Kata_speed repository
cd %REPO_PATH%

REM Perform necessary operations to resolve CUDA v12.4 issues
REM (Add specific commands as needed)

ENDLOCAL
pause
