@echo off
setlocal

rem TODO docker change image name
set "IMAGE_NAME=ghcr.io/yo35/mnms:latest"

rem Check whether Docker is available or not.
where docker >nul 2>&1
if errorlevel 1 (
    echo Error: Docker is not installed ^(or not in PATH^). 1>&2
    exit /b 1
)

rem Check whether the Docker daemon can be reached (with Docker Desktop, it must be started).
docker info >nul 2>&1
if errorlevel 1 (
    echo Error: cannot connect to the Docker daemon ^(is Docker Desktop running?^). 1>&2
    exit /b 1
)

rem Note: unlike on Linux, no user mapping is needed: with Docker Desktop, the files written in /data
rem end up owned by the current Windows user.

rem Fetch the latest version of the image if not up to date.
rem If the registry cannot be reached (e.g. offline), fall back to the local copy of the image, if any.
docker pull "%IMAGE_NAME%" 1>&2
if errorlevel 1 (
    echo Warning: cannot check for updates of %IMAGE_NAME%, using the local copy of the image ^(if any^). 1>&2
)

rem In the arguments passed to the container, Windows path separators (backslash) are replaced by '/'
rem (the container runs Linux, which expects '/' as path separator).
rem WARNINGS:
rem  - This conversion affects all the arguments passed to mnms-docker (whether or not they represent a path).
rem    To disable it, remove or comment out the line `if defined args set ...`.
rem  - No conversion is applied to the paths that may appear INSIDE the JSON settings file or Python script
rem    passed to mnms-docker. Thus, they must use '/' as path separator.
rem  - Regardless of path separators, all files used by the simulation (the JSON settings file or Python script,
rem    and any file they reference) must be located in the current directory or one of its subdirectories,
rem    and referenced by relative paths.
set "args=%*"
if defined args set "args=%args:\=/%"

rem Run Docker, with parameters:
rem - `-it`: attach a terminal and keep stdin open, so that the app behaves as when run from a terminal.
rem - `--rm`: delete the container when it exits (otherwise, stopped containers accumulate).
rem - `--volume ...`: mount the current (host) directory as /data in the container.
docker run -it --rm --volume "%CD%:/data" "%IMAGE_NAME%" %args%
exit /b %errorlevel%
