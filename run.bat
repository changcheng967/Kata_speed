cd %cd%
@echo off
if exist "./config.json" (
    echo ok
) else (
    yk_linker_windows.exe config
)
yk_linker_windows.exe run
Pause