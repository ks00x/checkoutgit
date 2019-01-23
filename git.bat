@echo off
setlocal ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION

::this also support calls that contains a absolute windows path

::check of one of the params contain a absolute windows path
echo.%* | findstr /r /c:"[a-z]:[\\/]" > nul
if %errorlevel% == 1 (
    ::if not just git with the given parameters
    call :git %*
    exit /b
)

::loop though the params and replace the path with a wslpath
:param_loop
set param_check=%1
if defined param_check (
    call :get_wslpath %param_check% R_PATH
    if defined params (
        set "params=%params% !R_PATH!"
    ) else (
        set "params=!R_PATH!"
    )    
) else (
    goto :param_continue
)
shift
goto :param_loop
:param_continue
::last call git with the new params
call :git %params%
exit /b

::git label
:git
set params=
::first try the call with wslpath
::needed for calls that return a wslpath like: git rev-parse --show-toplevel
wsl wslpath -w $(git %*) 2> nul 
if not %errorlevel% == 0 (
    ::if the call didn't return a wslpath try again without wslpath
    wsl git %*
)
exit /b

::get wslpath label
:get_wslpath
set wslpath_param=%1
::check of current param has windows path
echo %wslpath_param% | findstr /r /b /c:"[a-z]:[\\/]" > nul
if %errorlevel% == 0 (
    ::get wslpath
    for /f "tokens=* USEBACKQ" %%F IN (`wsl wslpath "%wslpath_param%"`) do (
        set wslpath_result=%%F
    )
) else (
    set wslpath_result=%wslpath_param%
)
set %2=%wslpath_result%
exit /b
@echo on