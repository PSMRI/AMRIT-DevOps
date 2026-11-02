@echo off
setlocal enabledelayedexpansion

:: MySQL connection details
set HOST=127.0.0.1
set PORT=3306
set USER=root
set PASSWORD=1234

:: Gitbook URL for the SQL files (AMRIT_data_dump.zip)
set GITBOOK_URL=https://1865391384-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2FYfDZFIsUuulWkRHaq4c1%2Fuploads%2FYndkB40gFexKANZgvNJ1%2FAMRITMasterData.zip?alt=media^&token=a8af4cf2-07c4-477e-9aa4-016c424f328a


:: Download the file using PowerShell's Invoke-WebRequest (equivalent to wget)
echo Downloading AMRITMasterData.zip...
powershell -Command "Invoke-WebRequest -Uri '%GITBOOK_URL%' -OutFile 'AMRITMasterData.zip'"

If %ERRORLEVEL% neq 0 (
    echo Failed to download AMRITMasterData.zip
    exit /b 1
)


:: Extract the file using PowerShell's Expand-Archive (equivalent to unzip)
echo Extracting AMRITMasterData.zip...
powershell -Command "Expand-Archive -Path 'AMRITMasterData.zip' -DestinationPath 'AMRITMasterData' -Force"

:: Path to the extracted SQL files (zip contains an AMRIT_data_dump\ folder)
set SQL_DIR=AMRITMasterData\AMRIT_data_dump

:: Associating files with databases. Data-only dumps restored AFTER Flyway schema
:: migration; they use column-qualified INSERT IGNORE statements.
set DATABASES="db_iemr.sql=db_iemr" "db_identity.sql=db_identity" "db_1097_identity.sql=db_1097_identity" "db_reporting.sql=db_reporting"

:: Iterate over the SQL files and execute them
:: added strings to variables to avoid issues with spaces in paths
for %%F in (%DATABASES%) do (
    for /f "tokens=1,2 delims==" %%A in ("%%~F") do (
        set "FILE=%%A"
        set "DATABASE=%%B"

        if exist "%SQL_DIR%\!FILE!" (
            echo Running !FILE! on !DATABASE!...

            mysql -h %HOST% -P %PORT% -u %USER% -p%PASSWORD% !DATABASE! < "%SQL_DIR%\!FILE!"

            if !ERRORLEVEL! equ 0 (
                echo Successfully executed !FILE! on !DATABASE!.
            ) else (
                echo Error executing !FILE! on !DATABASE!.
            )
        ) else (
            echo Skipping !FILE! ^(not found in archive^).
        )
    )
)

pause

:: Clean up the extracted files
del AMRITMasterData.zip
rmdir /s /q AMRITMasterData
echo Cleaned up AMRITMasterData folder.
