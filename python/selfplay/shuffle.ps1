# Define parameters
param (
    [string]$BASEDIR,
    [string]$TMPDIR,
    [int]$NTHREADS,
    [int]$BATCHSIZE
)

# Check for required parameters
if (-not $BASEDIR -or -not $TMPDIR -or -not $NTHREADS -or -not $BATCHSIZE) {
    Write-Host "Usage: .\shuffle.ps1 -BASEDIR <basedir> -TMPDIR <tmpdir> -NTHREADS <num_threads> -BATCHSIZE <batch_size>"
    exit
}

# Define directories
$OUTDIR = (Get-Date).ToString("yyyyMMdd-HHmmss")
$OUTDIRTRAIN = Join-Path -Path $BASEDIR -ChildPath "shuffleddata\$OUTDIR\train"
$OUTDIRVAL = Join-Path -Path $BASEDIR -ChildPath "shuffleddata\$OUTDIR\val"
$TMPDIRTRAIN = Join-Path -Path $TMPDIR -ChildPath "train"
$TMPDIRVAL = Join-Path -Path $TMPDIR -ChildPath "val"

# Remove existing output directories if they exist
Write-Host "Removing existing directories if they exist..."
if (Test-Path $OUTDIRTRAIN) {
    Write-Host "Removing existing directory:" $OUTDIRTRAIN
    Remove-Item -Path $OUTDIRTRAIN -Recurse -Force
}
if (Test-Path $OUTDIRVAL) {
    Write-Host "Removing existing directory:" $OUTDIRVAL
    Remove-Item -Path $OUTDIRVAL -Recurse -Force
}

# Wait a moment to ensure directories are removed
Start-Sleep -Seconds 2

# Create directories
Write-Host "Creating directories..."
New-Item -Path $OUTDIRTRAIN -ItemType Directory -Force
New-Item -Path $OUTDIRVAL -ItemType Directory -Force
New-Item -Path $TMPDIRTRAIN -ItemType Directory -Force
New-Item -Path $TMPDIRVAL -ItemType Directory -Force

# Confirm directory creation
$dirsCreatedTrain = Test-Path $OUTDIRTRAIN
$dirsCreatedVal = Test-Path $OUTDIRVAL
$dirsCreatedTmpTrain = Test-Path $TMPDIRTRAIN
$dirsCreatedTmpVal = Test-Path $TMPDIRVAL

if ($dirsCreatedTrain -and $dirsCreatedVal -and $dirsCreatedTmpTrain -and $dirsCreatedTmpVal) {
    Write-Host "Directories created successfully."
} else {
    Write-Host "Failed to create necessary directories."
    exit
}

Write-Host "Beginning shuffle at" (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")

# Path to the Python script
$pythonScriptPath = "C:\Users\chang\OneDrive\Documents\GitHub\Kata_speed\python\shuffle.py"

# Run the shuffling commands
Write-Host "Starting shuffling process..."
try {
    Start-Process python3 -ArgumentList "`"$pythonScriptPath`" -expand-window-per-row 0.4 -taper-window-exponent 0.65 -out-dir `"$OUTDIRTRAIN`" -out-tmp-dir `"$TMPDIRTRAIN`" -approx-rows-per-out-file 70000 -num-processes $NTHREADS -batch-size $BATCHSIZE `"$BASEDIR\selfplay\shuffleddata\train`"" -NoNewWindow -RedirectStandardOutput "$BASEDIR\shuffleddata\$OUTDIR\outtrain.txt" -Wait
    Start-Process python3 -ArgumentList "`"$pythonScriptPath`" -expand-window-per-row 0.4 -taper-window-exponent 0.65 -out-dir `"$OUTDIRVAL`" -out-tmp-dir `"$TMPDIRVAL`" -approx-rows-per-out-file 70000 -num-processes $NTHREADS -batch-size $BATCHSIZE `"$BASEDIR\selfplay\shuffleddata\val`"" -NoNewWindow -RedirectStandardOutput "$BASEDIR\shuffleddata\$OUTDIR\outval.txt" -Wait
} catch {
    Write-Host "Error occurred during shuffling process:" $_.Exception.Message
    exit
}

# Allow time for filesystem changes
Start-Sleep -Seconds 10

# Clean up old directories
Write-Host "Cleaning up old directories..."
$shuffledDataDir = Join-Path -Path $BASEDIR -ChildPath "shuffleddata"
$oldDirs = Get-ChildItem -Path $shuffledDataDir -Directory | Where-Object { $_.CreationTime -lt (Get-Date).AddHours(-2) }
$oldDirs | Sort-Object CreationTime -Descending | Select-Object -Skip 5 | ForEach-Object {
    Write-Host "Removing old directory:" $_.FullName
    Remove-Item -Path $_.FullName -Recurse -Force
}

# Wait for the new directories to be fully created
Write-Host "Waiting for directories to be fully created..."
Start-Sleep -Seconds 5

# Create a symbolic link for current data
$currentTmpDir = Join-Path -Path $shuffledDataDir -ChildPath "current_tmp"
if (Test-Path $currentTmpDir) {
    Write-Host "Removing existing symbolic link:" $currentTmpDir
    Remove-Item -Path $currentTmpDir -ErrorAction SilentlyContinue
}

# Verify the target directory before creating symbolic link
$targetDir = Join-Path -Path $shuffledDataDir -ChildPath $OUTDIR
if (Test-Path $targetDir) {
    Write-Host "Creating symbolic link:" $currentTmpDir
    try {
        New-Item -Path $currentTmpDir -ItemType SymbolicLink -Target $targetDir -Force
    } catch {
        Write-Host "Failed to create symbolic link:" $_.Exception.Message
    }
} else {
    Write-Host "Target directory for symbolic link does not exist:" $targetDir
}

Write-Host "Finished shuffle at" (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
