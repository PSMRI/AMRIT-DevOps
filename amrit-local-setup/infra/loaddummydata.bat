@echo off
setlocal enabledelayedexpansion

:: MySQL connection details
set HOST=127.0.0.1
set PORT=3306
set USER=root
set PASSWORD=1234

:: Gitbook URL for the SQL files
set GITBOOK_URL=https://1865391384-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2FYfDZFIsUuulWkRHaq4c1%2Fuploads%2F1WdSAf0fQBeJOea70EXE%2FAmritMasterData.zip?alt=media&token=18e0b6d6-487c-4c0c-967a-02cdd94d61ad


:: Download the file using PowerShell's Invoke-WebRequest (equivalent to wget)
echo Downloading AmritMasterData.zip...
powershell -Command "Invoke-WebRequest -Uri '%GITBOOK_URL%' -OutFile 'AmritMasterData.zip'"

If %ERRORLEVEL% neq 0 (
    echo Failed to download AmritMasterData.zip
    exit /b 1
)


:: Extract the file using PowerShell's Expand-Archive (equivalent to unzip)
echo Extracting AmritMasterData.zip...
powershell -Command "Expand-Archive -Path 'AmritMasterData.zip' -DestinationPath 'AmritMasterData'"

:: Path to the extracted SQL files
set SQL_DIR=AmritMasterData/AmritMasterData

:: Associating files with databases
set DATABASES="AmritMasterData.sql=db_iemr" "m_beneficiaryregidmapping_dump_1097.sql=db_1097_identity" "m_beneficiaryregidmapping_dump.sql=db_identity"

:: Iterate over the SQL files and execute them
:: added strings to variables to avoid issues with spaces in paths
for %%F in (%DATABASES%) do (
    for /f "tokens=1,2 delims==" %%A in ("%%~F") do (
        set "FILE=%%A"
        set "DATABASE=%%B"
        echo Running !FILE! on !DATABASE!...
        
        mysql -h %HOST% -P %PORT% -u -p !DATABASE! < "%SQL_DIR%\!FILE!"
        
        if !ERRORLEVEL! equ 0 (
            echo Successfully executed !FILE! on !DATABASE!.
        ) else (
            echo Error executing !FILE! on !DATABASE!.
        )
    )
)

pause

:: Clean up the extracted files
del AmritMasterData.zip
rmdir /s /q AmritMasterData
echo Cleaned up AmritMasterData folder.
